#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

u8 data[] = {   
	0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58,
	0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58
};
u8 zero;
u8 i0;
u8 i1;
u8 i2;
u8 i3;
u8 x;
u8 t;
u8 o;
u8 _;
void g(void) {
	// g(i, x, t, o) -> t
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
	  CLR zero
	  ADC X_hi, zero
	  LD  t, X         */
	t = (((i1&0x1f)<<8|i0)*t)>>8 >> o; //TODO; NOTE: o == {1, 2, 4}
	AND	(t, x)
	ANDI	(t, 3)
	RET
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
		LDI	(x, 1)
		MOV	(t, n)
		LDI	(o, 4)
		RCALL	g();
		MOV	(acc, t)

		//voice 2:
		MOV	(x, s)
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
		ADD	(acc, t)

		//voice 3:
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
		t = ((i3&0x01)<<13 | i2<<5 | i1>>3) % 3; //TODO
		ADD	(t, n)
		LDI	(o, 2)
		RCALL	g();
		ADD	(acc, t)

		//voice 4:
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
		t = ((i3&0x01)<<14 | i2<<6 | i1>>2) % 3; //TODO
		SUB	(t, n)
		NEG	(t)
		SUBI	(t, -8)
		LDI	(o, 1)
		RCALL	g();
		ADD	(acc, t)

		putchar(acc<<4);
		#define tmp acc
		CLR	(tmp) //NOTE: maybe use dedicated zero register?
		SUBI	(i0, -1)
		ADC	(i1, tmp, !i0)
		ADC	(i2, tmp, !i0&&!i1)
		ADC	(i3, tmp, !i0&&!i1&&!i2)
		#undef tmp
	}
}
