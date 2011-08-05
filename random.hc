
/*

(C)2010-2011, Alexéy Sudáchen, alexey@sudachen.name

Permission is hereby granted, free of charge, to any person ornd_bcontaining a copy
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
#include "sha2.hc"
#include "md5.hc"

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

void Soft_Random(byte_t *bits, int count)
#ifdef _YOYO_RANDOM_BUILTIN
  {
    static uquad_t rnd_ct[4] = {0};
    static byte_t rnd_bits[32] = {0}; 
    static int rnd_bcont = 0;
    static int initialized = 0;
    __Xchg_Interlock
      {
        if ( !initialized )
          {
            rnd_ct[0] = ((quad_t)getpid() << 48 ) | (quad_t)time(0);
            rnd_ct[1] = 0;
            rnd_ct[2] = 0;
            rnd_ct[3] = (longptr_t)&bits;
            initialized = 1;
          }
          
        while ( count )
          {
            if ( !rnd_bcont )
              {
                rnd_ct[1] = clock();
              #ifdef _SOFTRND_ADDENTRPY  
                rnd_ct[2] = (*(quad_t*)((byte_t*)&count - 256) ^  *(quad_t*)((byte_t*)&count + 256)) + 1;
              #else
                rnd_ct[2] = (quad_t)count ^ (longptr_t)bits;
              #endif
                Md5_Digest(rnd_ct,64,rnd_bits);
                ++rnd_ct[3];
                Md5_Digest(rnd_ct,64,rnd_bits+16);
                ++rnd_ct[3];
                rnd_bcont = 32;
              }
            *bits++ = rnd_bits[--rnd_bcont];
            --count;
          }
      }
  }
#endif
  ;
  
void System_Random(void *bits,int count /* of bytes*/ )
#ifdef _YOYO_RANDOM_BUILTIN
  {
  #ifdef _SOFTRND
    goto simulate;
  #elif !defined __windoze
    int i, fd = open(_YOYO_DEV_RANDOM,O_RDONLY|O_NONBLOCK);
    if ( fd >= 0 )
      {
        for ( i = 0; i < count; )
          {
            int rd = read(fd,bits+i,count-i);
            if ( rd < 0 )
              {
                if ( rd == EAGAIN )
                  {
                    Soft_Random(bits+i,count-i);
                    break;
                  }
                else
                  {
                    char *err = strerror(errno);
                    close(fd);
                    __Raise_Format(YOYO_ERROR_IO,
                      (_YOYO_DEV_RANDOM " does not have required data: %s",err));
                  }
              }
            i += rd;
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
    Soft_Random(bits,count);
  }
#endif
  ;

ulong_t Random_Bits(int no)
#ifdef _YOYO_RANDOM_BUILTIN
  {
    static byte_t bits[128] = {0};
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

