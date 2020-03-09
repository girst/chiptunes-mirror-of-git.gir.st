/* REGISTER NAMES */
#define acc  r16
#define i0   r17
#define i1   r18
#define i2   r19
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
PCMSK  = 0x10
PCIFR  = 0x11
PCICR  = 0x12
PRR    = 0x35
RAMEND = 0x5F
FLASHM = 0x4000

.section .text
.org 0x0000 ; RESET interrupt
	CLR	i0
	RJMP	main
.org 0x0004 ; PCINT0 interrupt
	CBI	PCICR, 0 ; disable interrupt
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
	ADD	Xlo, t ; NOTE: notes are positioned so that hi8(notes) never changes
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
		BRCC skip6	;sbrc t, NNN
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
	; NOTE: clr i0 moved to .ord 0x0
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
	LDI	x, 0x05
	OUT	DDRB, x     ; PORTB0:pwm, PORTB2:debug
	LDI	x, 0xd8
	OUT	CCP, x      ; change protected ioregs
	OUT	CLKPSR, one ; clock prescaler 1/2 (4Mhz)
	LDI	x, 0xa7     ; determined by trial-and-error (->PORTB2)
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
	CPI	i2, 0x78>>5 ; 16m23 -- one loop
;TODO^: s/>>5//
	BREQ	halt

	SLEEP
	RJMP	loop

halt:
	CLR	i2          ; clear halt condition

	#define zero i2
	; disable timer0, set all pins as input+pullup to conserve battery.
	LDI	x, 0x08     ; disable timer clock
	OUT	TCCR0B, x
	;OUT	PRR, one ; §8.3: only helps in idle and active modes


sbi PORTB, 0 ; force pin high, so pcint triggers on connect to ground --- XXX TODO: this does not work reliably for PORTB0
sbi PORTB, 2 ; force pin high, so pcint triggers on connect to ground (works reliably for portb2)


	OUT	DDRB, zero
	LDI	x, 0x0f
	OUT	PUEB, x



	SBI	PCMSK, 2    ; listen for pin change on the audio out pin (i.e. wake up when a audio sink is connected)
;TODO^: s/2/0/
	OUT	PCICR, one  ; enable PCINT0

	;enter power-down-mode
	LDI	x, 0x05     ; sleep mode: power-down, enabled
	OUT	SMCR, x
	SLEEP
	OUT	SMCR, one   ; sleep mode: idle, enabled

	RJMP loop

wakeup:
	SBI	PCIFR, 0 ; clear interrupt
	OUT	PUEB, zero ; remove pullups
	LDI	x, 0x05 ; restore output pins
	OUT	DDRB, x
	;OUT	PRR, zero ; reenable periphials
	LDI	x, 0x09
	OUT	TCCR0B, x ; reenable timer0
	RETI
	#undef zero

sample:
	OUT	OCR0AL, acc ; start by outputting a sample, because routine has variable runtime
#ifdef DEBUG
	SBI	PORTB, 2 ; to measure runtime
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
	CBI	PORTB, 2   ; end runtime measurement
#endif // DEBUG
	OUT	TIFR0, one ; clear pending interrupt (routine takes two intr.cycles)
	RETI ; reenables interrupts
