#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

u8 data[] = {   
	0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58,
	0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58
};
u8 zero; //zero register
u8 i0;
u8 i1;
u8 i2;
u8 i3;
u8 x;
u8 t;
u8 o;
u8 _;
#define Mh o //mod3 vars
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
	/*MOV X_hi==_, data_hi
	  MOV X_lo==t, data_lo
	  ADD X_lo, t
	  ADC X_hi, zero
	  LD  t, X         */
	t = (((i1&0x1f)<<8|i0)*t)>>8; //TODO
	RET //TODO: CALL/RET is expensive; store PC in register and RJMP, then JRMP back
};

int main(void) {
	u8 n;
	u8 s;
	u8 acc;
	//TODO: clear all vars/registers
	for (;;) {
		MOV	(n, i2)
		LSL	(n)
		LSL	(n)
		#define tmp acc
		MOV	(tmp, i1)
		SWAP	(tmp)
		ANDI	(tmp, 0x0f)
		LSR	(tmp)
		LSR	(tmp)
		OR	(n, tmp)
		#undef tmp
		MOV	(s, i3)
		ROR	(s)
		ROR	(s)
		ANDI	(s, 0x80)
		#define tmp acc
		MOV	(tmp, i2)
		LSR	(tmp)
		OR	(s, tmp)
		#undef tmp

		//voice 1:
		MOV	(t, n)
		LDI	(o, 4)
		RCALL	g();
	t >>= o; //NOTE: o == {1, 2, 4}
	ANDI	(t, 3)
		ANDI	(t, 1)
		MOV	(acc, t)

		//voice 2:
		#define tmp o
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
		LDI	(o, 2)
		RCALL	g();
	t >>= o; //NOTE: o == {1, 2, 4}
	ANDI	(t, 3)
		AND	(t, s)
		ADD	(acc, t)

		//voice 3:
		MOV	(Ml, i2)
		SWAP	(Ml)
		ANDI	(Ml, 0xf0)
		LSL	(Ml)
		#define tmp Mh
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
		LDI	(o, 2)
		RCALL	g();
	t >>= o; //NOTE: o == {1, 2, 4}
	ANDI	(t, 3)
		MOV	(x, s)
		INC	(x)
		#define tmp o
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
                MOV	(x, tmp)
		#undef tmp
		AND	(t, x)
		ADD	(acc, t)

		//voice 4:
		MOV	(Ml, i2)
		SWAP	(Ml)
		ANDI	(Ml, 0xf0)
		LSL	(Ml)
		LSL	(Ml)
		#define tmp Mh
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
		LDI	(o, 1)
		RCALL	g();
	t >>= o; //NOTE: o == {1, 2, 4}
	ANDI	(t, 3)
		MOV	(x, s)
		INC	(x)
		#define tmp o
                MOV	(tmp, x)
		LSR	(tmp)
                ADD	(tmp, x)
		ROR	(tmp)
		LSR	(tmp)
		LSR	(tmp)
                ADD	(tmp, x)
		ROR	(tmp)
                ADD	(tmp, x)
		ROR	(tmp)
		LSR	(tmp)
		LSR	(tmp)
                MOV	(x, tmp)
		#undef tmp
		AND	(t, x)
		ADD	(acc, t)

		putchar(acc<<4); //TODO
		SUBI	(i0, -1)
		ADC	(i1, zero, !i0)
		ADC	(i2, zero, !i0&&!i1)
		ADC	(i3, zero, !i0&&!i1&&!i2)
	}
}
