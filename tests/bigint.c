
#include "../libyoyo.hc"

int main(int argc, char **argv)
  {
    void *f;
    int logout;
    clock_t S = clock();
    clock_t S0 = 0, S1;
    
    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);
    
    logout = Prog_Has_Opt("l");
    f = Cfile_Open(Prog_Argument_Dflt(0,"longinteger.txt"),"r");
    
    while ( !Oj_Eof(f) ) __Auto_Release 
      {
        YOYO_BIGINT *a, *b, *c, *R;
        char *l = Oj_Read_Line(f);
        YOYO_ARRAY *q = Str_Split(l,0);
        if ( !q->count ) continue;

        a = Bigint_Decode_10(q->at[1]);
        b = Bigint_Decode_10(q->at[2]);
        c = Bigint_Decode_10(q->at[3]);
        R = Bigint_Decode_10(q->at[4]);
        
        if ( !strcmp(q->at[0],"*") )
          {
            YOYO_BIGINT *Q = Bigint_Mul(Bigint_Copy(a),b);
            if (logout) puts(__Format("%s*%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],"/") )
          {
            YOYO_BIGINT *Q = Bigint_Div(Bigint_Copy(a),b);
            if (logout) puts(__Format("%s/%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],"+") )
          {
            YOYO_BIGINT *Q = Bigint_Add(Bigint_Copy(a),b);
            if (logout) puts(__Format("%s+%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],"-") )
          {
            YOYO_BIGINT *Q = Bigint_Sub(Bigint_Copy(a),b);
            if (logout) puts(__Format("%s-%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],"%") )
          {
            YOYO_BIGINT *Q = Bigint_Modulo(Bigint_Copy(a),b);
            if (logout) puts(__Format("%s%%%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],"**%") )
          {
            YOYO_BIGINT *Q = Bigint_Expmod(Bigint_Copy(a),b,c);
            if (logout) puts(__Format("%s**%s%%%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(c),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],"*%") )
          {
            YOYO_BIGINT *Q = Bigint_Modmul(Bigint_Copy(a),b,c);
            if (logout) puts(__Format("%s*%s%%%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(c),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
       else if ( !strcmp(q->at[0],"*/%") )
          {
            YOYO_BIGINT *Q = Bigint_Invmod(Bigint_Copy(a),b);
            if (logout) puts(__Format("%s/%%%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
       else if ( !strcmp(q->at[0],"<<") )
          {
            YOYO_BIGINT *Q = Bigint_Lshift(Bigint_Copy(a),b->value[0]);
            if (logout) puts(__Format("%s<<%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
        else if ( !strcmp(q->at[0],">>") )
          {
            YOYO_BIGINT *Q = Bigint_Rshift(Bigint_Copy(a),b->value[0]);
            if (logout) puts(__Format("%s>>%s=%s (%s)",
              Bigint_Encode_10(a),
              Bigint_Encode_10(b),
              Bigint_Encode_10(Q), Bigint_Encode_10(R)));
            REQUIRE( Bigint_Equal(Q,R) );
          }
      }
    
    S1 = clock();
    printf("total time: %.3f\n",(double)(S1-S)/CLOCKS_PER_SEC);
      
    return 0;
  }

