
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

#ifndef C_once_AF69CAD4_02C8_492E_9C13_B69483693E5F
#define C_once_AF69CAD4_02C8_492E_9C13_B69483693E5F

#include "core.hc"
#include "dicto.hc"
#include "array.hc"
#include "string.hc"

#ifdef _YOYO_PROG_BUILTIN
static void *Prog_Data_Opts = 0;
static void *Prog_Data_Args = 0;
static char *Prog_Dir_S = 0;
static char *Prog_Nam_S = 0;
#endif

enum _YOYO_ROG_FLAGS
  {
    PROG_CMDLINE_OPTS_FIRST = 1,
    PROG_EXIT_ON_ERROR = 2,
  };

typedef enum _YOYO_PROG_PARAM_FEATURES
  {
    PROG_PARAM_HAS_NO_ARGUMENT,
    PROG_PARAM_HAS_ARGUMENT,
    PROG_PARAM_CAN_HAVE_ARGUMENT
  } YOYO_PROG_PARAM_FEATURES;

typedef struct _YOYO_PROG_PARAM_INFO
  {
    void *vals;
    int  *present;
    YOYO_PROG_PARAM_FEATURES features;
  } YOYO_PROG_PARAM_INFO;

void Prog_Param_Info_Destruct(YOYO_PROG_PARAM_INFO *o)
#ifdef _YOYO_PROG_BUILTIN
  {
    Yo_Unrefe(o->vals);
    Yo_Unrefe(o->present);
    Yo_Object_Destruct(o);
  }
#endif
  ;

void *Prog_Param_Info(void)
#ifdef _YOYO_PROG_BUILTIN
  {
    return Yo_Object_Dtor(sizeof(YOYO_PROG_PARAM_INFO),Prog_Param_Info_Destruct);
  }
#endif
  ;

void *Prog_Parse_Command_Line_Pattern(char *patt)
#ifdef _YOYO_PROG_BUILTIN
  {
    int i,j;
    void *dt = Dicto_Refs();
    YOYO_ARRAY *L = Str_Split(patt,",; \t\n\r");
    
    for ( i = 0; i < L->count; ++i )
      {
        YOYO_ARRAY *Q = Str_Split(L->at[i],"|");
        if ( Q->count )
          {
            int *present = Yo_Object(sizeof(int),0);
            void *vals = 0;
            
            for ( j = 0; j < Q->count; ++j )
              {
                YOYO_PROG_PARAM_INFO *nfo = Prog_Param_Info();
                char *S = Q->at[j];
                int S_Ln = strlen(S)-1;
                
                if ( S[S_Ln] == ':' )
                  { 
                    nfo->features = PROG_PARAM_HAS_ARGUMENT; 
                    S[S_Ln] = 0;
                  }
                else if ( S[S_Ln] == '=' )
                  { 
                    nfo->features = PROG_PARAM_CAN_HAVE_ARGUMENT; 
                    S[S_Ln] = 0; 
                  }
                else
                  nfo->features = PROG_PARAM_HAS_NO_ARGUMENT;
                
                if ( nfo->features != PROG_PARAM_HAS_NO_ARGUMENT )
                  {
                    if ( !vals )
                      vals = Array_Ptrs();
                    nfo->vals = Yo_Refe(vals);
                  }
                
                nfo->present = Yo_Refe(present);  
                Dicto_Put(dt,S,Yo_Refe(nfo));
              }
          }
      }
      
    return dt;
  }
#endif
  ;

void Prog_Parse_Command_Line(int argc, char **argv, char *patt, unsigned flags)
#ifdef _YOYO_PROG_BUILTIN
  {
    int i;
    void *args = Array_Void();
    void *opts = Prog_Parse_Command_Line_Pattern(patt);
    
    int argument_passed = 0;
    for ( i = 1; i < argc; ++i )
      {
        if ( (*argv[i] == '-' && argv[i][1] && (argv[i][1] != '-' || argv[i][2]))
          && (!(flags&PROG_CMDLINE_OPTS_FIRST)||!argument_passed) )
          {
            YOYO_ARRAY *L;
            YOYO_PROG_PARAM_INFO *a;
            char *Q = argv[i]+1;
            
            if ( *Q == '-' ) ++Q;
            if ( !*Q ) continue;

            L = Str_Split_Once(Q,"=");
            if ( 0 != (a = Dicto_Get(opts,L->at[0],0)) )
              {
                if ( a->features == PROG_PARAM_HAS_ARGUMENT && L->count == 1 )
                  {
                    if ( argc > i+1 )
                      {
                      #ifdef __windoze
                        Array_Push(L,Str_Locale_To_Utf8_Npl(argv[i+1])); 
                      #else
                        Array_Push(L,Str_Copy_Npl(argv[i+1],-1)); 
                      #endif
                        ++i;
                      }
                    else
                        Yo_Raise(YOYO_ERROR_ILLFORMED,
                                  Yo_Format("comandline option -%s requires parameter",(L->at)[0]),
                                  __FILE__,__LINE__);
                  }
                                
                if ( a->features == PROG_PARAM_HAS_NO_ARGUMENT && L->count > 1 )
                      Yo_Raise(YOYO_ERROR_ILLFORMED,
                                Yo_Format("comandline option -%s does not have parameter",(L->at)[0]),
                                __FILE__,__LINE__);
                *a->present = 1;
                if ( L->count > 1 )
                  Array_Push(a->vals,Array_Take_Npl(L,1));
              }
            else
                Yo_Raise(YOYO_ERROR_ILLFORMED,
                          Yo_Format("unknown comandline option -%s",(L->at)[0]),
                          __FILE__,__LINE__);
          }
        else
          {
            argument_passed = 1;
            Array_Push(args,argv[i]);
          }
      }

    Prog_Data_Opts = Yo_Refe(opts);
    Prog_Data_Args = Yo_Refe(args);
  }
