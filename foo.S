/* REGISTER NAMES */
#define acc  r16
#define i0   r17
#define i1   r18
#define i2   r19
#define i3   r20
#define n    r21
#define s    r22
#define t    r23 //==Ml
#define x    r24 //==a1==Mh
#define _    r25 //==a2
#define Xlo  r26
#define Xhi  r27
;            r28
;            r29
;            r30 Zlo
;            r31 Zhi
; aliases:
#define Ml   r23 //mod3 vars
#define Mh   r24 // -"-

/* I/O REGISTERS */
OCR0AL = 0x26
DDRB   = 0x01
PORTB  = 0x02
PUEB   = 0x03
SPL    = 0x3D
SPH    = 0x3E
CCP    = 0x3C
CLKPSR = 0x36
OSCCAL = 0x39
WDTCSR = 0x31
SMCR   = 0x3A
TCCR0A = 0x2E
TCCR0B = 0x2D
TIMSK0 = 0x2B
TIFR0  = 0x2A
RAMEND = 0x5F
FLASHM = 0x4000

.section .text
.org 0x0000 ; RESET interrupt
	RJMP	main
.org 0x0008 ; TIM0_OVF interrupt
	RJMP	sample

notes:
	.byte 0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58
	.byte 0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58

mod3: ; mod3(Mh.Ml) -> t
	#define tmp _
	ADD	Ml, Mh
	CLR	Mh
	ADC	Mh, Mh  ; store carry in Mh
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
#define a1 x
#define a2 _
.macro always _bit ; nop; for when a test() is not necessary (see tree)
.endm
.macro never _bit  ; nop; for when a test() is not necessary (see tree)
.endm
.macro test _bit,_jmpto
	SBRC	t, \_bit
	RJMP	\_jmpto
.endm
.macro i_test _bit,_jmpto ; inverted test (for reordered 0x8_)
	SBRS	t, \_bit
	RJMP	\_jmpto
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
.macro add16
	ADD	a1, i0
	ADC	a2, i1
.endm
.macro add8 ; ditto with carrying
	ADD	a1, i0
.endm
#undef a2
#undef a1

g: ; g(i, t) -> t
	#define a1 x
	#define a2 _
	CLR	a1

	#define tmp _
	#define zero a1
	ANDI	t, 0x07
	MOV	tmp, i2
	ANDI	tmp, 3
	CPSE	tmp, zero
	SUBI	t, -8
	#undef zero
	#undef tmp

	;TODO: check correctness!
	LDI	Xlo, lo8(notes)
	ADD	Xlo, t ; NOTE: can't overflow, since RAMEND == 0x5F
	LD	t, X

	CLR	a2

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
		add16 $ shift16
		always	5
		add8 $ shift8
		never	6
		shift8
		always	7
		add8 $ shift0
		RJMP	end_mul ; calc'd 0xb0

	m_1000:	add16 $ shift16
		always	4
		add16 $ shift16
		never	5
		shift8
		always	6
		add8 $ shift8
		never	7
		shift0
		RJMP	end_mul ; calc'd 0x58

	m__100:	add16 $ shift16
		i_test	3, m_0100
	m_1100:	add16
	m_0100:	shift16
		never	4
		shift16
		never	5
		shift8
		never	6
		shift8
		always	7
		add8 $ shift0
		RJMP	end_mul ; calc'd 0x8c / 0x84

	m____1: add16 $ shift16
		never	1
	m___01:	shift16
		test	2, m__101
	m__001:	shift16
		always	3
	m_1001:	add16 $ shift16
		never	4
		shift16
		always	5
		add8 $ shift8
		always	6
		add8 $ shift8
		never	7
		shift0
		RJMP	end_mul ; calc'd 0x69

	m__101:	add16 $ shift16
		test	3, m_1101
	m_0101:	shift16
		always	4
		add16 $ shift16
		always	5
		add8 $ shift8
		always	6
		add8 $ shift8
		never	7
		shift0
		RJMP	end_mul ; calc'd 0x75

	m_1101:	add16 $ shift16
		always	4
		add16 $ shift16
		never	5
		shift8
		never	6
		shift8
		always	7
		add8 $ shift0
		; calc'd 0x9d

	end_mul:
		LSR a1 ;final shift is a common operation for all

	MOV	t, a1 ;;TODO: use a1 in loop: directly
	#undef a1
	#undef a2
	RET ; TODO: replace CALL/RET with IJMP?

main: ; setup routine
	CLR	i0
	CLR	i1
	CLR	i2
	CLR	i3
	CLR	acc ; we output a dummy sample before the actual first one
	LDI	Xhi, hi8(FLASHM + notes) ; never changes

	#define zero i0
	#define one _
	LDI	one, 1
	LDI	x, RAMEND
	OUT	SPL, x      ; init stack ptr
	OUT	SPH, zero   ; -"-
	OUT	PUEB, zero  ; disable pullups
	LDI	x, 0x05
	OUT	DDRB, x     ; PORTB0:pwm, PORTB2:debug
	LDI	x, 0xd8
	OUT	CCP, x      ; change protected ioregs
	OUT	CLKPSR, one ; clock prescaler 1/2 (4Mhz)
	LDI	x, 0xa7     ; determined by trial-and-error (->PORTB2)
	OUT	OSCCAL, x   ; set oscillator calibration
	OUT	WDTCSR, zero; turn off watchdog ;;TODO: incomplete - see datasheet pg48
	; OUT	SMCR, 2     ; sleep mode 'power down' ('idle' (default) has faster response time)

	;set timer/counter0 to 8bit fastpwm, non-inverting, no prescaler
	LDI	x, 0x81
	OUT	TCCR0A, x
	LDI	x, 0x09
	OUT	TCCR0B, x
	OUT	TIMSK0, one ; enable tim0_ovf
	SEI
	#undef one
	#undef zero

loop:
	SLEEP ; wait for interrupt
	RJMP	loop

sample:
	; potential TODO: softcounter in r25 to only update duty cicle every n iterations
	; potential TODO: save/restore status register (SREG=0x3f) (only if something in mainloop)

	OUT	OCR0AL, acc ; start by outputting a sample, because routine has variable runtime
	SBI	PORTB, 2 ; to measure runtime

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

	SWAP	acc ; acc<<4, to be passed to OCR0AL

	SUBI	i0, -1
	SBCI	i1, -1
	SBCI	i2, -1
	SBCI	i3, -1

	CBI	PORTB, 2 ; end runtime measurement
	LDI	_, 1     ; TODO: could use own register for speed
	OUT	TIFR0, _ ; clear pending interrupt (routine takes two intr.cycles)
	RETI ; reenables interrupts
