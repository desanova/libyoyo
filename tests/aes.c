
#define _LIBYOYO
#include "../libyoyo.hc"
#include "../libcrypt.hc"

int main(int argc, char **argv)
  {
    YOYO_AES ctxe, ctxd;
    YOYO_BUFFER *bf, *bbf, *bbbf;
    char passwd[] = "1234567\0\0\0\0";
    byte_t sign[32] = {0};
    int i;
    
    Prog_Init(argc,argv,"?|h,a:",PROG_EXIT_ON_ERROR);

    if ( Prog_Has_Opt("a") )
      {
        bf = Buffer_Init(Str_To_Int(Prog_First_Opt("a",0)));
        System_Random(bf->at,bf->count);
        printf("generated %d random bytes\n",bf->count);
      }
    else 
      {
        if ( !Prog_Arguments_Count() )
          {
            puts("usage: ./aes <filename>");
            exit(-1);
          }
        bf = Oj_Read_All(Cfile_Open(Prog_Argument(0),"r"));
      }
    
    System_Random(passwd+strlen(passwd),4);
    Sha2_Digest(passwd,sizeof(passwd),sign);
    
    Aes_Init_Encipher_Static(&ctxe,sign,256);
    Aes_Init_Decipher_Static(&ctxd,sign,256);
    bbf = Buffer_Copy(bf->at,bf->count);
    for ( i = 0; i+16 < bf->count; i+= 16 )
      Aes_Encrypt16(&ctxe,bbf->at+i);
    __Auto_Release 
      Oj_Write_Full(Cfile_Open("aes.encrypted","w+"),bbf->at,bbf->count);
    bbbf = Buffer_Copy(bbf->at,bbf->count);
    for ( i = 0; i+16 < bf->count; i+= 16 )
      Aes_Decrypt16(&ctxd,bbbf->at+i);
    __Auto_Release 
      Oj_Write_Full(Cfile_Open("aes.decrypted","w+"),bbbf->at,bbbf->count);
      
    REQUIRE( memcmp(bf->at,bbbf->at,bf->count) == 0 );
    puts("succeeded!");
    return 0;
  }

