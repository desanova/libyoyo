
/*

(C)2010-2011, Alexéy Sudáchen, alexey@sudachen.name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#ifndef C_once_B4220D86_3019_4E13_8682_D7F809F4E829
#define C_once_B4220D86_3019_4E13_8682_D7F809F4E829

#include "core.hc"
#include "string.hc"
#include "buffer.hc"

typedef struct _YOYO_BIGINT
  {
    unsigned short digits;
    signed char sign;
    unsigned char capacity; /* extra blocks count */
    halflong_t value[1];
  } YOYO_BIGINT;
  
enum
  {
    YOYO_BIGINT_MINDIGITS   = (256-sizeof(YOYO_BIGINT))/sizeof(halflong_t)+1, 
    SizeOf_Min_YOYO_BIGINT  = sizeof(YOYO_BIGINT)+(YOYO_BIGINT_MINDIGITS-1)*sizeof(halflong_t),
    YOYO_BIGINT_DIGIT_SHIFT = sizeof(halflong_t)*8,
    YOYO_BIGINT_DIGIT_MASK  = (halflong_t)-1L,
  };

typedef struct _YOYO_BIGINT_STATIC
  {
    YOYO_BIGINT bint;
    halflong_t space[YOYO_BIGINT_MINDIGITS-1];
  } YOYO_BIGINT_STATIC;

YOYO_BIGINT *Bigint_Init(quad_t val)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i = 0;
    YOYO_BIGINT *bint = __Malloc(SizeOf_Min_YOYO_BIGINT);
    if ( val < 0 ) { bint->sign = -1; val = -val; } else bint->sign = 1;
    while ( val & YOYO_BIGINT_DIGIT_MASK )
     {
       bint->value[i++] = val & YOYO_BIGINT_DIGIT_MASK;
       val >>= YOYO_BIGINT_DIGIT_SHIFT; 
     }
    bint->digits = i;
    return bint;
  }
#endif
  ;

int Bigint_Bitcount(YOYO_BIGINT *bint) 
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int bc,bcc;
    int i = bint->digits - 1;
    while ( i >= 0 && !bint->value[i] ) --i;
    if ( i < 0 ) return 0;
    bc = cxx_bitcount(bint->value[i]);
    bcc = bc + i*YOYO_BIGINT_DIGIT_SHIFT;   
    return bcc;
  }
#endif
  ;
  
int Bigint_Zero(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i = 0;
    for ( ; i < bint->digits; ++i )
      if ( bint->value[i] ) 
        return 0;
    return 1;
  }
#endif
  ;

#define Bigint_Copy(Bint) Bigint_Copy_Expand(Bint,0)
#define Bigint_Expand(Bint,Extra) Bigint_Copy_Expand(Bint,Extra)
YOYO_BIGINT *Bigint_Copy_Expand(YOYO_BIGINT *bint, int extra_digits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *out = 0;
    int digits, gap;
    
    STRICT_REQUIRE( extra_digits >= 0 );

    if ( bint )
      {
        digits = bint->digits+extra_digits;
        STRICT_REQUIRE( bint->digits > 0 );
      }
    else
      digits = extra_digits;
    
    if ( digits < YOYO_BIGINT_MINDIGITS ) 
      gap = 0;
    else
      gap = digits-YOYO_BIGINT_MINDIGITS;
    
    out = __Malloc(SizeOf_Min_YOYO_BIGINT+gap*sizeof(halflong_t));
    memset(out,0,SizeOf_Min_YOYO_BIGINT+gap*sizeof(halflong_t));
    if ( bint )
      memcpy(out,bint,sizeof(*bint)+(bint->digits*sizeof(halflong_t)));
    else
      out->sign = 1;
    out->digits = digits;
    
    return out;
  }
#endif
  ;

/*
YOYO_BIGINT *Bigint_Expand(YOYO_BIGINT *bint, int extra_digits)
  {
    int digits = bint->digits+extra_digits;
    YOYO_BIGINT *out = 0;
    
    STRICT_REQUIRE( bint );
    STRICT_REQUIRE( bint->digits > 0 );
    STRICT_REQUIRE( extra_digits >= 0 );
    
    if ( digits < YOYO_BIGINT_MINDIGITS ) 
      digits = 0;
    else
      digits -= YOYO_BIGINT_MINDIGITS;
    
    bint = __Realloc(bint,SizeOf_Min_YOYO_BIGINT+digits*sizeof(halflong_t));
    return bint;
  } */

