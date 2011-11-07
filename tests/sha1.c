
#define _LIBYOYO
#include "../libyoyo.hc"
#include "../libcrypt.hc"

/*
 * FIPS-180-1 test vectors
 */
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

byte_t Data_Sum[3][20] =
{
    { 0xA9, 0x99, 0x3E, 0x36, 0x47, 0x06, 0x81, 0x6A, 0xBA, 0x3E,
      0x25, 0x71, 0x78, 0x50, 0xC2, 0x6C, 0x9C, 0xD0, 0xD8, 0x9D },
    { 0x84, 0x98, 0x3E, 0x44, 0x1C, 0x3B, 0xD2, 0x6E, 0xBA, 0xAE,
      0x4A, 0xA1, 0xF9, 0x51, 0x29, 0xE5, 0xE5, 0x46, 0x70, 0xF1 },
    { 0x34, 0xAA, 0x97, 0x3C, 0xD4, 0xC4, 0xDA, 0xA4, 0xF6, 0x1E,
      0xEB, 0x2B, 0xDB, 0xAD, 0x27, 0x31, 0x65, 0x34, 0x01, 0x6F }
};

int main(int argc, char **argv)
  {

    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);

    if ( Prog_Arguments_Count() )
      {
        YOYO_BUFFER *bf;
        byte_t sign[20] = {0};
        bf = Oj_Read_All(Cfile_Open(Prog_Argument(0),"r"));
        Sha1_Digest(bf->at,bf->count,sign);
        puts(Str_Hex_Encode(sign,20));
      }
    else
      {
        int i, j, buflen;
        byte_t buf[1000];
        int verbose = Prog_Has_Opt("l");
        YOYO_SHA1 ctx;
        
        for ( i = 0; i < 3; i++ )
          {
            if ( verbose )
                printf( "  SHA-1 test #%d: ", i + 1 );

            Sha1_Start( &ctx );

            if ( i == 2 )
              {
                  memset( buf, 'a', buflen = 1000 );

                  for ( j = 0; j < 1000; j++ )
                      Sha1_Update( &ctx, buf, buflen );
              }
            else
                Sha1_Update( &ctx,Data_Buf[i],
                                  Data_Buflen[i] );

            Sha1_Finish( &ctx, buf );

            if ( memcmp( buf,Data_Sum[i], 20 ) != 0 )
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
