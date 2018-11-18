#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

u8 data[] = {   
	0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58,
	0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58
};
u8 zero;	//r16
u8 acc;		//r17
u8 i0;		//r18
u8 i1;		//r19
u8 i2;		//r20
u8 i3;		//r21
u8 n;		//r22
u8 s;		//r23
u8 _;		//r24
		//r25
u8 t;/*==Ml*/	//r26 (Xlo)
u8 x;/*==Mh*/	//r27 (Xhi)
		//r28
		//r29
/*fakestack_l*/	//r30 (Zlo)
/*fakestack_h*/	//r31 (Zhi)
#define Mh x //mod3 vars
#define Ml t // -"-
//http://homepage.divms.uiowa.edu/~jones/bcd/mod.shtml
void mod3(void) {
	// mod3(Mh.Ml) -> t
	#define tmp _
	ADD	(Ml, Mh)
	CLR	(Mh)
	ADC	(Mh, zero, carry) //Mh only holds the carry bit
	MOV	(tmp, Ml)
	SWAP	(tmp)
	ANDI	(tmp, 0x0f)
	SWAP	(Mh)
	OR	(tmp, Mh)
	ANDI	(Ml, 0x0f)
	ADD	(Ml, tmp)
	MOV	(tmp, Ml)
	LSR	(tmp)
	LSR	(tmp)
	ANDI	(Ml, 0x03)
	ADD	(Ml, tmp)
	MOV	(tmp, Ml)
	LSR	(tmp)
	LSR	(tmp)
	ANDI	(Ml, 0x03)
	ADD	(Ml, tmp)
	CPI	(Ml, 3)
	BRPL	(skip)
	SUBI	(Ml, 3)
	skip:;
	RET
	#undef tmp
}
void g(void) {
	// g(i, t) -> t
	// tempvars: `x` and `_`
	#define tmp _
	ANDI	(t, 0x07)
	MOV	(tmp, i2)
	ANDI	(tmp, 3)
	TST	(tmp)
	#undef tmp
	BREQ	(skip)
	SUBI	(t, -8)
	skip:
	//TODO: directly load address to mul_* routine and jump to it?
	;static void* mul_jmptable[] = {   
		&&mul_84, &&mul_9d, &&mul_b0, &&mul_69, &&mul_9d, &&mul_84, &&mul_69, &&mul_58,
		&&mul_75, &&mul_8c, &&mul_b0, &&mul_69, &&mul_8c, &&mul_75, &&mul_69, &&mul_58
	};
	void *t_;
	t_ = mul_jmptable[t];
	#define a1 x
	#define a2 _
	#define a0 t
	CLR	(a2)
	CLR	(a1)
	goto *t_; //GNU extension simulates indirect jump
	/*
	  LDI  Xlo==x, data_lo
	  ADD  Xlo, t
	  ADD  Xlo, t  ; 16 bit value; advance by 2*u8
	  LDI  Xhi==t, data_hi <--this won't work, need t afterwards
	  ADC  Xhi, zero
	  LD   Zlo, X
	  SUBI Xlo, -1
	  ADC  Xhi, zero
	  LD   Zhi, X
	  IJMP Z
	*/
#if 0
	t = data[t];
	/*MOV X_hi==x, data_hi _
	  MOV X_lo==t, data_lo  \_ this won't
	  ADD X_lo, t          _/  work! XXX
	  ADC X_hi, zero
	  LD  t, X         */
	#define a1 x
	#define a2 _
	#define a0 t
	// start MUL
	CLR	(a2)
	CLR	(a1)
#endif

	//sorted by ocurrence, then longest cycle count first
	CPI	(t, 0x69)
	BREQ	(mul_69)
	CPI	(t, 0x75)
	BREQ	(mul_75)
	CPI	(t, 0x9d)
	BREQ	(mul_9d)
	CPI	(t, 0x58)
	BREQ	(mul_58)
	CPI	(t, 0x8c)
	BREQ	(mul_8c)
	CPI	(t, 0x84)
	BREQ	(mul_84)
	CPI	(t, 0xb0)
	BREQ	(mul_b0)
	mul_58: // 0101 1000 (24cy)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)

		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		RJMP	(endmul)
	mul_69: // 0110 1001 (26cy)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)

		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		RJMP	(endmul)
	mul_75: // 0111 0101 (28cy)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)

		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		RJMP	(endmul)
	mul_84: // 1000 0100 (22cy)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)

		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		RJMP	(endmul)
	mul_8c: // 1000 1100 (24cy)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)

		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		RJMP	(endmul)
	mul_9d: // 1001 1101 (28cy)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)

		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		RJMP	(endmul)
	mul_b0: // 1011 0000 (22cy)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)

		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
		LSR (a2)
		ROR (a1)
		LSR (a2)
		ROR (a1)
		ADD (a1, i0)
		ADC (a2, i1, carry)
	endmul:
		LSR (a2) //final shift is a common operation for all
		ROR (a1)
	// end MUL
	MOV	(t, a1)
	#undef a0
	#undef a1
	#undef a2
	RET //TODO: replace CALL/RET with IJMP?
};