#define Bigint_Less(Bint,Q)  ( Bigint_Cmp(Bint,Q) <  0 )
#define Bigint_Equal(Bint,Q) ( Bigint_Cmp(Bint,Q) == 0 )
long Bigint_Cmp(YOYO_BIGINT *bint, YOYO_BIGINT *q)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    if ( bint != q )
      {
        int ac  = bint->digits;
        int bc  = q->digits;
        halflong_t *a = bint->value+(ac-1); 
        halflong_t *b = q->value+(bc-1); 
        long QQ, Q = ac-bc;
  
        if ( Q ) 
          {
            halflong_t **qq = ( Q < 0 )?&b:&a;
            long QQ = Q;
            if ( QQ < 0 ) QQ = -QQ;
            while ( QQ-- ) if ( *(*qq)-- ) return Q; 
            Q = Yo_MIN(ac,bc);
            STRICT_REQUIRE(bint->value+(Q-1) == a);
            STRICT_REQUIRE(q->value+(Q-1) == b);
          }
        else 
          Q = ac;
  
        for ( QQ = Q; QQ--;  )
          if ( ( Q = (long)*a-- - (long)*b-- ) ) 
            return Q;
      }
      
    return 0;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Mul_Short(YOYO_BIGINT *bint,halflong_t d)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i,j;
    ulong_t Q = 0;
    ulong_t C = 0;

    for ( i = 0, j = bint->digits; i < j; ++i )
      {
        Q = (ulong_t)bint->value[i] * (ulong_t)d + Q;
        C = (Q & YOYO_BIGINT_DIGIT_MASK) + C;
        bint->value[i] = (halflong_t)C;
        Q >>= YOYO_BIGINT_DIGIT_SHIFT;
        C >>= YOYO_BIGINT_DIGIT_SHIFT;
      }

    if ( Q )
      {
        if ( bint->digits >= YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,1);
        else ++bint->digits;
        bint->value[i] = (halflong_t)Q;
      }
      
    return bint;
  }
#endif
  ;
  
YOYO_BIGINT *Bigint_Add_Short(YOYO_BIGINT *bint,halflong_t d)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    halflong_t *i, *iE;
    ulong_t Q = (ulong_t)bint->value[0]+d;
    bint->value[0] = (halflong_t)Q;
    Q >>= YOYO_BIGINT_DIGIT_SHIFT;

    if ( Q )
      for ( i = bint->value+1, iE = bint->value+bint->digits; i < iE && Q; ++i )
        {
          Q += (ulong_t)*i;
          *i = (halflong_t)Q;
          Q >>= YOYO_BIGINT_DIGIT_SHIFT;
        }

    if ( Q )
      {
        int j = i-bint->value;
        if ( bint->digits >= YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,1);
        else ++bint->digits;
        bint->value[j] = (halflong_t)Q;
      }

    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Reset(YOYO_BIGINT *bint,int digits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    if ( !bint )
      bint = Bigint_Expand(bint,digits);
    else
      {
        if ( digits > bint->digits && digits > YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,digits-bint->digits);
        else
          bint->digits = Yo_MAX(digits,1);
      }
    
    memset(bint->value,0,sizeof(halflong_t)*bint->digits);
    return bint;
  }
#endif
  ;

#define Bigint_Bit(Bint,i) \
  (((Bint)->value[i/YOYO_BIGINT_DIGIT_SHIFT] >> (i%YOYO_BIGINT_DIGIT_SHIFT)) & 1 )
#define Bigint_Setbit_(p,val) (p) = ((p)&~(val))|(val)
#define Bigint_Setbit(Bint,i,val) Bigint_Setbit_(\
    (Bint)->value[i/YOYO_BIGINT_DIGIT_SHIFT],\
    (val&1) << (i%YOYO_BIGINT_DIGIT_SHIFT))

