#include <stdio.h>
typedef unsigned char u8;
int g(int i, int x, int t, int o) {
    return ((3 & x &
	     (i *
	      ((3 & i >> 16 ? "BY}6YB6%" : "Qj}6jQ6%")[t % 8] +
	       51) >> o)) << 4);
};

int main(void) {
int i;
int n;
int s;
    for (i = 0;; i++) {
	putchar(g(i, 1, n = i >> 14, 12) +
		g(i, s = i >> 17, n ^ i >> 13, 10) + 
		g(i, s / 3, n + ((i >> 11) % 3), 10) + 
		g(i, s / 5, 8 + n - ((i >> 10) % 3), 9));
    }
}
