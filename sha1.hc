
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

The SHA-1 standard was published by NIST in 1993.
http://www.itl.nist.gov/fipspubs/fip180-1.htm

*/

#ifndef C_once_1B3E01E2_7457_494E_A17C_3A12388FC4AF
#define C_once_1B3E01E2_7457_494E_A17C_3A12388FC4AF

#include "core.hc"

typedef struct _YOYO_SHA1_SIGNER
  {
    uint_t state[5];   /* state (ABCDE) */
    uint_t count[2];   /* number of bits, modulo 2^64 (lsb first) */
    int    finished;
    byte_t buffer[64]; /* input buffer */
  } YOYO_SHA1_SIGNER;

void *Sha1_Clone(YOYO_SHA1_SIGNER *sha1)
#ifdef _YOYO_SHA1_BUILTIN
  {
    return Yo_Object_Clone(sizeof(YOYO_SHA1_SIGNER),sha1);
  }
#endif
  ;

void *Sha1_Init()
#ifdef _YOYO_SHA1_BUILTIN
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Clone_OjMID, Sha1_Clone },
        {0}};
    
    YOYO_SHA1_SIGNER *sha1 = Yo_Object(sizeof(YOYO_SHA1_SIGNER),funcs);

    sha1->state[0] = 0x67452301; 
    sha1->state[1] = 0xefcdab89; 
    sha1->state[2] = 0x98badcfe; 
    sha1->state[3] = 0x10325476;
    sha1->state[4] = 0xc3d2e1f0;

    return sha1;
  }
#endif
  ;

void Sha1_Update(YOYO_SHA1_SIGNER *sha1, void *data, int len);
void *Sha1_Finish(YOYO_SHA1_SIGNER *sha1, void *digest);

#define YOYO_SHA1_INITIALIZER {{0x67452301,0xefcdab89,0x98badcfe,0x10325476,0xc3d2e1f0},{0},0,{0}}

void *Sha1_Sign_Data(void *data, int len, void *digest)
#ifdef _YOYO_SHA1_BUILTIN
  {
    YOYO_SHA1_SIGNER sha1 = YOYO_SHA1_INITIALIZER;
    Sha1_Update(&sha1,data,len);
    return Sha1_Finish(&sha1,digest);
  }
#endif
  ;

void *Sha1_Sign_Sign_Data(void *data, int len, void *digest)
#ifdef _YOYO_SHA1_BUILTIN
  {
    byte_t tmp[20];
    YOYO_SHA1_SIGNER sha1 = YOYO_SHA1_INITIALIZER;
    Sha1_Sign_Data(data,len,tmp);
    Sha1_Update(&sha1,tmp,20);
    Sha1_Update(&sha1,data,len);
    return Sha1_Finish(&sha1,digest);
  }
#endif
  ;

#define Sha1_Digest_Of(Data,Len) Sha1_Sign_Data(Data,Len,0)

#ifdef _YOYO_SHA1_BUILTIN


#if 0
  #if defined _X86 || defined __i386 || defined __x86_64
    #define Sha1_Internal_Encode memcpy
    #define Sha1_Internal_Decode memcpy
  #else
    void Sha1_Internal_Encode(byte_t *output, uint_t *input, uint_t len) 
      {
        uint_t i, j;

        for (i = 0, j = 0; j < len; i++, j += 4) 
          {
            output[j]   = (byte_t)(input[i] & 0xff);
            output[j+1] = (byte_t)((input[i] >> 8) & 0xff);
            output[j+2] = (byte_t)((input[i] >> 16) & 0xff);
            output[j+3] = (byte_t)((input[i] >> 24) & 0xff);
          }
      }

    void Sha1_Internal_Decode(uint_t *output, byte_t *input, uint_t len)
      {
        uint_t i, j;

        for (i = 0, j = 0; j < len; i++, j += 4)
          output[i] = ((uint_t)input[j]) | (((uint_t)input[j+1]) << 8) |
            (((uint_t)input[j+2]) << 16) | (((uint_t)input[j+3]) << 24);
      }
  #endif

