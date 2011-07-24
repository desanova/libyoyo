
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
#include "random.hc"

typedef struct _YOYO_BIGINT
  {
    unsigned short digits;
    signed char sign;
    unsigned char capacity; /* extra blocks count */
    halflong_t value[1];
  } YOYO_BIGINT;
  
enum
  {
    YOYO_BIGINT_BLOCKSIZE   = 128,
    YOYO_BIGINT_BLOCKMASK   = YOYO_BIGINT_BLOCKSIZE-1,
    YOYO_BIGINT_MINDIGITS   = (YOYO_BIGINT_BLOCKSIZE-sizeof(YOYO_BIGINT))/sizeof(halflong_t)+1, 
    YOYO_BIGINT_BLKDIGITS   = YOYO_BIGINT_BLOCKSIZE/sizeof(halflong_t), 
    SizeOf_Min_YOYO_BIGINT  = sizeof(YOYO_BIGINT)+(YOYO_BIGINT_MINDIGITS-1)*sizeof(halflong_t),
    YOYO_BIGINT_DIGIT_SHIFT = sizeof(halflong_t)*8,
    YOYO_BIGINT_DIGIT_MASK  = (halflong_t)-1L,
  };

typedef struct _YOYO_BIGINT_STATIC
  {
    YOYO_BIGINT bint;
    halflong_t space[YOYO_BIGINT_MINDIGITS-1];
  } YOYO_BIGINT_STATIC;

#define Bigint_Size_Of_Digits(Digits) ((((Digits-1)*sizeof(halflong_t)+sizeof(YOYO_BIGINT))+YOYO_BIGINT_BLOCKMASK)&~YOYO_BIGINT_BLOCKMASK)
#define Bigint_Digits_Of_Bits(Bits) ((bits+sizeof(halflong_t)*8-1)/(sizeof(halflong_t)*8))

#define Bigint_Init(Value) Bigint_Init_Digits(Value,1)
YOYO_BIGINT *Bigint_Init_Digits(quad_t val, int digits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i = 0;
    YOYO_BIGINT *bint;
    if ( digits < YOYO_BIGINT_MINDIGITS ) digits = YOYO_BIGINT_MINDIGITS;
    bint = __Malloc(Bigint_Size_Of_Digits(digits));
    //printf("malloc %d\n",Bigint_Size_Of_Digits(digits));
    //puts(Yo_Btrace());
    if ( val < 0 ) { bint->sign = -1; val = -val; } else bint->sign = 1;
    while ( val & YOYO_BIGINT_DIGIT_MASK )
     {
       bint->value[i++] = val & YOYO_BIGINT_DIGIT_MASK;
       val >>= YOYO_BIGINT_DIGIT_SHIFT; 
     }
    if ( i < digits )
      memset(bint->value+i,0,(digits-i)*sizeof(halflong_t));
    bint->digits = Yo_MAX(i,1);
    bint->capacity = ((digits-YOYO_BIGINT_MINDIGITS)+YOYO_BIGINT_BLKDIGITS-1)/YOYO_BIGINT_BLKDIGITS;
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
    bc = Bitcount_Of(bint->value[i]);
    bcc = bc + i*YOYO_BIGINT_DIGIT_SHIFT;   
    return bcc;
  }
#endif
  ;
  
int Bigint_Is_1(YOYO_BIGINT *bint)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i;
    if ( bint->value[0] != 1 )
      return 0;
    for ( i = 1; i < bint->digits; ++i )
      if ( bint->value[i] ) 
        return 0;
    return 1;
  }
#endif
  ;

