
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

#ifndef C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120
#define C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120

#include "core.hc"

/* string.hc */
char *Str_Hex_Byte(byte_t val,char pfx,void *out);

typedef struct _YOYO_BUFFER
  { 
    byte_t *at; 
    int count; 
  } YOYO_BUFFER;

void Buffer_Resize(YOYO_BUFFER *bf,int count)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( count < 0 )
      __Raise(YOYO_ERROR_OUT_OF_RANGE,0);
    
    if ( count < bf->count ) 
      bf->count = count;
    else
      {
        bf->at = Yo_Resize_Npl(bf->at,count+1,1);
        bf->count = count;
      }
    
    bf->at[bf->count] = 0;
  }
#endif
  ;

void Buffer_Append(YOYO_BUFFER *bf,void *S,int len)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( len < 0 ) /* appending C string */
      len = S?strlen(S):0;

    if ( len && S )
      {
        int capacity = Min_Pow2(bf->count+len+1);
        bf->at = Yo_Resize_Npl(bf->at,capacity,1);
        memcpy(bf->at+bf->count,S,len);
        bf->count += len;
        bf->at[bf->count] = 0;
      }
  }
#endif
  ;

void Buffer_Fill_Append(YOYO_BUFFER *bf,int c,int count)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    STRICT_REQUIRE( count >= 0 );

    if ( count > 0 )
      {
        int capacity = Min_Pow2(bf->count+count+1);
        bf->at = Yo_Resize_Npl(bf->at,capacity,1);
        memset(bf->at+bf->count,c,count);
        bf->count += count;
        bf->at[bf->count] = 0;
      }
  }
#endif
  ;

void Buffer_Printf(YOYO_BUFFER *bf, char *fmt, ...)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    int q, rq_len, capacity;
    va_list va;
    va_start(va,fmt);
    
    rq_len = Yo_Detect_Required_Buffer_Size(fmt,va)+1;
    capacity = Min_Pow2(bf->count+rq_len+1);
    bf->at = Yo_Resize_Npl(bf->at,capacity,1);
    
  #ifdef __windoze
    q = vsprintf(bf->at+bf->count,fmt,va);
  #else
    q = vsnprintf(bf->at+bf->count,rq_len,fmt,va);
  #endif
  
    if ( q >= 0 )
      bf->count += q;
    STRICT_REQUIRE(bf->count >= 0 && bf->count <= capacity);
  
    bf->at[bf->count] = 0;
  }
#endif
  ;

void Buffer_Hex_Append(YOYO_BUFFER *bf, void *S, int len)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( len < 0 ) /* appending C string */
      len = S?strlen(S):0;

    if ( len && S )
      {
        int i;
        int capacity = Min_Pow2(bf->count+len*2+1);
        bf->at = Yo_Resize_Npl(bf->at,capacity,1);
        
        for ( i = 0; i < len; ++i )
          Str_Hex_Byte( ((byte_t*)S)[i], 0, bf->at+bf->count+i*2 );

        bf->count += len*2;
        bf->at[bf->count] = 0;
      }
  }
#endif
  ;

void Buffer_Quote_Append(YOYO_BUFFER *bf, void *S, int len, int brk)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    byte_t *q = S;
    byte_t *p = q;
    byte_t *E;
    
    if ( len < 0 ) 
      len = S?strlen(S):0;
    
    E = p + len;
    
    while ( p != E )
      {
        do 
          { 
            if ( *p < 30 || *p == '\\' || *p == brk ) 
              break; 
            ++p; 
          } 
        while ( p != E );
        
        if ( q != p )
          Buffer_Append(bf,q,p-q);
        
        if ( p != E )
          {
            if ( *p == '\n' ) Buffer_Append(bf,"\\n",2);
            else if ( *p == '\t' ) Buffer_Append(bf,"\\t",2);
            else if ( *p == '\r' ) Buffer_Append(bf,"\\r",2);
            else if ( *p == '\\' ) Buffer_Append(bf,"\\\\",2);
            else if ( *p == brk )  
              { 
                Buffer_Fill_Append(bf,'\\',1);
                Buffer_Fill_Append(bf,brk,1);
              }
            else if ( *p == '"' ) Buffer_Append(bf,"\\\"",2);
            else if ( *p < 30 ) 
              {
                Buffer_Append(bf,"\\x",2);
                Buffer_Hex_Append(bf,p,1);
              }
          
            ++p;
          }
          
        q = p;
      }
  }
