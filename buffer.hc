
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

typedef struct _YOYO_BUFFER
  { 
    byte_t *at; 
    int count; 
  } YOYO_BUFFER;

void Buffer_Resize(YOYO_BUFFER *bf,int count)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    if ( count < 0 )
      Yo_Raise(YO_ERROR_OUT_OF_RANGE,0,__Yo_FILE__,__LINE__);
    
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
    if ( len < 0 )
      Yo_Raise(YO_ERROR_OUT_OF_RANGE,0,__Yo_FILE__,__LINE__);

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

void Buffer_Insert(YOYO_BUFFER *bf,int pos,void *S,int len)
#ifdef _YOYO_BUFFER_BUILTIN
  {
    int capacity = Min_Pow2(bf->count+len+1);

    if ( len < 0 )
      Yo_Raise(YO_ERROR_OUT_OF_RANGE,0,__Yo_FILE__,__LINE__);

    if ( pos < 0 ) pos = bf->count + pos + 1;
    if ( pos < 0 || pos > bf->count ) 
      {
        Yo_Raise(YO_ERROR_OUT_OF_RANGE,0,__Yo_FILE__,__LINE__);
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

void *Buffer_Take_Data(YOYO_BUFFER *bf)
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
    if ( bf->count ) memset(bf->at,0,bf->count);
    return bf;
  }
#endif
  ;

#endif /* C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120 */