int Bigint_Is_0(YOYO_BIGINT *bint)
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
    
    if ( digits <= YOYO_BIGINT_MINDIGITS ) 
      gap = 0;
    else
      gap = digits-YOYO_BIGINT_MINDIGITS;
    
    out = __Malloc(Bigint_Size_Of_Digits(digits));
    //printf("malloc %d\n",Bigint_Size_Of_Digits(digits));
    //puts(Yo_Btrace());
    memset(out,0,Bigint_Size_Of_Digits(digits));
    if ( bint )
      memcpy(out,bint,sizeof(*bint)+((bint->digits-1)*sizeof(halflong_t)));
    else
      out->sign = 1;
      
    out->digits = digits;
    out->capacity = (gap+YOYO_BIGINT_BLKDIGITS-1)/YOYO_BIGINT_BLKDIGITS;
    
    return out;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Expand(YOYO_BIGINT *bint, int extra_digits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    if ( bint )
      {
        int digits = bint->digits+extra_digits;
        YOYO_BIGINT *out = 0;
    
        STRICT_REQUIRE( bint );
        STRICT_REQUIRE( bint->digits > 0 );
        STRICT_REQUIRE( extra_digits >= 0 );
    
        if ( bint->capacity*YOYO_BIGINT_BLKDIGITS + YOYO_BIGINT_MINDIGITS >= digits )
          {
            memset(bint->value+bint->digits,0,extra_digits*sizeof(halflong_t));
            bint->digits = digits;
            return bint;
          }
      }
    
    return Bigint_Copy_Expand(bint,extra_digits);
  }
#endif
  ;
  
#define Bigint_Alloca(Digits) Bigint_Setup_(alloca(Bigint_Size_Of_Digits(Digits)), Digits)
YOYO_BIGINT *Bigint_Setup_(YOYO_BIGINT *bint, int digits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    REQUIRE(bint);
    
    memset(bint,0,Bigint_Size_Of_Digits(digits));
    bint->digits = 1;
    bint->sign = 1;
    if ( digits > YOYO_BIGINT_MINDIGITS )
      bint->capacity =  ((digits-YOYO_BIGINT_MINDIGITS)+YOYO_BIGINT_BLKDIGITS-1)/YOYO_BIGINT_BLKDIGITS;
    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Copy_To(YOYO_BIGINT *bint, YOYO_BIGINT *dst)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    if ( dst->digits < bint->digits )
      dst = Bigint_Expand(dst,bint->digits-dst->digits);
    memcpy(dst->value,bint->value,sizeof(halflong_t)*bint->digits);
    dst->digits = bint->digits;
    dst->sign   = bint->sign;
    return dst;
  }
#endif
  ;

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
            QQ = Q;
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