#else
    void Sha1_Internal_Encode(byte_t *output, uint_t *input, uint_t len) 
      {
        uint_t i, j;

        for (i = 0, j = 0; j < len; i++, j += 4) 
          {
            output[j+0] = (byte_t)(input[i] >> 24);
            output[j+1] = (byte_t)(input[i] >> 16);
            output[j+2] = (byte_t)(input[i] >> 8);
            output[j+3] = (byte_t)(input[i]);
          }
      }

    void Sha1_Internal_Decode(uint_t *output, byte_t *input, uint_t len)
      {
        uint_t i, j;
        for (i = 0, j = 0; j < len; i++, j += 4)
          output[i] = ((uint_t)input[j+3]) | (((uint_t)input[j+2]) << 8) |
            (((uint_t)input[j+1]) << 16) | (((uint_t)input[j+0]) << 24);
      }
#endif

  #define ROTATE_LEFT(x,n) (((x) << (n)) | ((x) >> (32-(n))))
  #define R(t) (x[t&0x0f] = ROTATE_LEFT( \
                      x[(t- 3)&0x0f] \
                    ^ x[(t- 8)&0x0f] \
                    ^ x[(t-14)&0x0f] \
                    ^ x[(t   )&0x0f], \
                    1 ))\

  #define F(x,y,z) (z ^ ( x & ( y ^z)))
  #define FF(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + F(b,c,d) + 0x5a827999u + q; b = ROTATE_LEFT(b,30)
  #define G(x,y,z) (x ^ y ^ z)
  #define GG(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + G(b,c,d) + 0x6ed9eba1u + q; b = ROTATE_LEFT(b,30)
  #define H(x,y,z) ((x & y) | (z & (x | y)))
  #define HH(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + H(b,c,d) + 0x8f1bbcdcu + q; b = ROTATE_LEFT(b,30)
  #define I(x,y,z) (x ^ y ^ z)
  #define II(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + I(b,c,d) + 0xca62c1d6u + q; b = ROTATE_LEFT(b,30)

  void Sha1_Internal_Transform(YOYO_SHA1_SIGNER *sha1, void *block)
    {
      uint_t *state = sha1->state;
      uint_t a = state[0], b = state[1], c = state[2], d = state[3], e = state[4], x[16];

      Sha1_Internal_Decode(x, block, 64);

      FF( a, b, c, d, e, x[0]  );
      FF( e, a, b, c, d, x[1]  );
      FF( d, e, a, b, c, x[2]  );
      FF( c, d, e, a, b, x[3]  );
      FF( b, c, d, e, a, x[4]  );
      FF( a, b, c, d, e, x[5]  );
      FF( e, a, b, c, d, x[6]  );
      FF( d, e, a, b, c, x[7]  );
      FF( c, d, e, a, b, x[8]  );
      FF( b, c, d, e, a, x[9]  );
      FF( a, b, c, d, e, x[10] );
      FF( e, a, b, c, d, x[11] );
      FF( d, e, a, b, c, x[12] );
      FF( c, d, e, a, b, x[13] );
      FF( b, c, d, e, a, x[14] );
      FF( a, b, c, d, e, x[15] );
      FF( e, a, b, c, d, R(16) );
      FF( d, e, a, b, c, R(17) );
      FF( c, d, e, a, b, R(18) );
      FF( b, c, d, e, a, R(19) );
      GG( a, b, c, d, e, R(20) );
      GG( e, a, b, c, d, R(21) );
      GG( d, e, a, b, c, R(22) );
      GG( c, d, e, a, b, R(23) );
      GG( b, c, d, e, a, R(24) );
      GG( a, b, c, d, e, R(25) );
      GG( e, a, b, c, d, R(26) );
      GG( d, e, a, b, c, R(27) );
      GG( c, d, e, a, b, R(28) );
      GG( b, c, d, e, a, R(29) );
      GG( a, b, c, d, e, R(30) );
      GG( e, a, b, c, d, R(31) );
      GG( d, e, a, b, c, R(32) );
      GG( c, d, e, a, b, R(33) );
      GG( b, c, d, e, a, R(34) );
      GG( a, b, c, d, e, R(35) );
      GG( e, a, b, c, d, R(36) );
      GG( d, e, a, b, c, R(37) );
      GG( c, d, e, a, b, R(38) );
      GG( b, c, d, e, a, R(39) );
      HH( a, b, c, d, e, R(40) );
      HH( e, a, b, c, d, R(41) );
      HH( d, e, a, b, c, R(42) );
      HH( c, d, e, a, b, R(43) );
      HH( b, c, d, e, a, R(44) );
      HH( a, b, c, d, e, R(45) );
      HH( e, a, b, c, d, R(46) );
      HH( d, e, a, b, c, R(47) );
      HH( c, d, e, a, b, R(48) );
      HH( b, c, d, e, a, R(49) );
      HH( a, b, c, d, e, R(50) );
      HH( e, a, b, c, d, R(51) );
      HH( d, e, a, b, c, R(52) );
      HH( c, d, e, a, b, R(53) );
      HH( b, c, d, e, a, R(54) );
      HH( a, b, c, d, e, R(55) );
      HH( e, a, b, c, d, R(56) );
      HH( d, e, a, b, c, R(57) );
      HH( c, d, e, a, b, R(58) );
      HH( b, c, d, e, a, R(59) );
      II( a, b, c, d, e, R(60) );
      II( e, a, b, c, d, R(61) );
      II( d, e, a, b, c, R(62) );
      II( c, d, e, a, b, R(63) );
      II( b, c, d, e, a, R(64) );
      II( a, b, c, d, e, R(65) );
      II( e, a, b, c, d, R(66) );
      II( d, e, a, b, c, R(67) );
      II( c, d, e, a, b, R(68) );
      II( b, c, d, e, a, R(69) );
      II( a, b, c, d, e, R(70) );
      II( e, a, b, c, d, R(71) );
      II( d, e, a, b, c, R(72) );
      II( c, d, e, a, b, R(73) );
      II( b, c, d, e, a, R(74) );
      II( a, b, c, d, e, R(75) );
      II( e, a, b, c, d, R(76) );
      II( d, e, a, b, c, R(77) );
      II( c, d, e, a, b, R(78) );
      II( b, c, d, e, a, R(79) );

      state[0] += a;
      state[1] += b;
      state[2] += c;
      state[3] += d;
      state[4] += e;

    }

  #undef R
  #undef F
  #undef G
  #undef H
  #undef I
  #undef ROTATE_LEFT
  #undef FF
  #undef GG
  #undef HH
  #undef II

  void Sha1_Update(YOYO_SHA1_SIGNER *sha1, void *input, int input_length)
    {      
      int i, index, partLen;
      uint_t *count = sha1->count;
      index = (uint_t)((count[0] >> 3) & 0x3F);
      if ((count[0] += ((uint_t)input_length << 3)) < ((uint_t)input_length << 3))
        count[1]++;
      count[1] += ((uint_t)input_length >> 29);
      partLen = 64 - index;

      if (input_length >= partLen) 
        {
          memcpy(&sha1->buffer[index], input, partLen);
          Sha1_Internal_Transform(sha1,sha1->buffer);
          for (i = partLen; i + 63 < input_length; i += 64)
            Sha1_Internal_Transform(sha1,&((byte_t*)input)[i]);
          index = 0;
        }
      else
        i = 0;
      memcpy(&sha1->buffer[index],&((byte_t*)input)[i],input_length-i);
    }

  void *Sha1_Finish(YOYO_SHA1_SIGNER *sha1, void *digest)
    {
      if ( !sha1->finished )
        {
          static byte_t PADDING[64] = {
            0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          };
          byte_t bits[8];
          uint_t index, padLen;
          Sha1_Internal_Encode(bits, sha1->count+1, 4);
          Sha1_Internal_Encode(bits+4, sha1->count, 4);
          index = (uint_t)((sha1->count[0] >> 3) & 0x3f);
          padLen = (index < 56) ? (56 - index) : (120 - index);
          Sha1_Update(sha1, PADDING, padLen);
          Sha1_Update(sha1, bits, 8);
          sha1->finished = 1;
        }
      if ( !digest ) digest = __Malloc(20);
      Sha1_Internal_Encode(digest, sha1->state, 20);
      return digest;
    }

#endif /* _YOYO_SHA1_BUILTIN */

#endif /* C_once_1B3E01E2_7457_494E_A17C_3A12388FC4AF */

