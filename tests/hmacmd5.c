
#define _LIBYOYO
#include "../libyoyo.hc"
#include "../libcrypt.hc"

/*
 * RFC 2202 test vectors
 */
byte_t Data_Key[7][26] =
  {
    { "\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B\x0B" },
    { "Jefe" },
    { "\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA\xAA" },
    { "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10"
      "\x11\x12\x13\x14\x15\x16\x17\x18\x19" },
    { "\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C" },
    { "" }, /* 0xAA 80 times */
    { "" }
  };

int Data_Keylen[7] =
  {
    16, 4, 16, 25, 16, 80, 80
  };

byte_t Data_Buf[7][74] =
  {
    { "Hi There" },
    { "what do ya want for nothing?" },
    { "\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD"
      "\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD"
      "\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD"
      "\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD"
      "\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD\xDD" },
    { "\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD"
      "\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD"
      "\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD"
      "\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD"
      "\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD" },
    { "Test With Truncation" },
    { "Test Using Larger Than Block-Size Key - Hash Key First" },
    { "Test Using Larger Than Block-Size Key and Larger"
      " Than One Block-Size Data" }
  };

int Data_Buflen[7] =
  {
    8, 28, 50, 50, 20, 54, 73
  };

byte_t Data_Sum[7][16] =
  {
    { 0x92, 0x94, 0x72, 0x7A, 0x36, 0x38, 0xBB, 0x1C,
      0x13, 0xF4, 0x8E, 0xF8, 0x15, 0x8B, 0xFC, 0x9D },
    { 0x75, 0x0C, 0x78, 0x3E, 0x6A, 0xB0, 0xB5, 0x03,
      0xEA, 0xA8, 0x6E, 0x31, 0x0A, 0x5D, 0xB7, 0x38 },
    { 0x56, 0xBE, 0x34, 0x52, 0x1D, 0x14, 0x4C, 0x88,
      0xDB, 0xB8, 0xC7, 0x33, 0xF0, 0xE8, 0xB3, 0xF6 },
    { 0x69, 0x7E, 0xAF, 0x0A, 0xCA, 0x3A, 0x3A, 0xEA,
      0x3A, 0x75, 0x16, 0x47, 0x46, 0xFF, 0xAA, 0x79 },
    { 0x56, 0x46, 0x1E, 0xF2, 0x34, 0x2E, 0xDC, 0x00,
      0xF9, 0xBA, 0xB9, 0x95 },
    { 0x6B, 0x1A, 0xB7, 0xFE, 0x4B, 0xD7, 0xBF, 0x8F,
      0x0B, 0x62, 0xE6, 0xCE, 0x61, 0xB9, 0xD0, 0xCD },
    { 0x6F, 0x63, 0x0F, 0xAD, 0x67, 0xCD, 0xA0, 0xEE,
      0x1F, 0xB1, 0xF5, 0x62, 0xDB, 0x3A, 0xA5, 0x3E }
  };


int main(int argc, char **argv)
  {
    byte_t buf[80];
    int i, verbose, buflen;
    YOYO_HMAC_MD5 ctx;
    
    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);
    
    verbose = Prog_Has_Opt("l");
    
    for( i = 0; i < 7; i++ )
      {
        if( verbose )
            printf( "  HMAC-MD5 test #%d: ", i + 1 );

        if( i == 5 || i == 6 )
          {
            memset( buf, '\xAA', buflen = 80 );
            Hmac_Md5_Start( &ctx, buf, buflen );
          }
        else
            Hmac_Md5_Start( &ctx, Data_Key[i],
                                  Data_Keylen[i] );

        Hmac_Md5_Update( &ctx, Data_Buf[i],
                               Data_Buflen[i] );

        Hmac_Md5_Finish( &ctx, buf );

        buflen = ( i == 4 ) ? 12 : 16;

        if( memcmp( buf, Data_Sum[i], buflen ) != 0 )
          {
            if( verbose )
                puts("failed");
            return 1;
          }
        else
          {
            if( verbose )
              puts("passed");
          }
      }
      
    return 0;
  }

