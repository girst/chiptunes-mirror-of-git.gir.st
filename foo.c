#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

u8 data[] = {   
	0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58,
	0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58
};
u8 i0;
u8 i1;
u8 i2;
u8 i3;
u8 x;
u8 t;
u8 o;
void g(int i) {
	// g(i, x, t, o) -> t
	u8 tmp;
	ANDI	(t, 0x07)
	MOV	(tmp, i2)
	ANDI	(tmp, 3)
	TST	(tmp)
	BREQ	(skip)
	SUBI	(t, -8)
	skip:
	t = data[t];
	t = (i*t) >> o;
	AND	(t, x)
	ANDI	(t, 3)
	RET
};

int main(void) {
	int i = 0;
	unsigned short n;
	unsigned short s;
	u8 acc;
	//TODO: clear all vars/registers
	for (;;) {
		acc = 0;
		n = (i2<<2 | i1>>6);
		s = i >> 17;

		//voice 1:
		LDI	(x, 1)
		MOV	(t, n)
		LDI	(o, 12)
		RCALL	g(i);
		MOV	(acc, t)

		//voice 2:
		MOV	(x, s)
		t = n ^ i >> 13;
		LDI	(o, 10)
		RCALL	g(i);
		ADD	(acc, t)

		//voice 3:
		x = s / 3;
		t = n + ((i >> 11) % 3);
		LDI	(o, 10)
		RCALL	g(i);
		ADD	(acc, t)

		//voice 4:
		x = s / 5;
		t = 8 + n - ((i >> 10) % 3);
		LDI	(o, 9)
		RCALL	g(i);
		ADD	(acc, t)

		putchar(acc<<4);
		i++;
		#define tmp acc
		LDI	(tmp, 0)
		SUBI	(i0, -1)
		ADC	(i1, tmp, !i0)
		ADC	(i2, tmp, !i0&&!i1)
		ADC	(i3, tmp, !i0&&!i1&&!i2)
	}
}
