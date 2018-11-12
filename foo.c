#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

u8 data[] = {   
	0x84, 0x9d, 0xb0, 0x69, 0x9d, 0x84, 0x69, 0x58,
	0x75, 0x8c, 0xb0, 0x69, 0x8c, 0x75, 0x69, 0x58
};
u8 x;
u8 t;
u8 o;
u8 g(int i) {
	u8 tmp;
	ANDI	(t, 0x07)
	tmp = i >> 16;
	ANDI	(tmp, 3)
	TST	(tmp)
	BREQ	(skip)
	SUBI	(t, -8)
	skip:
	t = data[t];
	t = (i*t) >> o;
	AND	(t, x)
	ANDI	(t, 3)
	return t;
};

int main(void) {
	int i;
	unsigned short n;
	unsigned short s;
	u8 acc;
	for (i = 0;; i++) {
		acc = 0;
		n = i >> 14;
		s = i >> 17;

		//voice 1:
		LDI	(x, 1)
		MOV	(t, n)
		LDI	(o, 12)
		acc += g(i);

		//voice 2:
		MOV	(x, s)
		t = n ^ i >> 13;
		LDI	(o, 10)
		acc += g(i);

		//voice 3:
		x = s / 3;
		t = n + ((i >> 11) % 3);
		LDI	(o, 10)
		acc += g(i);

		//voice 4:
		x = s / 5;
		t = 8 + n - ((i >> 10) % 3);
		LDI	(o, 9)
		acc += g(i);
		putchar(acc<<4);
	}
}
