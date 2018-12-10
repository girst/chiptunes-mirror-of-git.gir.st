#include <stdio.h>
#include "fakeasm.h"
typedef unsigned char u8;

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
u8 x;/*==Ml*/	//r26 (Xlo)
u8 t;/*==Mh*/	//r27 (Xhi)
		//r28
		//r29
void *Z;	//r30 (Zlo)
/*...*/		//r31 (Zhi)
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
static void* mul_jmptable[] = { // replaces data[] section at the top
	&&mul_84, &&mul_9d, &&mul_b0, &&mul_69, &&mul_9d, &&mul_84, &&mul_69, &&mul_58,
	&&mul_75, &&mul_8c, &&mul_b0, &&mul_69, &&mul_8c, &&mul_75, &&mul_69, &&mul_58
	// addresses of mul_* stored in little endian (i.e. { lo(mul_84), hi(mul_84), ... })
};
	#define tmp _
	ANDI	(t, 0x07)
	MOV	(tmp, i2)
	ANDI	(tmp, 3)
	TST	(tmp)
	CPSE	(tmp, zero)
	SUBI	(t, -8)
	#undef tmp
	#define a1 x
	#define a2 _
	#define a0 t
	CLR	(a2)
	CLR	(a1)
	goto *mul_jmptable[t]; /*
	  ;NOTE: optimize by placing *X and *Z below address 0xff and get rid of hi byte
	  LDI  Xlo, lo(mul_jmptable)
	  LDI  Xhi, hi(mul_jmptable)
	  ADD  Xlo, t
	  ADC  Xhi, zero
	  ADD  Xlo, t      ; advance twice, since it's a 16 bit address
	  ADC  Xhi, zero
	  LD   Zlo, X
	  SUBI Xlo, -1
	  ADC  Xhi, zero
	  LD   Zhi, X
	  IJMP Z */

	//don't care about top three bits (so don't compute them => _)
	mul_58: // ___1 1000 (24cy)
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
		LSR (a1)
		ADD (a1, i0)
		LSR (a1)
		RJMP	(endmul)
	mul_69: // ___0 1001 (26cy)
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
		LSR (a1)
		ADD (a1, i0)
		LSR (a1)
		RJMP	(endmul)
	mul_75: // ___1 0101 (28cy)
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
		LSR (a1)
		ADD (a1, i0)
		LSR (a1)
		RJMP	(endmul)
	mul_84: // ___0 0100 (22cy)
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
		LSR (a1)
		LSR (a1)
		ADD (a1, i0)
		RJMP	(endmul)
	mul_8c: // ___0 1100 (24cy)
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
		LSR (a1)
		LSR (a1)
		ADD (a1, i0)
		RJMP	(endmul)
	mul_9d: // ___1 1101 (28cy)
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
		LSR (a1)
		LSR (a1)
		ADD (a1, i0)
		RJMP	(endmul)
	mul_b0: // ___1 0000 (22cy)
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
		LSR (a1)
		LSR (a1)
		ADD (a1, i0)
	endmul:
		LSR (a1) //final shift is a common operation for all
	// end MUL
	MOV	(t, a1) //TODO: use a1 in main() directly
	#undef a0
	#undef a1
	#undef a2
	RET //TODO: replace CALL/RET with IJMP? (requires undoing goto-mul-hack)
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
		ADC	(i1, zero, !i0) //XXX: must use "sbci i1,-1" in the assembly version
		ADC	(i2, zero, !i0&&!i1) //          sbci i2,-1
		ADC	(i3, zero, !i0&&!i1&&!i2) //     sbci i3,-1
	}
}