YOYO_BIGINT *Bigint_Hishift_Q(YOYO_BIGINT *bint,YOYO_BIGINT *lo,int count,int *bits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i, bi;
    bint = Bigint_Reset(bint,(count+YOYO_BIGINT_DIGIT_SHIFT-1)/YOYO_BIGINT_DIGIT_SHIFT);
  
    count = Yo_MIN(count,*bits);
    *bits -= count;

    for ( i = 0, bi=*bits; i < count; ++i ) 
      Bigint_Setbit(bint,i,Bigint_Bit(lo,i+bi));

    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Hishift_1(YOYO_BIGINT *bint, YOYO_BIGINT *lo,int *bits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    halflong_t Q = 0;
    halflong_t *i, *iE;

    if ( *bits )
      {
        --*bits;
        Q = Bigint_Bit(lo,*bits);
      }

    for ( i = bint->value, iE = bint->value+bint->digits; i != iE; ++i )
      {
        halflong_t S = *i;
        *i = ( S << 1 ) | Q;
        Q = S >> (YOYO_BIGINT_DIGIT_SHIFT-1);
      }
    
    if ( Q )
      {
        int j = bint->digits;
        if ( bint->digits >= YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,1);
        else ++bint->digits;
        bint->value[j] = (halflong_t)Q;
      }

    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Lshift_1(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    halflong_t *i, *iE;
    halflong_t Q = 0;

    for ( i = bint->value, iE = bint->value+bint->digits; i != iE; ++i )
      {
        halflong_t k = *i;
        *i = ( k << 1 ) | Q;
        Q = k >> (YOYO_BIGINT_DIGIT_SHIFT-1);
      }

    if ( Q )
      {
        int j = bint->digits;
        if ( bint->digits >= YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,1);
        else ++bint->digits;
        bint->value[j] = (halflong_t)Q;
      }

    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Rshift_1(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    halflong_t *i, *iE;
    halflong_t Q = 0;

    for ( i = bint->value+bint->digits-1, iE = bint->value-1; i != iE; --i )
      {
        halflong_t k = *i;
        *i = ( k >> 1 ) | Q;
        Q = k << (YOYO_BIGINT_DIGIT_SHIFT-1);
      }
    
    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Lshift(YOYO_BIGINT *bint,unsigned count)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i, dif;
    int w = count%YOYO_BIGINT_DIGIT_SHIFT;
    ulong_t Q = 0;

    if ( w ) for ( i = 0; i < bint->digits; ++i )
      {
        Q |= ((ulong_t)bint->value[i]<<w);
        bint->value[i] = (halflong_t)Q;
        Q = (Q>>YOYO_BIGINT_DIGIT_SHIFT);
      }
      
    if ( Q )
      {
        if ( bint->digits >= YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,1);
        else ++bint->digits;
        bint->value[i] = (halflong_t)Q;
      }

    dif = count/YOYO_BIGINT_DIGIT_SHIFT;
    if ( dif ) 
      {
        int digits = bint->digits;
        if ( digits+dif > YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,dif);
        else bint->digits += dif;
        memmove(bint->value+dif,bint->value,digits*sizeof(halflong_t));
        memset(bint->value,0,dif*sizeof(halflong_t));
      }

    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Sub_Unsign(YOYO_BIGINT *bint,YOYO_BIGINT *q,int sign)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    ulong_t Q;
    int i,j;

    if ( bint->digits < q->digits )
      if ( q->digits > YOYO_BIGINT_MINDIGITS )
        bint = Bigint_Expand(bint,q->digits);
      else
        {
          memset(bint->value+bint->digits,0,sizeof(halflong_t)*(q->digits-bint->digits));
          bint->digits = q->digits;
        }
    
    Q = 0;
    for ( i = 0, j = q->digits; i < j; ++i )
      {
        Q = (ulong_t)bint->value[i] - (ulong_t)q->value[i] - Q;
        bint->value[i] = (halflong_t)Q;
        Q >>= YOYO_BIGINT_DIGIT_SHIFT;
        Q &= 1;
      };

    if ( Q )
      {
        bint->sign = -sign;
        for ( i = 0, j = bint->digits; i < j; ++i )
          bint->value[i] = ~bint->value[i];
        Bigint_Add_Short(bint,1);
      }
    else
      bint->sign = sign;
      
    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Add_Unsign(YOYO_BIGINT *bint,YOYO_BIGINT *q,int sign)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    ulong_t Q;
    int i,j;
    
    if ( bint->digits < q->digits )
      if ( q->digits > YOYO_BIGINT_MINDIGITS )
        bint = Bigint_Expand(bint,q->digits);
      else
        {
          memset(bint->value+bint->digits,0,sizeof(halflong_t)*(q->digits-bint->digits));
          bint->digits = q->digits;
        }
    
    Q = 0;
    for ( i = 0, j = q->digits; i < j; ++i )
      {
        Q = (ulong_t)bint->value[i] + (ulong_t)q->value[i] + Q;
        bint->value[i] = (halflong_t)Q;
        Q >>= YOYO_BIGINT_DIGIT_SHIFT;
      };

    if ( Q )
      {
        if ( bint->digits >= YOYO_BIGINT_MINDIGITS )
          bint = Bigint_Expand(bint,1);
        else ++bint->digits;
        bint->value[i] = (halflong_t)Q;
      }

    bint->sign = sign;
    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Sub(YOYO_BIGINT *bint,YOYO_BIGINT *q)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    if ( bint->sign != q->sign )
      return Bigint_Add_Unsign(bint,q,-q->sign);
    else
      return Bigint_Sub_Unsign(bint,q,q->sign);
  }
#endif
  ;

YOYO_BIGINT *Bigint_Add(YOYO_BIGINT *bint,YOYO_BIGINT *q)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    if ( bint->sign != q->sign )
      return Bigint_Sub_Unsign(bint,q,-q->sign);
    else
      return Bigint_Add_Unsign(bint,q,q->sign);
  }
#endif
  ;

YOYO_BIGINT *Bigint_Divrem(YOYO_BIGINT *bint, YOYO_BIGINT *q, YOYO_BIGINT **rem)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *R, *Q = Bigint_Init(0);
    int bits    = Bigint_Bitcount(bint);
    int divbits = Bigint_Bitcount(q);
  
    if ( divbits > bits ) 
      {
        if ( rem ) *rem = Bigint_Copy(bint);
        return Q;
      }
  
    if ( !divbits ) 
      __Raise(YOYO_ERROR_ZERODIVIDE,0);
      
    R = Bigint_Init(0);
    Q = Bigint_Hishift_Q(Q,bint,divbits,&bits);
  
    for(;;) 
      {
        if ( !Bigint_Less(Q,q) )
          { 
            Q = Bigint_Sub(Q,q); 
            R = Bigint_Add_Short(R,1); 
            STRICT_REQUIRE(Bigint_Less(Q,q));
          }
        if ( !bits ) break;
        R = Bigint_Lshift_1(R);
        Q = Bigint_Hishift_1(Q,bint,&bits);
      }

    if ( rem ) *rem = Q;
    return R;
  }
#endif
  ;
  
YOYO_BIGINT *Bigint_Divrem_Short(YOYO_BIGINT *bint, halflong_t q, halflong_t *rem)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *brem = 0;
    YOYO_BIGINT biq = { 1, 1, 0, {q} };
    bint = Bigint_Divrem(bint,&biq,&brem);
    *rem = brem->value[0];
    return bint;
  }
