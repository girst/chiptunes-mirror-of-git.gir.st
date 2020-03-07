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
RAMEND = 0x5F
FLASHM = 0x4000

.section .text
.org 0x0000 ; RESET interrupt
	CLR	i0
.org 0x0002 ; INT0 external interrupt
	CLR	i1
.org 0x0004 ; PCINT0 pin change interrupt
	CLR	i2
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
	ADD	Xlo, t ; NOTE: can't overflow, since RAMEND == 0x5F
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
	; NOTE: clr i0..i2 moved to .ord 0x0
	CLR	i3
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
	SLEEP ; wait for interrupt
	RJMP	loop

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

	cpi i2, 0x78 ; 16m23 -- one loop
	breq halt

#ifdef DEBUG
	CBI	PORTB, 2   ; end runtime measurement
#endif // DEBUG
	OUT	TIFR0, one ; clear pending interrupt (routine takes two intr.cycles)
	RETI ; reenables interrupts

;	POWER SAVING MODE
;
;	To reduce physical size, we won't use a latching power switch. Instead,
;	playback will stop after a full iteration (16m23s). Then, a momentary
;	button will trigger a RESET, INT0 or PCINT0 interrupt to resume
;	playback.  Meanwhile, all periphials will be shut down and the clock
;	turned off. The watchdog is permanently off to reduce power consumption.
;	Note: it is not necessary to switch the clock source from the 8MHz
;	oscillator to the 128kHz one, since power-down mode disables the clock
;	completely.

; TODO: if we are using pcint on the audio-out pin, we could instruct the user to short the audio plug to ground to start playback. this would eliminate the button (and associated wiring) completely.

halt:
	;set all pins as input & enable pullups and disable periphials to conserve energy
	ldi x, 0x00
	out DDRB, x
	ldi x, 0x0f
	out PUEB, x
	PRR = 0x35
	ldi x, 0x3 ; bit0: disable Timer0, bit1: disable attiny5/10's ADC
	out PRR, x

#if 0
	;enable (PC)INT0
	EIMSK = 0x13
	; EICRA(0x15)==00: generate INT0 on low level (default, can skip).
	sbi EIMSK, 0 ; enable INT0
	; TODO: the ISR should clear the interrupt raised flag, disable itself, reset DDRB/PUEB/PRR and RETI.
	
	;EIFR(0x14): set to 1 to clear int0 flag

	/* alternatively, using PCINT:
	PCICR(0x12): set to 1 to enable pcint0
	PCIFR(0x11): set to 1 to clear pcint0 flag
	PCMSK(0x10): PCINT0 mask (lsb: portb0, msb: portb3)
	*/
#endif

	;enter power-down-mode
	ldi x, 0x05 ; power-down mode:____010_ ; enable:_______1
	out SMCR, x
	SLEEP
	; NOTE: at this point, only INT0, PCINT0 and RESET can wake up the MCU.

#if 0
	;disable power-down-mode
	clr x; xxx: should do before sleep-ing
	out SMCR, x
#endif
