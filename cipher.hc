
/*

Copyright © 2010-2011, Alexéy Sudáchen, alexey@sudachen.name, Chile

In USA, UK, Japan and other countries allowing software patents:

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    http://www.gnu.org/licenses/

Otherwise:

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

#ifdef _LIBYOYO
#define _YOYO_CIPHER_BUILTIN
#endif

#include "yoyo.hc"
#include "md5.hc"
#include "sha2.hc"

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
      __Raise(YOYO_ERROR_NO_ENOUGH,__yoTa("data buffer to small",0));
    
    if ( S_len % 8 )
      __Raise(YOYO_ERROR_UNALIGNED,__yoTa("size of data buffer should be aligned to 8 bytes",0));
  }
#endif
  ;

void _Oj_Check_Buffer_Size_N_Alignment_16(int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    if ( S_len < 16 ) 
      __Raise(YOYO_ERROR_NO_ENOUGH,__yoTa("data buffer to small",0));
    
    if ( S_len % 16 )
      __Raise(YOYO_ERROR_UNALIGNED,__yoTa("size of data buffer should be aligned to 16 bytes",0));
  }
#endif
  ;

void _Oj_Encrypt_Decrypt_ECB_8(void *cipher, void (*f8)(void*,void*), void *S, int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i;
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        f8(cipher,p);
      }
  }
#endif
  ;

void _Oj_Encrypt_Decrypt_ECB_16(void *cipher, void (*f16)(void*,void*), void *S, int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i;
    
    _Oj_Check_Buffer_Size_N_Alignment_16(S_len);
    
    for ( i = 0; i < S_len/16; ++i )
      {
        byte_t *p = (byte_t*)S+i*16;
        f16(cipher,p);
      }
  }
#endif
  ;

void Oj_Encrypt_ECB(void *cipher, void *S, int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    void (*f)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Encrypt8_OjMID,0);
    
    if ( f )
      _Oj_Encrypt_Decrypt_ECB_8(cipher,f,S,S_len);
    else if ( 0 != (f = Yo_Find_Method_Of(&cipher,Oj_Encrypt16_OjMID,0)) )
      _Oj_Encrypt_Decrypt_ECB_16(cipher,f,S,S_len);
    else
      __Raise(YOYO_ERROR_METHOD_NOT_FOUND,
              __yoTa("cipher does not contain Oj_Encrypt8_OjMID or Oj_Encrypt16_OjMID mothod",0));
  }
#endif
  ;

void Oj_Decrypt_ECB(void *cipher, void *S, int S_len)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    void (*f)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Decrypt8_OjMID,0);
    
    if ( f )
      _Oj_Encrypt_Decrypt_ECB_8(cipher,f,S,S_len);
    else if ( 0 != (f = Yo_Find_Method_Of(&cipher,Oj_Decrypt16_OjMID,0)) )
      _Oj_Encrypt_Decrypt_ECB_16(cipher,f,S,S_len);
    else
      __Raise(YOYO_ERROR_METHOD_NOT_FOUND,
              __yoTa("cipher does not contain Oj_Decrypt8_OjMID or Oj_Decrypt16_OjMID mothod",0));
  }
#endif
  ;

quad_t _Oj_Encrypt_Decrypt_XEX_8(void *cipher, void (*f8)(void*,void*), void *cipher2, void (*xex)(void*,void*), void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i,j, n = xex?8:16;
    byte_t q16[16] = {0};
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        ++st;
        Quad_To_Eight(st,q16);
        
        if ( xex )
          xex(cipher2,q16);
        else
          Md5_Digest(q16,8,q16);
        
        for ( j = 0; j < n; ++j )
          p[j%8] ^= q16[j];
        f8(cipher,p);
        for ( j = 0; j < n; ++j )
          p[j%8] ^= q16[j];
      }
    
    return st;
  }
#endif
  ;

quad_t _Oj_Encrypt_Decrypt_XEX_16(void *cipher, void (*f16)(void*,void*), void *cipher2, void (*xex)(void*,void*), void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    int i,j, n = xex?16:32;
    byte_t q32[32] = {0};
    
    _Oj_Check_Buffer_Size_N_Alignment_16(S_len);
    
    for ( i = 0; i < S_len/16; ++i )
      {
        byte_t *p = (byte_t*)S+i*16;
        ++st;
        Quad_To_Eight(st,q32);
        ++st;
        Quad_To_Eight(st,q32+8);
        
        if ( xex )
          xex(cipher2,q32);
        else
          Sha2_Digest(q32,16,q32);
          
        for ( j = 0; j < n; ++j )
          p[j%16] ^= q32[j];
        f16(cipher,p);
        for ( j = 0; j < n; ++j )
          p[j%16] ^= q32[j];
      }
    
    return st;
  }
#endif
  ;

quad_t Oj_Encrypt_XEX_2(void *cipher, void *cipher2, void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    void (*encrypt)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Encrypt8_OjMID,0);
    if ( encrypt ) 
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_8(cipher,encrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt2)(void*,void*) = Yo_Find_Method_Of(&cipher2,Oj_Encrypt8_OjMID,YO_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_8(cipher,encrypt,cipher2,encrypt2,S,S_len,st);
          }
      }
    else if ( 0 != (encrypt = Yo_Find_Method_Of(&cipher,Oj_Encrypt16_OjMID,0)) ) 
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_16(cipher,encrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt2)(void*,void*) = Yo_Find_Method_Of(&cipher2,Oj_Encrypt16_OjMID,YO_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_16(cipher,encrypt,cipher2,encrypt2,S,S_len,st);
          }
      }
    else
      __Raise(YOYO_ERROR_METHOD_NOT_FOUND,
              __yoTa("cipher does not contain Oj_Encrypt8_OjMID or Oj_Encrypt16_OjMID mothod",0));
    return 0;
  }
#endif
  ;

quad_t Oj_Decrypt_XEX_2(void *cipher, void *cipher2, void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    void (*decrypt)(void*,void*) = Yo_Find_Method_Of(&cipher,Oj_Decrypt8_OjMID,0);
    if ( decrypt )
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_8(cipher,decrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt)(void*,void*) = Yo_Find_Method_Of(&cipher2,Oj_Encrypt8_OjMID,YO_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_8(cipher,decrypt,cipher2,encrypt,S,S_len,st);
          }
      }
    else if ( 0 != (decrypt = Yo_Find_Method_Of(&cipher,Oj_Decrypt16_OjMID,0)) )
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_16(cipher,decrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt)(void*,void*) = Yo_Find_Method_Of(&cipher2,Oj_Encrypt16_OjMID,YO_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_16(cipher,decrypt,cipher2,encrypt,S,S_len,st);
          }
      }
    else
      __Raise(YOYO_ERROR_METHOD_NOT_FOUND,
              __yoTa("cipher does not contain Oj_Decrypt8_OjMID or Oj_Decrypt16_OjMID mothod",0));
    return 0;
  }
#endif
  ;

quad_t Oj_Encrypt_XEX(void *cipher, void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    return Oj_Encrypt_XEX_2(cipher,cipher,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Decrypt_XEX(void *cipher, void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    return Oj_Decrypt_XEX_2(cipher,cipher,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Encrypt_XEX_MDSH(void *cipher, void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    return Oj_Decrypt_XEX_2(cipher,0,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Decrypt_XEX_MDSH(void *cipher, void *S, int S_len, quad_t st)
#ifdef _YOYO_CIPHER_BUILTIN
  {
    return Oj_Decrypt_XEX_2(cipher,0,S,S_len,st);
  }
#endif
  ;

#endif /* C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219 */

