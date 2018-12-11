/* REGISTER NAMES */
#define zero r16
#define acc  r17
#define i0   r18
#define i1   r19
#define i2   r20
#define i3   r21
#define n    r22
#define s    r23
#define _    r24
;            r25
#define x    r26 //==Xlo==Mh
#define t    r27 //==Xhi==Ml
;            r28
;            r29
;            r30 Zlo
;            r31 Zhi
; aliases:
#define Xlo  r26
#define Xhi  r27
#define Mh   r26 //mod3 vars
#define Ml   r27 // -"-

/* I/O REGISTERS */
OCR0AL = 0x26
DDRB   = 0x01
PUEB   = 0x03
SPL    = 0x3D
SPH    = 0x3E
CCP    = 0x3C
CLKPSR = 0x36
SMCR   = 0x3A
TCCR0A = 0x2E
TCCR0B = 0x2D
TIMSK0 = 0x2B
TIFR0  = 0x2A

.section .data
	.byte 0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58
	.byte 0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58

.section .text

mod3: ; mod3(Mh.Ml) -> t
	#define tmp _
	ADD	Ml, Mh
	CLR	Mh
	ADC	Mh, zero
	MOV	tmp, Ml
	SWAP	tmp
	ANDI	tmp, 0x0f
	SWAP	Mh
	OR	tmp, Mh
	ANDI	Ml, 0x0f
	ADD	Ml, tmp
	MOV	tmp, Ml
	LSR	tmp
	LSR	tmp
	ANDI	Ml, 0x03
	ADD	Ml, tmp
	MOV	tmp, Ml
	LSR	tmp
	LSR	tmp
	ANDI	Ml, 0x03
	ADD	Ml, tmp
	CPI	Ml, 3
	BRPL	skip
	SUBI	Ml, 3
	skip:
	RET
	#undef tmp

; definitions to mul-tree readable:
.macro always _bit ; nop; for when a test() is not necessary (see tree)
.endm
.macro never _bit  ; nop; for when a test() is not necessary (see tree)
.endm
.macro test _bit,_jmpto
	SBRC	t, _bit
	RJMP	_jmpto
.endm
.macro shift16
	LSR	a2
	ROR	a1
.endm
.macro shift8 ; top three bits don't need to be corrrect, so save cycles by not carrying
	LSR	a1
.endm
.macro shift0 ; nop; last shift is common
.endm
.macro add_shift16
	ADD	a1, i0
	ADC	a2, i1
	shift16
.endm
.macro add_shift8 ; ditto with carrying
	ADD	a1, i0
	shift8
.endm
.macro add_shift0 ; last shift is common
	ADD	a1, i0
.endm

g: ; g(i, t) -> t
	#define tmp _
	ANDI	t, 0x07
	MOV	tmp, i2
	ANDI	tmp, 3
	TST	tmp
	CPSE	tmp, zero
	SUBI	t, -8
	#undef tmp

	#define tmp _
	MOV	tmp, t  ; NOTE: must move value away from `t`, as that is also hi(X)
	LDI	Xhi, hi8(data)  ; TODO: can skip if &data < 0xff (it is)
	LDI	Xlo, lo8(data)
	ADD	Xlo, tmp  ;<-- the offset (formerly `t`) into data[]
	ADC	Xhi, zero  ; ditto skip
	LD	tmp, X
	MOV	t, tmp
	#undef tmp

	#define a1 x
	#define a2 _
	#define a0 t
	CLR	a2
	CLR	a1

	/* decision tree multiplication saves cycles and (hopefully) reduces code size
	                     _xxx?
	                 /           \
	           _xx?0                _xx1?
	             |                    |
	           _x?00                _x?01
	         /       \             /     \
	    _?000         _?100      _?001    _?101
	    /   \         /   \        |      /   \
	 _0000 _1000   _0100 _1100   _1001 _0101 _1101
	   |     |       |     |       |     |     |
	  ...   ...     ...   ...     ...   ...   ...
	   |     |       |     |       |     |     |
	   B0    58     84    8C      69     75    9D   */
		test	0, m____1
	m____0:	shift16
		never	1
	m___00:	shift16
		test	2, m__100
	m__000:	shift16
		test	3, m_1000
	m_0000:	shift16
		always	4
		add_shift16
		always	5
		add_shift8
		never	6
		shift8
		always	7
		add_shift0
		RJMP	end_mul ; calc'd 0xb0

	m_1000:	add_shift16
		always	4
		add_shift16
		never	5
		shift8
		always	6
		add_shift8
		never	7
		shift0
		RJMP	end_mul ; calc'd 0x58

	m__100:	add_shift16
		test	3, m_1100
	m_0100:	shift16
		RJMP	upper_8 ;'ll calc 0x84

	m_1100:	add_shift16
	upper_8: ; used twice, so deduplicated
		never	4
		shift16
		never	5
		shift8
		never	6
		shift8
		always	7
		add_shift0
		RJMP	end_mul ; calc'd 0x8c

	m____1: add_shift16
		never	1
	m___01:	shift16
		test	2, m__101
	m__001:	shift16
		always	3
	m_1001:	add_shift16
		never	4
		shift16
		always	5
		add_shift8
		always	6
		add_shift8
		never	7
		shift0
		RJMP	end_mul ; calc'd 0x69

	m__101:	add_shift16
		test	3, m_1101
	m_0101:	shift16
		always	4
		add_shift16
		always	5
		add_shift8
		always	6
		add_shift8
		never	7
		shift0
		RJMP	end_mul ; calc'd 0x75

	m_1101:	add_shift16
		always	4
		add_shift16
		never	5
		shift8
		never	6
		shift8
		always	7
		add_shift0
		; calc'd 0x9d

	end_mul:
		LSR a1 ;final shift is a common operation for all

	MOV	t, a1 ;;TODO: use a1 in main() directly
	#undef a0
	#undef a1
	#undef a2
	RET ; TODO: replace CALL/RET with IJMP?