YOYO_BIGINT *Bigint_Sub_Short(YOYO_BIGINT *bint,halflong_t d)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    halflong_t *i, *iE;
    ulong_t Q;
    
    if ( bint->sign < 1 ) return Bigint_Add_Short(bint,d);
    
    Q = (ulong_t)bint->value[0]-d;
    bint->value[0] = (halflong_t)Q;

    Q = ( Q >> YOYO_BIGINT_DIGIT_SHIFT ) & 1;

    if ( Q )
      for ( i = bint->value+1, iE = bint->value+bint->digits; i < iE && Q; ++i )
        {
          Q = (ulong_t)*i;
          --Q;
          *i = (halflong_t)Q;
          Q = ( Q >> YOYO_BIGINT_DIGIT_SHIFT ) & 1;
        }

    if ( Q )
      {
        int j;
        bint->sign = -bint->sign;
        for ( j = 0; j < bint->digits; ++j )
          bint->value[j] = ~bint->value[j];
        bint = Bigint_Add_Short(bint,1);
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
    int i = *bits-1, j;
    bint = Bigint_Reset(bint,(count+YOYO_BIGINT_DIGIT_SHIFT-1)/YOYO_BIGINT_DIGIT_SHIFT);
    
    count = Yo_MIN(count,*bits);
    *bits -= count;
    
    for ( j = count-1 ; j >= 0 ; --j, --i ) 
      {
        halflong_t d = lo->value[i/YOYO_BIGINT_DIGIT_SHIFT];
        d >>= (i%YOYO_BIGINT_DIGIT_SHIFT);
        bint->value[j/YOYO_BIGINT_DIGIT_SHIFT] |= ( (d&1) << (j%YOYO_BIGINT_DIGIT_SHIFT));
      }
      
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

YOYO_BIGINT *Bigint_Rshift(YOYO_BIGINT *bint,unsigned count)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i, dif;
    int w = count%YOYO_BIGINT_DIGIT_SHIFT;

    bint->value[0] = bint->value[0] >> w;
    
    if ( w ) for ( i = 1; i < bint->digits; ++i )
      {
        halflong_t Q = bint->value[i];
        bint->value[i-1] |= Q << (YOYO_BIGINT_DIGIT_SHIFT-w);
        bint->value[i] = Q >> w;
      }
        
    dif = count/YOYO_BIGINT_DIGIT_SHIFT;
    if ( dif )
      {
        int j = Yo_MAX(bint->digits-dif,0);
        if ( j )
          memmove(bint->value,bint->value+dif,j*sizeof(halflong_t));
        memset(bint->value+j,0,(bint->digits-j)*sizeof(halflong_t));
        bint->digits = Yo_MAX(j,1);
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

    for ( ; Q && i < bint->digits; ++i )
      {
        Q = (ulong_t)bint->value[i] - Q;
        bint->value[i] = (halflong_t)Q;
        Q >>= YOYO_BIGINT_DIGIT_SHIFT;
        Q &= 1;
      }
      
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

    for ( ; Q && i < bint->digits; ++i )
      {
        Q = (ulong_t)bint->value[i] + Q;
        bint->value[i] = (halflong_t)Q;
        Q >>= YOYO_BIGINT_DIGIT_SHIFT;
      }
      
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

#define Bigint_Div(Bint,Q) Bigint_Divrem(Bint,Q,0)
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
    int i;
    ulong_t Q = 0;
    for ( i = bint->digits-1; i >= 0; --i )
      {
        Q <<= YOYO_BIGINT_DIGIT_SHIFT;
        Q |= bint->value[i];
        bint->value[i] = (halflong_t)(Q/q);
        Q = Q%q;
      }
    if ( rem ) *rem = (halflong_t)Q;
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

        if ( !Bigint_Is_0(R) )
          {
            do
              {
                halflong_t rem;
                R = Bigint_Divrem_Short(R,10,&rem);
                Buffer_Fill_Append(bf,'0'+rem,1);
              }
            while ( R->value[0] || !Bigint_Is_0(R) );
            while ( bf->at[bf->count-1] == '0' ) --bf->count;
            if ( bint->sign < 0 ) Buffer_Fill_Append(bf,'-',1);
          }
        else
          Buffer_Fill_Append(bf,'0',1);
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
        int bc = (Bigint_Bitcount(bint)+7)/8;
        char *S = Str_Hex_Encode(bint->value,bc);
        ret = Str_Reverse(S,bc*2);
      }
    return ret;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Mul(YOYO_BIGINT *bint, YOYO_BIGINT *d)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *R = Bigint_Alloca(bint->digits+d->digits+1);
    int i, Qdigi, j, Tdigi;

    R->digits = bint->digits+d->digits+1;

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
    return Bigint_Copy_To(R,bint);
  }
#endif
  ;
  
YOYO_BIGINT *Bigint_Modulo(YOYO_BIGINT *bint, YOYO_BIGINT *mod)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int bits = Bigint_Bitcount(bint);
    int modbits = Bigint_Bitcount(mod);
    YOYO_BIGINT *R = Bigint_Alloca(mod->digits+1);
    
    if ( modbits > bits ) return bint;
    
    R = Bigint_Hishift_Q(R,bint,modbits,&bits);
    
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
    
    return Bigint_Copy_To(R,bint);
  }
#endif
  ;

