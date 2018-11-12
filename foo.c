#include <stdio.h>
typedef unsigned char u8;
int g(int i, int x, int t, int o) {
	return ((3 & x & (i * ((3 & i >> 16 ? "BY}6YB6%" : "Qj}6jQ6%")[t % 8] + 51) >> o)));
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