#endif
  ;

void Buffer_Html_Quote_Append(YOYO_BUFFER *bf, void *S, int len)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    byte_t *q = S;
    byte_t *p = q;
    byte_t *E;
    
    if ( len < 0 ) 
      len = S?strlen(S):0;
    
    E = p + len;
    
    while ( p != E )
      {
        do 
          { 
            if ( *p == '<' || *p == '>'  || *p == '&') 
              break; 
            ++p; 
          } 
        while ( p != E );
        
        if ( q != p )
          Buffer_Append(bf,q,p-q);
        
        if ( p != E )
          {
            if ( *p == '<' ) Buffer_Append(bf,"&lt;",4);
            else if ( *p == '>' ) Buffer_Append(bf,"&gt;",4);
            else if ( *p == '&' ) Buffer_Append(bf,"&amp;",5);
            ++p;
          }
          
        q = p;
      }
  }
#endif
  ;

void Buffer_Insert(YOYO_BUFFER *bf,int pos,void *S,int len)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    int capacity = Min_Pow2(bf->count+len+1);

    if ( len < 0 ) /* appending C string */
      len = S?strlen(S):0;

    if ( pos < 0 ) pos = bf->count + pos + 1;
    if ( pos < 0 || pos > bf->count ) 
      {
        Yo_Raise(YOYO_ERROR_OUT_OF_RANGE,0,__Yo_FILE__,__LINE__);
      }
    
    bf->at = Yo_Resize_Npl(bf->at,capacity,1);
    if ( pos < bf->count )
      memmove(bf->at+pos+len,bf->at+pos,bf->count-pos);
    memcpy(bf->at+pos,S,len);
    bf->count += len;
    bf->at[bf->count] = 0;
  }
#endif
  ;

#define Buffer_Take_Data(Bf) __Pool(Buffer_Take_Data_Npl(Bf))
void *Buffer_Take_Data_Npl(YOYO_BUFFER *bf)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    void *R = bf->at;
    bf->count = 0;
    bf->at = 0;
    return R;
  }
#endif
  ;
  
void *Buffer_Take_Data_Non(YOYO_BUFFER *bf)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    void *n = Buffer_Take_Data(bf);
    if ( !n ) 
      { 
        n = Yo_Malloc(1);
        *((char*)n) = 0;
      }
    return n;
  }
#endif
  ;
  
#define Buffer_COUNT(Bf)    ((int)((YOYO_BUFFER *)(Bf))->count+0)
#define Buffer_BEGIN(Bf)    (((YOYO_BUFFER *)(Bf))->at)
#define Buffer_END(Bf)      (Buffer_BEGIN(Bf)+Buffer_COUNT(Bf))

int Buffer_Count(YOYO_BUFFER *bf)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_COUNT(bf);
    return 0;
  }
#endif
  ;
  
void *Buffer_Begin(YOYO_BUFFER *bf)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_BEGIN(bf);
    return 0;
  }
#endif
  ;

void *Buffer_End(YOYO_BUFFER *bf)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_END(bf);
    return 0;
  }
#endif
  ;

void Buffer_Destruct(YOYO_BUFFER *bf)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( bf->at )
      free(bf->at);
    Yo_Object_Destruct(bf);
  }
#endif
  ;

void *Buffer_Init(int count)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    YOYO_BUFFER *bf = Yo_Object_Dtor(sizeof(YOYO_BUFFER),Buffer_Destruct);
    if ( count )
      Buffer_Resize(bf,count);
    return bf;
  }
#endif
  ;
  
void *Buffer_Zero(int count)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    YOYO_BUFFER *bf = Buffer_Init(count);
    if ( bf->count ) 
      memset(bf->at,0,bf->count);
    return bf;
  }
#endif
  ;

void *Buffer_Copy(void *S, int count)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    YOYO_BUFFER *bf = Buffer_Init(count);
    if ( count )
      memcpy(bf->at,S,count);
    return bf;
  }
#endif
  ;

#endif /* C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120 */