YOYO_BIGINT *Bigint_Modmul(YOYO_BIGINT *bint, YOYO_BIGINT *d, YOYO_BIGINT *mod)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *R = Bigint_Alloca(bint->digits+d->digits+1);
    int i, Qdigi, j, Tdigi;
    int bits, modbits;
    R->digits = bint->digits+d->digits+1;

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

    bits = Bigint_Bitcount(R);
    modbits = Bigint_Bitcount(mod);
    
    if ( modbits > bits ) return Bigint_Copy_To(R,bint);
    
    bint = Bigint_Hishift_Q(bint,R,modbits,&bits);
    
    for(;;) 
      {
        if ( !Bigint_Less(bint,mod) )
          {
            bint = Bigint_Sub(bint,mod);
            STRICT_REQUIRE(Bigint_Less(bint,mod));
          }
        if ( !bits ) break;
        bint = Bigint_Hishift_1(bint,R,&bits);
      }
    
    return bint;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Expmod(YOYO_BIGINT *bint, YOYO_BIGINT *e,YOYO_BIGINT *mod)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *E = Bigint_Alloca(e->digits);
    YOYO_BIGINT *t = Bigint_Alloca(mod->digits);
    YOYO_BIGINT *R = 0;
    
    __Auto_Ptr(R)
      {
        E = Bigint_Copy_To(e,E);
        t = Bigint_Modulo(Bigint_Copy_To(bint,t),mod);
        R = bint;
        R->value[0] = 1;
        R->digits = 1;
        
        if ( !Bigint_Is_0(E) ) for(;;) 
          {
            if ( E->value[0] & 1 )
              R = Bigint_Modmul(R,t,mod);
            Bigint_Rshift_1(E);
            if ( !E->value[0] && Bigint_Is_0(E) ) break;
            t = Bigint_Modmul(t,t,mod);
          }
      }
      
    return R;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Invmod(YOYO_BIGINT *bint, YOYO_BIGINT *mod)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *i = 0;
    
    __Auto_Ptr(i)
      {
        YOYO_BIGINT *b = Bigint_Copy(mod);
        YOYO_BIGINT *j = Bigint_Init(1);
        YOYO_BIGINT *c = Bigint_Copy(bint);
        i = Bigint_Init(0);
    
        while ( c->value[0] || !Bigint_Is_0(c) )
          {
            YOYO_BIGINT *y;
            YOYO_BIGINT *q;
            YOYO_BIGINT *x;
            x = Bigint_Divrem(b,c,&y);
            b = c;
            c = y;
            q = Bigint_Sub(i,Bigint_Mul(Bigint_Copy(j),x));
            i = j;
            j = q;
          }
      
        if ( i->sign < 0 ) i = Bigint_Add(i,mod);
      }
    
    return i;
  }
#endif
  ;

#ifndef _YOYO_BINGINT_BUILTIN
extern
#endif
halflong_t First_Prime_Values[]
#ifdef _YOYO_BINGINT_BUILTIN
= {
#include "prime_values.inc"        
}
#endif
  ;

#ifndef _YOYO_BINGINT_BUILTIN
extern
#endif
int First_Prime_Values_Count
#ifdef _YOYO_BINGINT_BUILTIN
= sizeof(First_Prime_Values)/sizeof(First_Prime_Values[0])
#endif
  ;

#ifdef _YOYO_BINGINT_BUILTIN
enum 
  { 
    YOYO_PRIME_MAX_COUNT = /*1229*/ sizeof(First_Prime_Values)/sizeof(First_Prime_Values[0]),
    YOYO_PRIME_RSAPUBLIC_MIN = 256, 
    YOYO_PRIME_RSAPUBLIC_MAX = YOYO_PRIME_MAX_COUNT,
    YOYO_PRIME_TEST_Q = 32,
  };
#endif

halflong_t First_Prime(int no)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    STRICT_REQUIRE(no >= 0 && no<YOY_PRIME_MAX_COUNT);
    return First_Prime_Values[no];
  }
