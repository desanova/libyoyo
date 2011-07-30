
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

#ifndef C_once_FF657866_8205_4CAE_9D01_65B8583E9D19
#define C_once_FF657866_8205_4CAE_9D01_65B8583E9D19

#include "core.hc"

#ifdef __windoze
# include <wincrypt.h>
# ifdef _MSC_VER
#  pragma comment(lib,"advapi32.lib")
# endif
#else
#endif

#define _YOYO_DEV_RANDOM "/dev/urandom"

#ifdef _YOYO_RANDOM_BUILTIN
#define _YOYO_RANDOM_EXTERN
#else
#define _YOYO_RANDOM_EXTERN extern
#endif

void System_Random(void *bits,int count /* of bytes*/ )
#ifdef _YOYO_RANDOM_BUILTIN
  {
  #ifndef __windoze
    int i, fd = open(_YOYO_DEV_RANDOM,O_RDONLY);
    if ( fd >= 0 )
      {
        for ( i = 0; i < count; )
          {
            int rd = read(fd,bits+i,count);
            if ( rd < 0 )
              {
                close(fd);
                Yo_Raise(YOYO_ERROR_IO,
                  _YOYO_DEV_RANDOM " does not have required data: failed to read",
                  __FILE__,__LINE__);
              }
            i += rd;
            count -= rd;
          }
        close(fd);
        return;
      }
    else
      goto simulate;
  #else
    typedef BOOL (__stdcall *tCryptAcquireContext)(HCRYPTPROV*,LPCTSTR,LPCTSTR,DWORD,DWORD);
    typedef BOOL (__stdcall *tCryptGenRandom)(HCRYPTPROV,DWORD,BYTE*);
    static tCryptAcquireContext fCryptAcquireContext = 0;
    static tCryptGenRandom fCryptGenRandom = 0;
    static HCRYPTPROV cp = 0;
    if ( !fCryptAcquireContext )
      {
        HMODULE hm = LoadLibraryA("advapi32.dll");
        fCryptAcquireContext = (tCryptAcquireContext)GetProcAddress(hm,"CryptAcquireContextA");
        fCryptGenRandom = (tCryptGenRandom)GetProcAddress(hm,"CryptGenRandom");
      }
    if ( !cp && !fCryptAcquireContext(&cp, 0, 0,PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) )
      goto simulate;
    if ( !fCryptGenRandom(cp,count,(unsigned char*)bits) )
      goto simulate;
    if ( count >= 4 && *(unsigned*)bits == 0 )
      goto simulate;
    return;
  #endif      
  simulate:
  #ifdef _STRICT
    Yo_Raise(YOYO_ERROR_IO,_YOYO_DEV_RANDOM " is not accessable",__Yo_FILE__,__LINE__);
  #else
    if ( 1 )
      {
        static uint_t sid = 0; 
        int i;
        
        if ( !sid ) sid = (uint_t)time(0);
        for ( i = 0; i < count; i+=4 )
          {
            sid = 1664525U * sid + 1013904223U;
            memcpy((char*)bits+i,&sid,Yo_MIN(count-i,4));
          }
      }
  #endif
  }
#endif
  ;

ulong_t Random_Bits(int no)
#ifdef _YOYO_RANDOM_BUILTIN
  {
    static byte_t bits[256] = {0};
    static int bits_count = 0;
    ulong_t r = 0;
    
    STRICT_REQUIRE( no > 0 && no <= sizeof(ulong_t)*8 );
    
    __Xchg_Interlock
      while ( no )
        {
          if ( !bits_count )
            {
              System_Random(bits,sizeof(bits));
              bits_count = sizeof(bits)*8;
            }
          no -= Bits_Pop(&r,bits,&bits_count,no);
        }

    return r;
  }
#endif
  ;

ulong_t Get_Random(unsigned min, unsigned max)
#ifdef _YOYO_RANDOM_BUILTIN
  {
    ulong_t r;
    int k = sizeof(r)*8/2;
    STRICT_REQUIRE(max > min);
    r = ((Random_Bits(k)*(max-min))>>k) + min;
    STRICT_REQUIRE(r >= min && r < max);
    return r;
  }
#endif
  ;
  
#endif /* C_once_FF657866_8205_4CAE_9D01_65B8583E9D19 */

