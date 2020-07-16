//#define DEBUG
#define CAL_MAGIC 0x9e   // attiny4 handwired
//#define CAL_MAGIC 0x8d  // attiny4 devboard
//#define CAL_MAGIC 0xa7 // attiny9 devboard


/* REGISTER NAMES */
#define acc  r16
#define i0   r17
#define i1   r18
#define i2   r19
; XXX: move registers down!
#define n    r21
#define s    r22
#define t    r23 //==Ml
#define x    r24 //==a1==Mh
#define _    r25 //==a2
#define Xlo  r26
#define Xhi  r27
#define one  r28
;            r29
;            r30 Zlo
;            r31 Zhi
; aliases:
#define Ml t //mod3 vars
#define Mh x // -"-
#define a1 x //mul_ vars
#define a2 _ // -"-

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
EIMSK  = 0x13
EICRA  = 0x15
RAMEND = 0x5F
FLASHM = 0x4000

.section .text
.org 0x0000 ; RESET interrupt
	RJMP	main
.org 0x0002 ; INT0 interrupt
	CBI	EIMSK, 0 ; disable interrupt
	RJMP	wakeup
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
	BRCS	skip
	SUBI	Ml, 3
	skip:
	RET
	#undef tmp

g: ; g(i, t) -> t
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

	LDI	Xlo, lo8(notes)
	ADD	Xlo, t
	LD	t, X

	CLR	a2

	; begin of mulitiplication:
		LSR t
		BRCC skip1
		ADD a1, i0
		ADC a2, i1
	skip1:
		LSR a2
		ROR a1
		LSR t
	;        BRCC skip2 -- this bit is always zero
	;        ADD a1, i0
	;        ADC a2, i1
	;skip2:
		LSR a2
		ROR a1
		LSR t
		BRCC skip3
		ADD a1, i0
		ADC a2, i1
	skip3:
		LSR a2
		ROR a1
		LSR t
		BRCC skip4
		ADD a1, i0
		ADC a2, i1
	skip4:
		LSR a2
		ROR a1
		LSR t
		BRCC skip5
		ADD a1, i0
		ADC a2, i1
	skip5:
		LSR a2
		ROR a1
		LSR t
		BRCC skip6
		ADD a1, i0
	skip6:
		LSR a1
		LSR t
		BRCC skip7
		ADD a1, i0
	skip7:
		LSR a1
		LSR t
		BRCC skip8
		ADD a1, i0
	skip8:
		LSR a1

	MOV	t, a1 ;;TODO: use a1 in loop: directly
	RET

main: ; setup routine
	CLR	i0
	CLR	i1
	CLR	i2
	CLR	acc ; we output a dummy sample before the actual first one
	LDI	Xhi, hi8(FLASHM + notes) ; never changes
	LDI	one, 1      ; mostly for clearing TIM0_OVF bit

	#define zero i0
	LDI	x, RAMEND
	OUT	SPL, x      ; init stack ptr
	OUT	SPH, zero   ; -"-
	OUT	PUEB, zero  ; disable pullups
	LDI	x, 0x03
	OUT	DDRB, x     ; PORTB0:pwm, PORTB1:debug (PORTB2:wakeup-input)
	LDI	x, 0xd8
	OUT	CCP, x      ; change protected ioregs
	OUT	CLKPSR, one ; clock prescaler 1/2 (4Mhz)
	LDI	x, CAL_MAGIC     ; determined by trial-and-error (->PORTB1)
	OUT	OSCCAL, x   ; set oscillator calibration
	OUT	WDTCSR, zero; turn off watchdog

	;set timer/counter0 to 8bit fastpwm, non-inverting, no prescaler
	LDI	x, 0x81
	OUT	TCCR0A, x
	LDI	x, 0x09
	OUT	TCCR0B, x
	OUT	TIMSK0, one ; enable tim0_ovf
	SEI
	#undef zero

loop:
	CPI	i2, 0x78    ; 16m23 -- one loop
	BREQ	halt

	SLEEP
	RJMP	loop

//we use an external pullup(>= 1kohm), as line-input usually has an impedance
//between 20-100kohm, while the attiny's internal pullups are "only" 20-50kohm
//(which is too strong)
halt:
	;stop the music, and check whether PINB0 is plugged into an audio
	;sink. Until then, conserve as much battery as possible.
	CLR	i2          ; clear halt condition

	#define zero i2
	; disable timer to free audio pin for wakeup function:
	OUT	TCCR0A, zero
	OUT	TCCR0B, zero

	#define five x
	LDI	x, 0x05

	;assert high level on pullup pins to avoid accidentally triggering INT0:
	OUT	PORTB, five

	OUT	DDRB, zero  ; set all pins as input

	;set up INT0 to wake up when a audio sink is connected
	SBI	EIMSK, 0    ; set-bit-0 high => enable interrupt
	OUT	EICRA, zero ; logical low generates INT0

	;enter power-down-mode
	OUT	SMCR, five  ; sleep mode: power-down, enabled
	SLEEP
	;OUT	SMCR, one   ; sleep mode: idle, enabled
	OUT	SMCR, zero  ; sleep mode: disabled
	#undef five

	RJMP loop

wakeup:
	LDI	x, 0x03     ; restore output pins
	OUT	DDRB, x
	LDI	x, 0x81
	OUT	TCCR0A, x   ; reenable COMA bits
	LDI	x, 0x09
	OUT	TCCR0B, x   ; reenable timer0
	RETI
	#undef zero

sample:
	OUT	OCR0AL, acc ; start by outputting a sample, because routine has variable runtime
#ifdef DEBUG
	SBI	PORTB, 1 ; to measure runtime
#endif // DEBUG

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
	MOV	s, i2
	LSR	s

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
	MOV	Mh, i2
	LSR	Mh
	LSR	Mh
	LSR	Mh
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
	MOV	Mh, i2
	LSR	Mh
	LSR	Mh
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

#ifdef DEBUG
	CBI	PORTB, 1   ; end runtime measurement
#endif // DEBUG
	OUT	TIFR0, one ; clear pending interrupt (routine takes two intr.cycles)
	RETI ; reenables interrupts
