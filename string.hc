
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

#ifndef C_once_0ED387CD_668B_44C3_9D91_A6336A2F5F48
#define C_once_0ED387CD_668B_44C3_9D91_A6336A2F5F48

#include "core.hc"
#include "array.hc"

#ifdef _YOYO_STRING_BUILTIN
#define _YOYO_STRING_EXTERN
#else
#define _YOYO_STRING_EXTERN extern
#endif

int Str_Length(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
    return S ? strlen(S) : 0;
  }
#endif
  ;

char Str_Last(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
    int L = S ? strlen(S) : 0;
    return L ? S[L-1] : 0;
  }
#endif
  ;
  
#define Str_Copy(Str,Len) Yo_Pool(Str_Copy_Npl(Str,Len))
char *Str_Copy_Npl(char *S,int L)
#ifdef _YOYO_STRING_BUILTIN
  {
    char *p;
    if ( L < 0 ) L = S?strlen(S):0;
    p = Yo_Malloc_Npl(L+1);
    if ( L )
      memcpy(p,S,L);
    p[L] = 0;
    return p;
  }
#endif
  ;

#define Str_Unicode_Copy(Str,Len) Yo_Pool(Unicode_Copy_Npl(Str,Len))
wchar_t *Str_Unicode_Copy_Npl(wchar_t *S,int L)
#ifdef _YOYO_STRING_BUILTIN
  {
    wchar_t *p;
    if ( L < 0 ) L = S?wcslen(S):0;
    p = Yo_Malloc_Npl((L+1)*sizeof(wchar_t));
    if ( L )
      memcpy(p,S,L*sizeof(wchar_t));
    p[L] = 0;
    return p;
  }
#endif
  ;

char *Str_Split_Once_Into(char *S,char *delims,void *arr)
#ifdef _YOYO_STRING_BUILTIN
  {
    if ( delims )
      {
        char *d;
        int j = 0;
        for ( ; S[j]; ++j )
          for ( d = delims; *d; ++d )
            if ( S[j] == *d )
            goto l;
      l:
        Array_Push(arr,Str_Copy_Npl(S,j));
        return S[j] ? S+(j+1) : 0;
      }
    else // split by spaces
      {
        char *p = S, *q;
        while ( *p && isspace(*p) ) ++p;
        q = p;
        while ( *q && !isspace(*q) ) ++q;
        Array_Push(arr,Str_Copy_Npl(p,q-p));
        while ( *q && isspace(*q) ) ++q;
        return *q ? q : 0;
      }
  }
#endif
  ;

void *Str_Split_Once(char *S,char *delims)
#ifdef _YOYO_STRING_BUILTIN
  {
    YOYO_ARRAY *L = Array_Ptrs();
    if ( S )
      {
        S = Str_Split_Once_Into(S,delims,L);
        if ( S )
          Array_Push(L,Str_Copy_Npl(S,-1));
      }
    return L;
  }
#endif
  ;

void *Str_Split(char *S,char *delims)
#ifdef _YOYO_STRING_BUILTIN
  {
    YOYO_ARRAY *L = Array_Ptrs();
    while ( S )
      S = Str_Split_Once_Into(S,delims,L);
    return L;
  }
#endif
  ;

int Bits_Pop(ulong_t *r, void *b, int *bits_count, int count)
#ifdef _YOYO_STRING_BUILTIN
  {
  #if 1  
    byte_t const *bits = (byte_t const*)b;
    int bC = *bits_count - 1;
    int Q = Yo_MIN(count,bC+1);
    int r_count = Q;

    if ( bC < 0 ) return 0;
  
    while ( ((bC+1) &7) && Q )
      {
        *r = (*r << 1) | ((bits[bC/8] >> (bC%8))&1); 
        --bC; --Q;
      }
    
    while ( bC >= 0 && Q )
      if ( Q > 7 )
        {
          *r = ( *r << 8 ) | bits[bC/8];
          Q -= 8; bC -= 8;
        }
      else
        {
          *r = (*r << Q) | bits[bC/8] >> (8-Q);
          bC -= Q; Q = 0;
        }
      
    *bits_count = bC + 1;
    return r_count;
  #else
    int r_count = 0;
    byte_t *bits = (byte_t*)b;
    while ( count && *bits_count )
      {
        int q = *bits_count-1;
        *r = (*r << 1) | ((bits[q/8] >> (q%8))&1); 
        --*bits_count;
        --count;
        ++r_count;
      }
    return r_count;
  #endif
  }
