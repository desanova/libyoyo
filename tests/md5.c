
#include "../libyoyo.hc"

int main(int argc, char **argv)
  {
    YOYO_BUFFER *bf;
    byte_t sign[16] = {0};
    
    
    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);

    if ( !Prog_Arguments_Count() )
      {
        puts("usage: ./md5 <filename>");
        exit(-1);
      }
    
    bf = Oj_Read_All(Cfile_Open(Prog_Argument(0),"r"));
    Md5_Sign_Data(bf->at,bf->count,sign);
    puts(Str_Hex_Encode(sign,16));
  }