#endif
  ;

void Prog_Clear_At_Exit(void)
#ifdef _YOYO_PROG_BUILTIN
  {
    Yo_Unrefe(Prog_Data_Opts);
    Yo_Unrefe(Prog_Data_Args);
    Yo_Thread_Cleanup();
    Yo_Global_Cleanup();
  }
#endif
  ;
  
int Prog_Init(int argc, char **argv, char *patt, unsigned flags)
#ifdef _YOYO_PROG_BUILTIN
  {
    int rt = 0;
    __Auto_Release __Try_Except
      {
        setlocale(LC_NUMERIC,"C");
        setlocale(LC_TIME,"C");
        Prog_Parse_Command_Line(argc,argv,patt,flags);
      #if __windoze
      #else
        Prog_Nam_S = __Retain(Path_Fullname(argv[0]));
        Prog_Dir_S = __Retain(Path_Dirname(Prog_Nam_S));
        REQUIRE(Prog_Dir_S != 0);
      #endif
        rt = 1;
        atexit(Prog_Clear_At_Exit);
      }
    __Except
      {
        if ( flags & PROG_EXIT_ON_ERROR )
          Error_Print_N_Exit(Yo__basename(argv[0]),-1);
      }
    return rt;
  }
#endif
  ;

int Prog_Arguments_Count()
#ifdef _YOYO_PROG_BUILTIN
  {
    return Array_Count(Prog_Data_Args);
  }
#endif
  ;

char *Prog_Argument(int no)
#ifdef _YOYO_PROG_BUILTIN
  {
    return Array_At(Prog_Data_Args,no);
  }
#endif
  ;

char *Prog_Argument_Dflt(int no,char *dflt)
#ifdef _YOYO_PROG_BUILTIN
  {
    if ( no < 0 || no >= Array_Count(Prog_Data_Args) )
      return dflt;
    return Array_At(Prog_Data_Args,no);
  }
#endif
  ;

int Prog_Argument_Int(int no)
#ifdef _YOYO_PROG_BUILTIN
  {
    char *S = Array_At(Prog_Data_Args,no);
    return strtol(S,0,10);
  }
#endif
  ;

int Prog_Has_Opt(char *name)
#ifdef _YOYO_PROG_BUILTIN
  {
    YOYO_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
    return i && *i->present;    
  }
#endif
  ;

int Prog_Opt_Count(char *name)
#ifdef _YOYO_PROG_BUILTIN
  {
    YOYO_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
    if ( i && *i->present && i->vals )
      return Array_Count(i->vals);
    return 0;
  }
#endif
  ;

char *Prog_Opt(char *name,int no)
#ifdef _YOYO_PROG_BUILTIN
  {
    YOYO_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
    if ( !i || !*i->present || !i->vals )
      return 0;
    return Array_At(i->vals,no);
  }
#endif
  ;
  
char *Prog_First_Opt(char *name,char *dflt)
#ifdef _YOYO_PROG_BUILTIN
  {
    YOYO_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
    if ( !i || !*i->present || !i->vals || !Array_Count(i->vals) )
      return dflt;
    return Array_At(i->vals,0);
  }
#endif
  ;

int Prog_First_Opt_Int(char *name,int dflt)
#ifdef _YOYO_PROG_BUILTIN
  {
    char *Q = Prog_First_Opt(name,0);
    if ( !Q ) return dflt;
    return strtol(Q,0,10);
  }
#endif
  ;

char *Prog_Last_Opt(char *name,char *dflt)
#ifdef _YOYO_PROG_BUILTIN
  {
    YOYO_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
    if ( !i || !*i->present || !i->vals || !Array_Count(i->vals) )
      return dflt;
    return Array_At(i->vals,-1);
  }
#endif
  ;

int Prog_Last_Opt_Int(char *name,int dflt)
#ifdef _YOYO_PROG_BUILTIN
  {
    char *Q = Prog_Last_Opt(name,0);
    if ( !Q ) return dflt;
    return strtol(Q,0,10);
  }
#endif
  ;

char *Prog_Directory()
#ifdef _YOYO_PROG_BUILTIN
  {
    return Prog_Dir_S;
  }
#endif
  ;

char *Prog_Fullname()
#ifdef _YOYO_PROG_BUILTIN
  {
    return Prog_Nam_S;
  }
#endif
  ;

#endif /* C_once_AF69CAD4_02C8_492E_9C13_B69483693E5F */