#endif
  ;
  
YOYO_BIGINT *Bigint_Decode_Str(char *S, int radix)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *bint = Bigint_Init(0);
    char *p = S;
    
    __Auto_Ptr(bint)
      if ( p )
        {
          if ( *p == '-' ) { bint->sign = -1; ++p; }
          else if ( *p == '+' ) ++p;
          
          for ( ;*p; ++p )
            {
              if ( radix == 10 )
                {
                  if ( !isdigit(*p) ) __Raise_Format(YOYO_ERROR_ILLFORMED,("invalid decimal number %s",S));
                  bint = Bigint_Mul_Short(bint,10);
                  bint = Bigint_Add_Short(bint,*p-'0');
                }
              else if ( radix == 16 )
                {
                  if ( !isxdigit(*p) || !isxdigit(p[1]) ) __Raise_Format(YOYO_ERROR_ILLFORMED,("invalid hexadecimal number %s",S));
                  bint = Bigint_Lshift(bint,8);
                  bint->value[0] |= Str_Unhex_Byte(p,0,0);
                  ++p;
                }
              else if ( radix == 2 )
                {
                  if ( *p != '0' && *p != '1' ) __Raise_Format(YOYO_ERROR_ILLFORMED,("invalid binary number %s",S));
                  bint = Bigint_Lshift_1(bint);
                  bint->value[0] |= (byte_t)(*p-'0');
                }
              else
                __Raise_Format(YOYO_ERROR_INVALID_PARAM,("invalid radix %d",radix));
            }
        }
      
    return bint;
  }
#endif
  ;

char *Bigint_Encode_2(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    char *ret = 0;
    __Auto_Ptr(ret)
      {
        int i = 0, bc = Bigint_Bitcount(bint);
        char *S = __Malloc(bc+1);
        
        S[bc] = 0;
        
        if ( bc ) for ( ; i < bc; ++i )
          S[i] = Bigint_Bit(bint,i) ? '1' : '0';
        
        ret = Str_Reverse(S,bc);
      }
    return ret;
  }