#endif
  ;

void Bits_Push(ulong_t bits, void *b, int *bits_count, int count)
#ifdef _YOYO_STRING_BUILTIN
  {
    while ( count-- )
      {
        int q = *bits_count;
        byte_t *d = ((byte_t *)b+q/8);
        *d = (byte_t)(((bits&1) << (q%8)) | (*d&~(1<<(q%8))));
        ++*bits_count;
        bits >>= 1;
      }
  }
#endif
  ;

char *Str_Xbit_Encode(void *data, int count /*of bits*/, int BC, char *bit_table, char *out )
#ifdef _YOYO_STRING_BUILTIN
  {
    char *Q = out;
    ulong_t q = 0;
    if ( count%BC ) 
      {
        Bits_Pop(&q,data,&count,count%BC);
        *Q++ = bit_table[q];
      }
    while ( count )
      {
        q = 0;
        Bits_Pop(&q,data,&count,BC);
        *Q++ = bit_table[q];
      }
    return out;
  }
#endif
  ;

_YOYO_STRING_EXTERN char Str_5bit_Encoding_Table[] /* 32 */ 
#ifdef _YOYO_STRING_BUILTIN
  = "0123456789abcdefgjkmnpqrstuvwxyz"
#endif
  ;
  
_YOYO_STRING_EXTERN char Str_5bit_Encoding_Table_Upper[] /* 32 */ 
#ifdef _YOYO_STRING_BUILTIN
  = "0123456789ABCDEFGJKMNPQRSTUVWXYZ"
#endif
  ;

_YOYO_STRING_EXTERN char Str_6bit_Encoding_Table[] /* 64 */ 
#ifdef _YOYO_STRING_BUILTIN
  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"
#endif
  ;

char *Str_5bit_Encode(void *data,int len)
#ifdef _YOYO_STRING_BUILTIN
  {
    if ( data && len )
      {
        int rq_len = (len*8+4)/5;
        char *out = Yo_Malloc(rq_len+1);
        memset(out,0,rq_len+1);
        return Str_Xbit_Encode(data,len*8,5,Str_5bit_Encoding_Table,out);
      }
    return 0;
  }
#endif
  ;

void *Str_Xbit_Decode(char *inS, int len, int BC, byte_t *bit_table, void *out)
#ifdef _YOYO_STRING_BUILTIN
  {
    int count = 0;
    byte_t *S = ((byte_t*)inS+len)-1, *E = (byte_t*)inS-1;
    while ( S != E )
      {
        byte_t bits = bit_table[*S--];
        if ( bits == 255 )
          __Raise(YOYO_ERROR_CORRUPTED,
            __Format(__yoTa("bad symbol '%c' in encoded sequence",0),S[1]));
        Bits_Push(bits,out,&count,BC);
      }
    return out;
  }
#endif
  ;

_YOYO_STRING_EXTERN byte_t Str_5bit_Decoding_Table[] /* 32 */ 
#ifdef _YOYO_STRING_BUILTIN
= {
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9,255,255,255,255,255,255,
    255, 10, 11, 12, 13, 14, 15, 16,255,255, 17, 18,255, 19, 20,255,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,255,255,255,255,255,
    255, 10, 11, 12, 13, 14, 15, 16,255,255, 17, 18,255, 19, 20,255,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
  }
#endif
  ;

void *Str_5bit_Decode(char *S,int *len)
#ifdef _YOYO_STRING_BUILTIN
  {
    int S_len = S ? strlen(S): 0;
    int rq_len = S_len ? (S_len*5+7)/8 : 0;
    
    if ( rq_len )
      {
        void *out = Yo_Malloc(rq_len);
        memset(out,0,rq_len);
        Str_Xbit_Decode(S,S_len,5,Str_5bit_Decoding_Table,out);
        if ( len ) *len = rq_len;
        return out;
      }
    
    return 0;
  }
#endif
  ;

char *Str_Hex_Byte(byte_t val,char pfx,void *out)
#ifdef _YOYO_STRING_BUILTIN
  {
    static char symbols[] = 
      { '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' };
    char *q = out;
    switch ( pfx )
      {
        case 'x': *q++='0'; *q++='x'; break;
        case '\\': *q++='\\'; *q++='x'; break;
        case '%': *q++='%'; break; 
        default: break;
      }
    *q++ = symbols[(val>>4)];
    *q++ = symbols[val&0x0f];
    *q = 0;
    return out;
  }
#endif
  ;

