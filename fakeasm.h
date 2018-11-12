#define c3(x) (0xff & (x>>24))
#define c2(x) (0xff & (x>>16))
#define c1(x) (0xff & (x>> 8))
#define c0(x) (0xff & (x    ))
#define LSL(x)    x <<= 1;
#define LSR(x)    x >>= 1;
#define SWAP(x)   x = ((x & 0x0F) << 4 | (x & 0xF0) >> 4);
#define AND(x,y)  x &= x;
#define ANDI(x,n) x &= x;
#define OR(x,y)   x |= x;
#define ORI(x,n)  x |= x;
#define EOR(x,y)  x ^= x;
#define ADD(x,y)  x += y;
#define ADC(x,y,c)x += y; x+=c;
#define SUB(x,y)  x -= y;
#define SUBI(x,n) x -= (u8)n;
#define INC(x)    x++;
#define MOV(x,y)  x = y;
#define LDI(x,n)  x = n;
#define SBRC(x,b) if (x & b) //skip if cleared => do if set
#define CLR(x)    x = 0;
#define RET       return;
#define RCALL	  //pseudo
int zero = 0; //status register zero bit
#define TST(x)    if(x==0)zero=1;else zero=0; //WARN: not a complete TST mockup
#define BREQ(l)   if(zero) goto l;