main:
	CLR	zero
	CLR	i0
	CLR	i1
	CLR	i2
	CLR	i3
	;;TODO: setup stack pointer, portb, clock, sleep mode, timer0
	RJMP	sample
sample: ;;TODO: this will probably become the timer0 overflow interrupt handler
	MOV	n, i2
	LSL	n
	LSL	n
	#define tmp _
	MOV	tmp, i1
	SWAP	tmp
	ANDI	tmp, 0x0f
	LSR	tmp
	LSR	tmp
	OR	n, tmp
	#undef tmp
	MOV	s, i3
	LSR	s
	ROR	s
	ANDI	s, 0x80
	#define tmp _
	MOV	tmp, i2
	LSR	tmp
	OR	s, tmp
	#undef tmp

	; voice 1:
	MOV	t, n
	RCALL	g
	SWAP	t
	ANDI	t, 1
	MOV	acc, t

	; voice 2:
	#define tmp _
	MOV	tmp, i2
	LSL	tmp
	LSL	tmp
	LSL	tmp
	MOV	t, i1
	SWAP	t
	ANDI	t, 0xf
	LSR	t
	OR	t, tmp
	#undef tmp
	EOR	t, n
	RCALL	g
	LSR	t
	LSR	t
	ANDI	t, 3
	AND	t, s
	ADD	acc, t

	; voice 3:
	MOV	Ml, i2
	SWAP	Ml
	ANDI	Ml, 0xf0
	LSL	Ml
	#define tmp _
	MOV	tmp, i1
	LSR	tmp
	LSR	tmp
	LSR	tmp
	OR	Ml, tmp
	#undef tmp
	MOV	Mh, i3
	SWAP	Mh
	ANDI	Mh, 0xf0
	LSL	Mh
	#define tmp _
	MOV	tmp, i2
	LSR	tmp
	LSR	tmp
	LSR	tmp
	OR	Mh, tmp
	#undef tmp
	RCALL	mod3
	ADD	t, n
	RCALL	g
	LSR	t
	LSR	t
	ANDI	t, 3
	MOV	x, s
	INC	x
	#define tmp _
	MOV	tmp, x
	LSR	tmp
	LSR	tmp
	ADD	tmp, x
	ROR	tmp
	LSR	tmp
	ADD	tmp, x
	ROR	tmp
	LSR	tmp
	ADD	tmp, x
	ROR	tmp
	LSR	tmp
	AND	t, tmp
	#undef tmp
	ADD	acc, t

	; voice 4:
	MOV	Ml, i2
	SWAP	Ml
	ANDI	Ml, 0xf0
	LSL	Ml
	LSL	Ml
	#define tmp _
	MOV	tmp, i1
	LSR	tmp
	LSR	tmp
	OR	Ml, tmp
	#undef tmp
	MOV	Mh, i3
	SWAP	Mh
	ANDI	Mh, 0xf0
	LSL	Mh
	LSL	Mh
	#define tmp _
	MOV	tmp, i2
	LSR	tmp
	LSR	tmp
	OR	Mh, tmp
	#undef tmp
	RCALL	mod3
	SUB	t, n
	NEG	t
	SUBI	t, -8
	RCALL	g
	LSR	t
	ANDI	t, 3
	INC	s
	#define tmp _
	MOV	tmp, s
	LSR	tmp
	ADD	tmp, s
	ROR	tmp
	LSR	tmp
	LSR	tmp
	ADD	tmp, s
	ROR	tmp
	ADD	tmp, s
	ROR	tmp
	LSR	tmp
	LSR	tmp
	AND	t, tmp
	#undef tmp
	ADD	acc, t

	SWAP	acc
	OUT	OCR0AL, acc
	SUBI	i0, -1
	SBCI	i1, -1
	SBCI	i2, -1
	SBCI	i3, -1

	rjmp sample ;;TODO: -> RETI