#endif
  ;

char *Bigint_Encode_10(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    char *ret = 0;
    __Auto_Ptr(ret)
      {
        YOYO_BUFFER *bf = Buffer_Init(0);
        YOYO_BIGINT *R = Bigint_Copy(bint);
        
        if ( !Bigint_Is_Zero(R) )
          {
            do
              {
                halflong_t rem;
                R = Bigint_Divrem_Short(R,10,&rem);
                Buffer_Fill_Append(bf,'0'+rem,1);
              }
            while ( R->value[0] || !Bigint_Is_Zero(R) );
            if ( bint->sign < 0 ) Buffer_Fill_Append(bf,'-',1);
          }
        
        ret = Str_Reverse(bf->at,bf->count);
      }
    return ret;
  }
#endif
  ;

char *Bigint_Encode_16(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    char *ret = 0;
    __Auto_Ptr(ret)
      {
        int bc = (Bigint_Bitcount(bint)+7)&~7;
        char *S = Str_Hex_Encode(bint->value,bc);
        ret = Str_Reverse(S,bc);
      }
    return ret;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Mul(YOYO_BIGINT *bint, YOYO_BIGINT *d)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *R = Bigint_Expand(0,bint->digits+d->digits+1);
    int i, Qdigi, j, Tdigi;

    for ( i = 0, Qdigi = d->digits, Tdigi = bint->digits; i < Qdigi; ++i )
      {
        ulong_t Q = 0;
        ulong_t C = 0;
        for ( j = 0; j < Tdigi; ++j )
          {
            Q = (ulong_t)d->value[i] * (ulong_t)bint->value[j] + Q;
            C = (ulong_t)R->value[j+i] + (Q & YOYO_BIGINT_DIGIT_MASK) + C;
            R->value[j+i] = (halflong_t)C;
            Q >>=YOYO_BIGINT_DIGIT_SHIFT;
            C >>= YOYO_BIGINT_DIGIT_SHIFT;
          }
        do 
          {
            C = (ulong_t)R->value[Tdigi+i] + (Q & YOYO_BIGINT_DIGIT_MASK) + C;
            R->value[Tdigi+i] = (halflong_t)C;
            Q >>= YOYO_BIGINT_DIGIT_SHIFT;
            C >>= YOYO_BIGINT_DIGIT_SHIFT;
          }
        while ( i < Qdigi && C ); 
      }

    while ( R->digits > 1 && !R->value[R->digits-1] ) --R->digits;
    if ( d->sign != bint->sign ) R->sign = -1;
    return R;
  }
#endif
  ;
  
YOYO_BIGINT *Bigint_Modulo(YOYO_BIGINT *bint, YOYO_BIGINT *mod)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *R = 0;
    int bits = Bigint_Bitcount(bint);
    int modbits = Bigint_Bitcount(mod);
    
    if ( modbits > bits ) return bint;
    
    R = Bigint_Hishift_Q(0,bint,modbits,&bits);
    
    for(;;) 
      {
        if ( !Bigint_Less(R,mod) )
          {
            R = Bigint_Sub(R,mod);
            STRICT_REQUIRE(Bigint_Less(R,mod));
          }
        if ( !bits ) break;
        R = Bigint_Hishift_1(R,bint,&bits);
      }

    return R;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Expmod(YOYO_BIGINT *bint, YOYO_BIGINT *e,YOYO_BIGINT *mod)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *R = 0;
    __Auto_Ptr(R)
      {
        YOYO_BIGINT *E = Bigint_Copy(e);
        YOYO_BIGINT *t = Bigint_Modulo(Bigint_Copy(bint),mod);
        R = Bigint_Init(1);
        
        if ( !Bigint_Zero(E) ) for(;;) 
          {
            if ( E->value[0] & 1 )
              __Auto_Ptr(R) R = Bigint_Modulo(Bigint_Mul(R,t),mod);
            Bigint_Rshift_1(E);
            if ( !E->value[0] && Bigint_Zero(E) ) break;
            __Auto_Ptr(t) t = Bigint_Modulo(Bigint_Mul(t,t),mod);
          }
      }
    return R;
  }
#endif
  ;
  
#endif /* C_once_B4220D86_3019_4E13_8682_D7F809F4E829 */


