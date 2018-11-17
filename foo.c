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
	t = data[t];
	/*MOV X_hi==x, data_hi
	  MOV X_lo==t, data_lo
	  ADD X_lo, t
	  ADC X_hi, zero
	  LD  t, X         */
	//t = (((i1&0x1f)<<8|i0)*t)>>8; //TODO

	#define a1 x
	#define a2 _
	a2 = 0;
	a1 = 0;
	#define a0 t

	for (u8 loop = 0; loop < 8; loop++) { //Note: t&2 always zero
		if (t & 1) {
			ADD	(a1, i0)
			ADC	(a2, i1, carry)
		}
		LSR	(a2)
		ROR	(a1)
		ROR	(t)
	}
	t = a1;
	#undef a0
	
	t &= 0x1e; //hint -- TODO: breaks without!?
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
