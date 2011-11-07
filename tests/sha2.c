
#define _LIBYOYO
#include "../libyoyo.hc"
#include "../libcrypt.hc"

byte_t Data_Buf[3][57] = 
  {
    { "abc" },
    { "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" },
    { "" }
  };

int Data_Buflen[3] =
  {
    3, 56, 1000
  };

byte_t Data_Sum[6][32] =
  {
    /*
     * SHA-256 test vectors
     */
    { 0xBA, 0x78, 0x16, 0xBF, 0x8F, 0x01, 0xCF, 0xEA,
      0x41, 0x41, 0x40, 0xDE, 0x5D, 0xAE, 0x22, 0x23,
      0xB0, 0x03, 0x61, 0xA3, 0x96, 0x17, 0x7A, 0x9C,
      0xB4, 0x10, 0xFF, 0x61, 0xF2, 0x00, 0x15, 0xAD },
    { 0x24, 0x8D, 0x6A, 0x61, 0xD2, 0x06, 0x38, 0xB8,
      0xE5, 0xC0, 0x26, 0x93, 0x0C, 0x3E, 0x60, 0x39,
      0xA3, 0x3C, 0xE4, 0x59, 0x64, 0xFF, 0x21, 0x67,
      0xF6, 0xEC, 0xED, 0xD4, 0x19, 0xDB, 0x06, 0xC1 },
    { 0xCD, 0xC7, 0x6E, 0x5C, 0x99, 0x14, 0xFB, 0x92,
      0x81, 0xA1, 0xC7, 0xE2, 0x84, 0xD7, 0x3E, 0x67,
      0xF1, 0x80, 0x9A, 0x48, 0xA4, 0x97, 0x20, 0x0E,
      0x04, 0x6D, 0x39, 0xCC, 0xC7, 0x11, 0x2C, 0xD0 }
  };


int main(int argc, char **argv)
  {

    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);

    if ( Prog_Arguments_Count() )
      {
        YOYO_BUFFER *bf;
        byte_t sign[32] = {0};
        bf = Oj_Read_All(Cfile_Open(Prog_Argument(0),"r"));
        Sha2_Digest(bf->at,bf->count,sign);
        puts(Str_Hex_Encode(sign,32));
      }
    else
      {
        int i, j, buflen;
        byte_t buf[1000];
        int verbose = Prog_Has_Opt("l");
        YOYO_SHA2 ctx;
        
        for ( i = 0; i < 3; i++ )
          {
            if ( verbose )
                printf( "  SHA-2 test #%d: ", i + 1 );

            Sha2_Start( &ctx );

            if ( i == 2 )
              {
                  memset( buf, 'a', buflen = 1000 );

                  for ( j = 0; j < 1000; j++ )
                      Sha2_Update( &ctx, buf, buflen );
              }
            else
                Sha2_Update( &ctx,Data_Buf[i],
                                  Data_Buflen[i] );

            Sha2_Finish( &ctx, buf );

            if ( memcmp( buf,Data_Sum[i], 32 ) != 0 )
              {
                if ( verbose )
                    puts("failed");
                return 1;
              }
            else
              {
                if( verbose )
                    puts("passed");
              }
          }
      }
      
    return 0;
  }
