#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

u8* data = "Qj}6jQ6%BY}6YB6%";
int g(int i, u8 x, u8 t, u8 o) {
	t = t & 0x7;
	if (3 & i >> 16 ) t+=8;
	u8 xxx = data[t];
	SUBI	(xxx, -51)
	xxx = (i*xxx) >> o;
	AND	(xxx, x)
	ANDI	(xxx, 3)
	return xxx;
};

int main(void) {
	int i;
	int n;
	int s;
	u8 acc;
	for (i = 0;; i++) {
		acc = 0;
		n = i >> 14;
		s = i >> 17;
		acc += g(i, 1, n, 12);
		acc += g(i, s, n ^ i >> 13, 10);
		acc += g(i, s / 3, n + ((i >> 11) % 3), 10);
		acc += g(i, s / 5, 8 + n - ((i >> 10) % 3), 9);
		putchar(acc<<4);
	}
}