char *Str_Hex_Encode(void *data, int len)
#ifdef _YOYO_STRING_BUILTIN
  {
    if ( data && len )
      {
        int i;
        int rq_len = len*2;
        char *out = Yo_Malloc(rq_len+1);
        memset(out,0,rq_len+1);
        for ( i = 0; i < len; ++i )
          Str_Hex_Byte(((byte_t*)data)[i],0,out+i*2);
        return out;
      }
    return 0;
  }
#endif
  ;

#define Str_Unhex_Half_Octet(c,r,i) \
          if ( *c >= '0' && *c <= '9' ) \
            r |= (*c-'0') << i; \
          else if ( *c >= 'a' && *c <= 'f' ) \
            r |= (*c-'a'+10) << i; \
          else if ( *c >= 'A' && *c <= 'F' ) \
            r |= (*c-'A'+10) << i; \

byte_t Str_Unhex_Byte(char *S,int pfx,int *cnt)
#ifdef _YOYO_STRING_BUILTIN
  {
    int i;
    byte_t r = 0;
    byte_t *c = (byte_t*)S;
    if ( pfx )
      {
        if ( *c == '0' && c[1] == 'x' ) c+=2;
        else if ( *c == '\\' && c[1] == 'x' ) c+=2;
        else if ( *c == '%' ) ++c;
      }
    for ( i=4; i >= 0; i-=4, ++c )
      {
        Str_Unhex_Half_Octet(c,r,i);
      }
    if ( cnt ) *cnt = c-(byte_t*)S;
    return r;
  }
#endif
  ;

void *Str_Hex_Decode(char *S,int *len)
#ifdef _YOYO_STRING_BUILTIN
  {
    int S_len = S ? strlen(S): 0;
    int rq_len = S_len ? S_len/2 : 0;
    
    if ( rq_len )
      {
        int i;
        byte_t *out = Yo_Malloc(rq_len);
        for ( i = 0; i < rq_len; ++i )
          out[i] = Str_Unhex_Byte(S+i*2,0,0);
        if ( len ) *len = rq_len;
        return out;
      }
    
    return 0;
  }
#endif
  ;

void Unsigned_To_Hex8(uint_t val,char *out)
#ifdef _YOYO_STRING_BUILTIN
  {
    int i;
    for ( i = 0; i < 4; ++i )
      Str_Hex_Byte((byte_t)(val>>(i*8)),0,out+i*2);
  }
#endif
  ;

uint_t Hex8_To_Unsigned(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
    uint_t ret = 0;
    int i;
    for ( i = 0; i < 4; ++i )
      ret |= ( (uint_t)Str_Unhex_Byte(S+i*2,0,0) << (i*8) );
    return ret;
  }
#endif
  ;

_YOYO_STRING_EXTERN char Utf8_Char_Length[] 
#ifdef _YOYO_STRING_BUILTIN
  = {
    /* Map UTF-8 encoded prefix byte to sequence length.  zero means
       illegal prefix.  see RFC 2279 for details */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 0, 0
  }
#endif
  ;

wchar_t Utf8_Char_Decode(void *S,int *cnt)
#ifdef _YOYO_STRING_BUILTIN
  {
    byte_t *text = S;
    int c = -1;
    int c0 = *text++; if ( cnt ) ++*cnt;
    if (c0 < 0x80) 
      c = (wchar_t)c0;
    else
      {
        int c1 = 0;
        int c2 = 0;
        int c3 = 0;
        int l = Utf8_Char_Length[c0];
        switch ( l )
          {
            case 2:
              if ( (c1 = *text) > 0 )
                c = ((c0 & 0x1f) << 6) + (c1 & 0x3f);
              if ( cnt ) ++*cnt;
              break;
            case 3:
              if ( (c1 = *text) > 0 && (c2 = text[1]) > 0 )
                c = ((c0 & 0x0f) << 12) + ((c1 & 0x3f) << 6) + (c2 & 0x3f);
              if ( cnt ) *cnt += 2;
              break;
            case 4: // hm, UCS4 ????
              if ( (c1 = *text) > 0 && (c2 = text[1]) > 0 && (c3 = text[2]) > 0 )
                c = ((c0 & 0x7) << 18) + ((c1 & 0x3f) << 12) + ((c2 & 0x3f) << 6) + (c3 & 0x3f);
              if ( cnt ) *cnt += 3;
              break;
            default:
              break;
          }
      }
    return c;
  }
#endif
  ;

