
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

#ifndef C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219
#define C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219

#include "core.hc"

#ifdef _YOYO_CIPHER_BUILTIN
# define _YOYO_CIPHER_BUILTIN_CODE(Code) Code
# define _YOYO_CIPHER_EXTERN 
#else
# define _YOYO_CIPHER_BUILTIN_CODE(Code)
# define _YOYO_CIPHER_EXTERN extern 
#endif

_YOYO_CIPHER_EXTERN char Oj_Encrypt8_OjMID[] _YOYO_CIPHER_BUILTIN_CODE ( = "encrypt8/@*" );
_YOYO_CIPHER_EXTERN char Oj_Decrypt8_OjMID[] _YOYO_CIPHER_BUILTIN_CODE ( = "decrypt8/@*" );
_YOYO_CIPHER_EXTERN char Oj_Encrypt16_OjMID[] _YOYO_CIPHER_BUILTIN_CODE ( = "encrypt16/@*" );
_YOYO_CIPHER_EXTERN char Oj_Decrypt16_OjMID[] _YOYO_CIPHER_BUILTIN_CODE ( = "decrypt16/@*" );

void Oj_Encrypt8(void *cipher,void *block8) _YOYO_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))Yo_Find_Method_Of(cipher,Oj_Encrypt8_OjMID,YO_RAISE_ERROR))
        (cipher,block8); });

void Oj_Decrypt8(void *cipher,void *block8) _YOYO_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))Yo_Find_Method_Of(cipher,Oj_Decrypt8_OjMID,YO_RAISE_ERROR))
        (cipher,block8); });
        
void Oj_Encrypt16(void *cipher,void *block16) _YOYO_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))Yo_Find_Method_Of(cipher,Oj_Encrypt16_OjMID,YO_RAISE_ERROR))
        (cipher,block16); });

void Oj_Decrypt16(void *cipher,void *block16) _YOYO_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))Yo_Find_Method_Of(cipher,Oj_Decrypt16_OjMID,YO_RAISE_ERROR))
        (cipher,block16); });

void _Oj_Check_Buffer_Size_N_Alignment_8(int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    if ( S_len < 8 ) 
      Yo_Raise(YOYO_ERROR_NO_ENOUGH,"data buffer to small",__Yo_FILE__,__LINE__);
    
    if ( S_len % 8 )
      Yo_Raise(YOYO_ERROR_UNALIGNED,"data buffer should be aligned to 8 bytes",__Yo_FILE__,__LINE__);
  }
#endif
  ;

void Oj_Encrypt_ECB(void *cipher, void *S, int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i;
    void (*encrypt8)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Encrypt8_OjMID,YO_RAISE_ERROR);
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        encrypt8(cipher,p);
      }
  }
#endif
  ;

void Oj_Encrypt_CBC(void *cipher, void *S, int S_len, void *old8_)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i,j;
    byte_t *old8 = old8_;
    void (*encrypt8)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Encrypt8_OjMID,YO_RAISE_ERROR);
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        if ( old8 )
          for ( j = 0; j < 8; ++j )
            p[j] ^= old8[j];
        encrypt8(cipher,p);
        old8 = p;
      }
      
    if ( old8_ )
      memcpy(old8_,old8,8);
  }
#endif
  ;

void Oj_Decrypt_ECB(void *cipher, void *S, int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i;
    void (*decrypt8)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Decrypt8_OjMID,YO_RAISE_ERROR);
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);

    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        decrypt8(cipher,p);
      }
  }
#endif
  ;

void Oj_Decrypt_CBC(void *cipher, void *S, int S_len, void *old8)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i,j;
    void (*decrypt8)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Decrypt8_OjMID,YO_RAISE_ERROR);

    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    if ( !old8 ) old8 = alloca(8);

    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t bf[8];
        byte_t *p = (byte_t*)S+i*8;
        memcpy(bf,p,8);
        decrypt8(cipher,p);
        for ( j = 0; j < 8; ++j )
          p[j] ^= ((byte_t*)old8)[j];
        memcpy(old8,bf,8);
      }
  }
#endif
  ;

#endif /* C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219 */