int main(void) {
	CLR	(zero)
	CLR	(i0)
	CLR	(i1)
	CLR	(i2)
	CLR	(i3)
	for (;;) {
		MOV	(n, i2)
		LSL	(n)
		LSL	(n)
		#define tmp _
		MOV	(tmp, i1)
		SWAP	(tmp)
		ANDI	(tmp, 0x0f)
		LSR	(tmp)
		LSR	(tmp)
		OR	(n, tmp)
		#undef tmp
		MOV	(s, i3)
		LSR	(s)
		ROR	(s)
		ANDI	(s, 0x80)
		#define tmp _
		MOV	(tmp, i2)
		LSR	(tmp)
		OR	(s, tmp)
		#undef tmp

		//voice 1:
		MOV	(t, n)
		RCALL	g();
		SWAP	(t)
		ANDI	(t, 1)
		MOV	(acc, t)

		//voice 2:
		#define tmp _
		MOV	(tmp, i2)
		LSL	(tmp)
		LSL	(tmp)
		LSL	(tmp)
		MOV	(t, i1)
		SWAP	(t)
		ANDI	(t, 0xf)
		LSR	(t)
		OR	(t, tmp)
		#undef tmp
		EOR	(t, n)
		RCALL	g();
		LSR	(t)
		LSR	(t)
		ANDI	(t, 3)
		AND	(t, s)
		ADD	(acc, t)

		//voice 3:
		MOV	(Ml, i2)
		SWAP	(Ml)
		ANDI	(Ml, 0xf0)
		LSL	(Ml)
		#define tmp _
		MOV	(tmp, i1)
		LSR	(tmp)
		LSR	(tmp)
		LSR	(tmp)
		OR	(Ml, tmp)
		#undef tmp
		MOV	(Mh, i3)
		SWAP	(Mh)
		ANDI	(Mh, 0xf0)
		LSL	(Mh)
		#define tmp _
		MOV	(tmp, i2)
		LSR	(tmp)
		LSR	(tmp)
		LSR	(tmp)
		OR	(Mh, tmp)
		#undef tmp
		RCALL	mod3();
		ADD	(t, n)
		RCALL	g();
		LSR	(t)
		LSR	(t)
		ANDI	(t, 3)
		MOV	(x, s)
		INC	(x)
		#define tmp _
		MOV	(tmp, x)
		LSR	(tmp)
		LSR	(tmp)
		ADD	(tmp, x)
		ROR	(tmp)
		LSR	(tmp)
		ADD	(tmp, x)
		ROR	(tmp)
		LSR	(tmp)
		ADD	(tmp, x)
		ROR	(tmp)
		LSR	(tmp)
		AND	(t, tmp)
		#undef tmp
		ADD	(acc, t)

		//voice 4:
		MOV	(Ml, i2)
		SWAP	(Ml)
		ANDI	(Ml, 0xf0)
		LSL	(Ml)
		LSL	(Ml)
		#define tmp _
		MOV	(tmp, i1)
		LSR	(tmp)
		LSR	(tmp)
		OR	(Ml, tmp)
		#undef tmp
		MOV	(Mh, i3)
		SWAP	(Mh)
		ANDI	(Mh, 0xf0)
		LSL	(Mh)
		LSL	(Mh)
		#define tmp _
		MOV	(tmp, i2)
		LSR	(tmp)
		LSR	(tmp)
		OR	(Mh, tmp)
		#undef tmp
		RCALL	mod3();
		SUB	(t, n)
		NEG	(t)
		SUBI	(t, -8)
		RCALL	g();
		LSR	(t)
		ANDI	(t, 3)
		INC	(s)
		#define tmp _
                MOV	(tmp, s)
		LSR	(tmp)
                ADD	(tmp, s)
		ROR	(tmp)
		LSR	(tmp)
		LSR	(tmp)
                ADD	(tmp, s)
		ROR	(tmp)
                ADD	(tmp, s)
		ROR	(tmp)
		LSR	(tmp)
		LSR	(tmp)
		AND	(t, tmp)
		#undef tmp
		ADD	(acc, t)

		putchar(acc<<4); //TODO
		SUBI	(i0, -1)
		ADC	(i1, zero, !i0)
		ADC	(i2, zero, !i0&&!i1)
		ADC	(i3, zero, !i0&&!i1&&!i2)
	}
}