int Utf8_Wide_Length(wchar_t c)
#ifdef _YOYO_STRING_BUILTIN
  {
    if ( c < 0x80 ) 
      return 1; 
    else if ( c < 0x0800 )
      return 2;
    else
      return 3;
    return 0;
  }
#endif
  ;

char *Utf8_Wide_Encode(void *_bf,wchar_t c,int *cnt)
#ifdef _YOYO_STRING_BUILTIN
  {
    char *bf = _bf;
    int l = 0;
    if ( c < 0x80 ) 
      { 
        *bf++ = (char)c; 
        l = 1; 
      }
    else if ( c < 0x0800 )
      {
        *bf++ = (char)(0xc0 | (c >> 6));
        *bf++ = (char)(0x80 | (c & 0x3f));
        l = 2;
      }
    else
      {
        *bf++ = (char)(0xe0 | (c >> 12));
        *bf++ = (char)(0x80 | ((c >> 6) & 0x3f));
        *bf++ = (char)(0x80 | (c & 0x3f));
        l = 3;
      }
    if ( cnt ) *cnt += l;
    return bf;
  }
#endif
  ;

wchar_t Utf8_Get_Wide(char **S)
#ifdef _YOYO_STRING_BUILTIN
  {
    wchar_t out = 0;
    if ( S && *S )
      {
        int cnt = 0;
        out = Utf8_Char_Decode(*S,&cnt);
        while( **S && cnt-- ) ++*S;
      }
    return out;
  }
#endif
  ;

char *Utf8_Skip(char *S,int l)
#ifdef _YOYO_STRING_BUILTIN
  {
    if ( S )
      while ( *S && l-- )
        {
          int q = Utf8_Char_Length[(unsigned)*S]; 
          if ( q ) while ( q-- && *S ) ++S;
          else ++S;
        }
    return S;
  }
#endif
  ;

#define Str_Utf8_To_Unicode(S) Yo_Pool(Str_Utf8_To_Unicode_Npl(S))
wchar_t *Str_Utf8_To_Unicode_Npl(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
    wchar_t *out = 0;
    if ( S )
      {
        int n = 0;
        char *Q = S;
        while( *Q ) { Utf8_Get_Wide(&Q); ++n; }
        out = Yo_Malloc_Npl((n+1)*sizeof(wchar_t));
        for( n = 0; *S; ) { out[n++] = Utf8_Get_Wide(&S); }
        out[n] = 0;
      }
    return out;
  }
#endif
  ;

#define Str_Unicode_To_Utf8(S) Yo_Pool(Str_Unicode_To_Utf8_Npl(S))  
char *Str_Unicode_To_Utf8_Npl(wchar_t *S)
#ifdef _YOYO_STRING_BUILTIN
  {
    char *out = 0;
    if ( S )
      {
        int n = 0;
        wchar_t *Q = S;
        while ( *Q )
          n += Utf8_Wide_Length(*Q++); 
        out = Yo_Malloc_Npl(n+1);
        for ( n = 0; *S; )
          Utf8_Wide_Encode(out+n,*S++,&n);
        out[n] = 0;
      }
    return out;
  }
#endif
  ;

#define Str_Concat(A,B) Yo_Pool(Str_Concat_Npl(A,B))
char *Str_Concat_Npl(char *a, char *b)
#ifdef _YOYO_STRING_BUILTIN
  {
    int a_len = a?strlen(a):0;
    int b_len = b?strlen(b):0;
    char *out = Yo_Malloc_Npl(a_len+b_len+1);
    if ( a_len )
      memcpy(out,a,a_len);
    if ( b_len )
      memcpy(out+a_len,b,b_len);
    out[a_len+b_len] = 0;
    return out;
  }
#endif
  ;

char *Str_Join_Va_Npl(char sep, va_list va)
#ifdef _YOYO_STRING_BUILTIN
  {
    int len = 0;
    char *q, *out = 0;
    va_list va2;
#ifdef __GNUC__
    va_copy(va2,va);
#else
    va2 = va;
#endif
    while ( !!(q = va_arg(va2,char *)) )
      len += strlen(q)+(sep?1:0);
    if ( len )
      {
        char *Q = out = Yo_Malloc_Npl(len+(sep?0:1));
        while ( !!(q = va_arg(va,char *)) )
          {
            int len = strlen(q);
            if ( sep && Q != out )
              *Q++ = sep;
            memcpy(Q,q,len);
            Q += len;
          }
        *Q = 0;
      }
    else
      {
        out = Yo_Malloc_Npl(1);
        *out = 0;
      }
    return out;
  }