#endif
  ;

int Bigint_Ferma_Prime_Test(YOYO_BIGINT *bint, int q)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int is_prime = 1;
    __Auto_Release
      {
        int i;
        YOYO_BIGINT *p   = Bigint_Alloca(bint->digits);
        YOYO_BIGINT *p_1 = Bigint_Alloca(bint->digits);
        YOYO_BIGINT *t   = Bigint_Alloca(1);
    
        if ( !q ) q = YOYO_PRIME_TEST_Q;
        STRICT_REQUIRE( q > 0 && q < PRIME_MAX_COUNT );

        p = Bigint_Copy_To(bint,p);
        p_1 = Bigint_Sub_Short(Bigint_Copy_To(bint,p_1),1);

        for ( i =0; is_prime && i < q; ++i )
          {
            t->value[0] = First_Prime_Values[i];
            t->digits = 1;
            if ( ! Bigint_Is_1(Bigint_Expmod(t,p_1,p)) )
              is_prime = 0;
          }
      }
      
    return is_prime;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Prime(int bits, int q, int maxcount,YOYO_BIGINT *tmp)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i,n;
    YOYO_BIGINT *ret = 0;
    YOYO_BIGINT *r = tmp;
    
    if ( !q ) q = YOYO_PRIME_TEST_Q;
    if ( !maxcount ) maxcount = 101;
    
    STRICT_REQUIRE( maxount > 0 );
    STRICT_REQUIRE( bits > 8 );
    STRICT_REQUIRE( q > 0 && q < 500 );

    n = Yo_MIN(128,bits-3);
    if ( !r )
      r = Bigint_Alloca(Bigint_Digits_Of_Bits(bits)+1);
    
    while ( !ret && maxcount-- ) __Auto_Ptr(ret)
      {
        r->digits   = 1;
        r->value[0] = 2;

        for ( i=0; i < bits-3; ++i )
          {
            r = Bigint_Lshift_1(r);
            r->value[0] |= Random_Bits(1);
          }

        r = Bigint_Lshift_1(r);
        r->value[0] |= 1;  

        for ( i = 0; i < n; ++i )
          {
            if ( Bigint_Ferma_Prime_Test(r,q) )
              {
                ret = !tmp ? Bigint_Copy(r) : r;
                break;
              }
            r = Bigint_Add_Short(r,2);
          }
       }
     
    if ( !ret )
      __Raise(YOYO_ERROR_LIMIT_REACHED,"failed to generate prime");
    return ret;
  }
#endif
  ;
  
void Bigint_Generate_Rsa_PQ(
  YOYO_BIGINT /*out*/ **rsa_P, int pBits,
  YOYO_BIGINT /*out*/ **rsa_Q, int qBits,
  YOYO_BIGINT /*out*/ **rsa_N)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int lt = 0;
    int bits = qBits+pBits-1;
    YOYO_BIGINT *nMax = Bigint_Init(1);
    YOYO_BIGINT *nMin = Bigint_Init(1);
    YOYO_BIGINT *n, *p, *q;
    YOYO_BIGINT *pr = Bigint_Alloca(Bigint_Digits_Of_Bits(pBits)+1);
    YOYO_BIGINT *qr = Bigint_Alloca(Bigint_Digits_Of_Bits(qBits)+1);
    YOYO_BIGINT *nr = Bigint_Alloca(Bigint_Digits_Of_Bits(bits)+1);

    nMax = Bigint_Sub_Short(Bigint_Lshift(nMax,bits),1);
    nMin = Bigint_Lshift(nMin,bits-1);

    REQUIRE(bits >= 64);
    STRICT_REQUIRE(pBits > 0);
    STRICT_REQUIRE(qBits > 0);
    STRICT_REQUIRE(Bigint_Less(nMin,nMax));

    for(;;)
      {
        __Purge(&lt);
        p = q = 0;
        p = Bigint_Prime(pBits,0,0,pr);
        q = Bigint_Prime(qBits,0,0,qr);
        n = Bigint_Mul(Bigint_Copy_To(p,nr),q);
        if ( Bigint_Less(n,nMax) || Bigint_Less(nMin,n) )
          break;
      }
  
    *rsa_P = (p == pr) ? Bigint_Copy(p) : p;
    *rsa_Q = (q == qr) ? Bigint_Copy(q) : q; 
    *rsa_N = (n == nr) ? Bigint_Copy(n) : n;
  }
