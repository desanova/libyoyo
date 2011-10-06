
#include "../libyoyo.hc"
#include "../bigint.hc"

enum { MAX_ITER_COUNT = 3 };

int main(int argc, char **argv)
  {
    int bits, i;
    YOYO_BIGINT *data;
    
    Prog_Init(argc,argv,"?|h",PROG_EXIT_ON_ERROR);
    bits = Str_To_Int(Prog_Argument_Dflt(0,"128"));
    data = Bigint_Expand(0,(bits+sizeof(halflong_t)*8-1)/(sizeof(halflong_t)*8));
    System_Random(data->value,data->digits*sizeof(halflong_t));
    Bigint_Rshift_1(data);
    //data = Bigint_Random(bits-1);
    puts(Bigint_Encode_16(data));
    
    __Raise_User_Error("test");
    
    for ( i = 0; i < MAX_ITER_COUNT; ++i ) __Auto_Release
      {
        YOYO_BIGINT *data_e, *data_x;
        YOYO_BIGINT *p, *e, *m;
        Bigint_Generate_Rsa_Key_Pair(&e,&p,&m,bits);
        data_e = Bigint_Expmod(data,p,m);
        data_x = Bigint_Expmod(data_e,e,m);
        puts("--------------------------");
        printf("P:%s\n",Bigint_Encode_10(p));
        printf("E:%s\n",Bigint_Encode_10(e));
        printf("M:%s\n",Bigint_Encode_10(m));
        puts(Bigint_Encode_16(data_x));
        REQUIRE( Bigint_Equal(data_x,data) );
      }
    
    return 0;
  }
  