#endif
  ;

char *Str_Join_Npl_(char sep, ...)
#ifdef _YOYO_STRING_BUILTIN
  {
    char *out;
    va_list va;
    va_start(va,sep);
    out = Str_Join_Va_Npl(sep,va);
    va_end(va);
    return out;
  }
#endif
  ;
  
#define Str_Join_Npl_2(Sep,S1,S2) Str_Join_Npl_(Sep,S1,S2,0)
#define Str_Join_Npl_3(Sep,S1,S2,S3) Str_Join_Npl_(Sep,S1,S2,S3,0)
#define Str_Join_Npl_4(Sep,S1,S2,S3,S4) Str_Join_Npl_(Sep,S1,S2,S3,S4,0)
#define Str_Join_Npl_5(Sep,S1,S2,S3,S4,S5) Str_Join_Npl_(Sep,S1,S2,S3,S4,S5,0)
#define Str_Join_Npl_6(Sep,S1,S2,S3,S4,S5,S6) Str_Join_Npl_(Sep,S1,S2,S3,S4,S5,S6,0)

char *Str_Join_(char sep, ...)
#ifdef _YOYO_STRING_BUILTIN
  {
    char *out;
    va_list va;
    va_start(va,sep);
    out = Yo_Pool(Str_Join_Va_Npl(sep,va));
    va_end(va);
    return out;
  }
#endif
  ;

#define Str_Join_2(Sep,S1,S2) Str_Join_(Sep,S1,S2,0)
#define Str_Join_3(Sep,S1,S2,S3) Str_Join_(Sep,S1,S2,S3,0)
#define Str_Join_4(Sep,S1,S2,S3,S4) Str_Join_(Sep,S1,S2,S3,S4,0)
#define Str_Join_5(Sep,S1,S2,S3,S4,S5) Str_Join_(Sep,S1,S2,S3,S4,S5,0)
#define Str_Join_6(Sep,S1,S2,S3,S4,S5,S6) Str_Join_(Sep,S1,S2,S3,S4,S5,S6,0)

int Str_Starts_With(char *S, char *pat)
#ifdef _YOYO_STRING_BUILTIN
  {
    while ( *pat )
      if ( *S++ != *pat++ )
        return 0;
    return 1;
  }
#endif
  ;

int Str_Unicode_Starts_With(wchar_t *S, wchar_t *pat)
#ifdef _YOYO_STRING_BUILTIN
  {
    while ( *pat )
      if ( *S++ != *pat++ )
        return 0;
    return 1;
  }
#endif
  ;

char *Str_From_Int(int value, int base)
#ifdef _YOYO_STRING_BUILTIN
  {
  }
#endif
  ;

char *Str_From_Flt(double value, int perc)
#ifdef _YOYO_STRING_BUILTIN
  {
  }
#endif
  ;

int Str_To_Bool(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
  }
#endif
  ;

int Str_To_Int(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
  }
#endif
  ;

int Str_To_Flt(char *S)
#ifdef _YOYO_STRING_BUILTIN
  {
  }
#endif
  ;

int Str_Icmp(char *cs, char *ct, int count)
#ifdef _YOYO_STRING_BUILTIN
  {
    if (count <= 0)
      return 0;
      
    do 
      {
        if (tolower(*cs) != tolower(*ct++))
          return 0;
        if (*cs++ == 0)
          break;
      } while (--count != 0);

    return 1;
  }    
#endif
  ;


enum 
  {
    YOYO_BOM_DOESNT_PRESENT = 0,
    YOYO_BOM_UTF16_LE = 1,
    YOYO_BOM_UTF16_BE = 2,
    YOYO_BOM_UTF8 = 3,
  };

int Str_Find_BOM(void *S)
#ifdef _YOYO_STRING_BUILTIN
  {
    if ( *(byte_t*)S == 0x0ff && ((byte_t*)S)[1] == 0x0fe )
      return YOYO_BOM_UTF16_LE;
    if ( *(byte_t*)S == 0x0fe && ((byte_t*)S)[1] == 0x0ff )
      return YOYO_BOM_UTF16_BE;
    if ( *(byte_t*)S == 0x0ef && ((byte_t*)S)[1] == 0x0bb && ((byte_t*)S)[1] == 0x0bf )
      return YOYO_BOM_UTF8;
    return YOYO_BOM_DOESNT_PRESENT;
  }
#endif
  ;

#endif /* C_once_0ED387CD_668B_44C3_9D91_A6336A2F5F48 */