#endif
  ;

YOYO_BIGINT *Bigint_Mutal_Prime(YOYO_BIGINT *bint, int bits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    YOYO_BIGINT *ret = 0;
    YOYO_BIGINT *r = Bigint_Alloca(Bigint_Digits_Of_Bits(bits)+1);
    YOYO_BIGINT *d = Bigint_Alloca(bint->digits);
    while (!ret) __Auto_Ptr(ret)
      {
        YOYO_BIGINT *x = Bigint_Prime(bits,0,0,r);
        Bigint_Copy_To(bint,d);
        if ( !Bigint_Is_0(Bigint_Modulo(d,x)) )
          ret = (x == r) ? Bigint_Copy(x) : x;
      }
    return ret;
  }
#endif
  ;
  
YOYO_BIGINT *Bigint_First_Mutal_Prime(YOYO_BIGINT *bint, int skip_primes)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    int i;
    halflong_t rem = 0;
    halflong_t prime;
    YOYO_BIGINT *r = Bigint_Alloca(bint->digits);
    
    REQUIRE(skip_primes > 0 && skip_primes < YOYO_PRIME_MAX_COUNT/2 );
    
    for ( i = skip_primes; !rem && i < YOYO_PRIME_MAX_COUNT; ++i )
      {
        YOYO_BIGINT *x = Bigint_Copy_To(bint,r);
        prime = First_Prime_Values[i];
        Bigint_Divrem_Short(r,prime,&rem);
      }
    
    if ( rem )         
      return Bigint_Init(prime);
    
    return 0;      
  }
#endif
  ;

void Bigint_Generate_Rsa_Key_Pair(
  YOYO_BIGINT /*out*/ **rsa_pub, 
  YOYO_BIGINT /*out*/ **rsa_priv, 
  YOYO_BIGINT /*out*/ **rsa_mod,
  int bits)
#ifdef _YOYO_BINGINT_BUILTIN
  {
    __Auto_Ptr(*rsa_mod)
      {
        YOYO_BIGINT *p, *q, *n, *phi;
        int pBits = Get_Random(bits/5,bits/2);
        int qBits = (bits+1)-pBits;
        int skip_primes = Get_Random(YOYO_PRIME_RSAPUBLIC_MIN,(YOYO_PRIME_RSAPUBLIC_MAX-YOYO_PRIME_RSAPUBLIC_MIN)/2);

        STRICT_REQUIRE(pBits < bits/2);
        STRICT_REQUIRE(pBits+qBits == bits+1);

        n = 0;
        while ( !n ) __Auto_Ptr(n)
          {
            Bigint_Generate_Rsa_PQ(&p,pBits,&q,qBits,&n);

            phi = Bigint_Mul(Bigint_Sub_Short(p,1),Bigint_Sub_Short(q,1));
            *rsa_pub = Bigint_Mutal_Prime(phi,bits/3);
            if ( !*rsa_pub ) n = 0;
            else
              {
                *rsa_priv  = Bigint_Invmod(*rsa_pub,phi);
                __Retain(*rsa_pub);
                __Retain(*rsa_priv);
                *rsa_mod = n;
              }
          }
      }
    
    __Pool(*rsa_pub);
    __Pool(*rsa_priv);
  }
#endif
  ;

#endif /* C_once_B4220D86_3019_4E13_8682_D7F809F4E829 */


