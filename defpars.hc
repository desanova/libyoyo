
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

#ifndef C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF
#define C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF

#include "core.hc"
#include "string.hc"
#include "buffer.hc"
#include "xdata.hc"
#include "file.hc"

typedef struct _YOYO_DEFPARSE_STATE
  {
    char *text;
    int lineno;
  } YOYO_DEFPARSE_STATE;

void Def_Parse_Skip_Spaces(YOYO_DEFPARSE_STATE *st)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    while ( *st->text && isspace(*st->text) )
      {
        if ( *st->text == '\n' ) ++st->lineno;
        ++st->text;
      }
  }
#endif
  ;

char *Def_Parse_Get_Literal(YOYO_DEFPARSE_STATE *st)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    int capacity = 127;
    int len = 0;
    char *out = 0;
    
    if ( *st->text == '"' || *st->text == '\'')
      {
        char brk = *st->text;
        char *S = ++st->text;
        for ( ; *st->text && *st->text != brk; ++st->text )
          {
            if ( *st->text == '\\' )
              {
                ++st->text;
                if ( *st->text == '\n' )
                  ++st->lineno;
                else if ( *st->text == '\r' )
                  ; /* none */
                else if ( *st->text == '\\' || *st->text == '"' || *st->text == '\'' )
                  __Vector_Append(&out,&len,&capacity,st->text,1);
                else if ( *st->text == 'n' )
                  __Vector_Append(&out,&len,&capacity,"\n",1);
                else if ( *st->text == 'r' )
                  __Vector_Append(&out,&len,&capacity,"\r",1);
                else if ( *st->text == 't' )
                  __Vector_Append(&out,&len,&capacity,"\t",1);
                else 
                  __Raise(YOYO_ERROR_ILLFORMED,__Format("invalid esc sequence at line %d",st->lineno));
              }
            else
              __Vector_Append(&out,&len,&capacity,st->text,1);
          }
          
        if ( *st->text == brk ) ++st->text;
      }
    else
      {
        char *q = st->text;
        while ( *st->text && !isspace(*st->text) && *st->text != ')' 
              && *st->text != '}' && *st->text != ',' && *st->text != ']' )
          ++st->text;
        __Vector_Append(&out,&len,&capacity,q,st->text-q);
      }
    
    return out;
  }
#endif
  ;

typedef struct
  {
    int type;
    union
      {
        YOYO_ARRAY  *arr;
        YOYO_BUFFER *dat;
        char   *txt;
        int     dec;
        double  flt;
      };
  } YOYO_DEFPARS_VALUE;

void Def_Parse_Get_Value(YOYO_DEFPARSE_STATE *st, YOYO_DEFPARS_VALUE *val)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    if ( *st->text == '[' )
      {
        ++st->text;
        if ( st->text[1] == '[' ) /* binary data */
          {
            byte_t b;
            val->dat = Buffer_Init(0);
            Def_Parse_Skip_Spaces(st);
            
            while ( isxdigit(*st->text) )
              {
                if ( !isxdigit(st->text[1]) )
                  __Raise(YOYO_ERROR_ILLFORMED,
                      __Format("expected hex byte value at line %d",st->lineno));
                
                b = Str_Unhex_Byte(st->text,0,0);
                Buffer_Append(val->dat,&b,1);
                st->text += 2;
                Def_Parse_Skip_Spaces(st);
              }
            
            if ( !*st->text || *st->text != ']' || st->text[1] != ']' )
              __Raise(YOYO_ERROR_ILLFORMED,
                  __Format("expected ']]' at line %d",st->lineno));
            
            val->type = XVALUE_OPT_VALTYPE_BIN;
            st->text += 2;
          }
        else /* array */
          { 
            YOYO_DEFPARS_VALUE lval;
            int tp;
            Def_Parse_Skip_Spaces(st);
            Def_Parse_Get_Value(st,&lval);
            if ( lval.type == XVALUE_OPT_VALTYPE_STR )
              {
                val->arr = Array_Ptrs();
                val->type= XVALUE_OPT_VALTYPE_STR_ARR;
                Array_Push(val->arr,__Retain(lval.txt));
              }
            else if ( lval.type == XVALUE_OPT_VALTYPE_INT 
                   || lval.type == XVALUE_OPT_VALTYPE_FLT )
              {
                val->dat = Buffer_Init(sizeof(double));
                val->type= XVALUE_OPT_VALTYPE_FLT_ARR;
                if ( lval.type == XVALUE_OPT_VALTYPE_INT )
                  *(double*)val->dat->at = lval.dec;
                else
                  *(double*)val->dat->at = lval.flt;
              }
            
            Def_Parse_Skip_Spaces(st);
            while ( *st->text == ',' )
              {
                ++st->text;
                Def_Parse_Skip_Spaces(st);
                Def_Parse_Get_Value(st,&lval);
                if ( val->type == XVALUE_OPT_VALTYPE_STR )
                  {
                    if ( val->type != XVALUE_OPT_VALTYPE_STR )
                      __Raise(YOYO_ERROR_ILLFORMED,
                              __Format("expected string value at line %d",st->lineno));
                    Array_Push(val->arr,__Retain(lval.txt));
                  }
                else /* XVALUE_OPT_VALUETYPE_FLT_ARR */
                  {
                    
                    if ( lval.type == XVALUE_OPT_VALTYPE_INT )
                      {
                        double f = lval.dec;
                        Buffer_Append(val->dat,&f,sizeof(double));
                      }
                    else if ( lval.type == XVALUE_OPT_VALTYPE_FLT )
                        Buffer_Append(val->dat,&lval.flt,sizeof(double));
                    else
                      __Raise(YOYO_ERROR_ILLFORMED,
                              __Format("expected numeric value at line %d",st->lineno));
                  }
                Def_Parse_Skip_Spaces(st);
              }
            
            if ( *st->text != ']' )
              __Raise(YOYO_ERROR_ILLFORMED,
                  __Format("expected ']' at line %d",st->lineno));
                  
            ++st->text;
          }
      }
    else if ( !isdigit(*st->text) 
            && ( (*st->text != '.' && *st->text != '-') || !isdigit(st->text[1]) ) )
      {
        val->txt = Def_Parse_Get_Literal(st);
        val->type = XVALUE_OPT_VALTYPE_STR;
      }
    else /* number */
      {
        if ( *st->text == '0' )
          {
            ++st->text;
            val->dec = 0;
            
            if ( *st->text == 'x' && isxdigit(st->text[1]) ) /* hex value */
              {
                ++st->text;
                do
                  {
                    val->dec = val->dec << 4;
                    Str_Unhex_Half_Octet(st->text,val->dec,0);
                    ++st->text;
                  }
                while ( isxdigit(*st->text) );
              }
            else if ( *st->text >= '0' && *st->text <= '7' )
              {
                ++st->text;
                do
                  {
                    val->dec = (val->dec << 3) | (*st->text-'0'); 
                    ++st->text;
                  }
                while ( *st->text >= '0' && *st->text <= '7' );
              }
            else if ( isspace(*st->text) )
              {
                ; /* nothing, it's zero value */
              }
            else
              goto invalid_numeric;
              
            val->type = XVALUE_OPT_VALTYPE_INT;
            
          }
        else if ( isdigit(*st->text) || *st->text == '.' || *st->text == '-' ) /* decimal or float value */
          {
            int neg = 1;
            int value = 0;
            
            if ( *st->text ) { neg = -1; ++st->text; }
            
            for ( ; isdigit(*st->text); ++st->text )
              value = value * 10 + ( *st->text - '0' );
            
            if ( *st->text == '.' )
              {
                double exp = 1;
                double d = value*neg;
                ++st->text;
                for ( ; isdigit(*st->text); ++st->text )
                  {
                    d = d * 10 + ( *st->text - '0' );
                    exp *= 10;
                  }
                val->flt = d/exp;
                val->type = XVALUE_OPT_VALTYPE_FLT;
              }
            else
              {
                val->type = XVALUE_OPT_VALTYPE_INT;
                val->dec = value*neg;
              }
          }

        if ( *st->text 
          && !isspace(*st->text) && *st->text != ')' 
          && *st->text != '}' && *st->text != ',' && *st->text != ']' )
      invalid_numeric:
          __Raise(YOYO_ERROR_ILLFORMED,
              __Format("invalid numeric value at line %d",st->lineno));
      }
  }
#endif
  ;

void Def_Parse_In_Node_Set_Value(YOYO_XNODE *n, char *name, YOYO_DEFPARS_VALUE *val)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    YOYO_XVALUE *xv = Xnode_Value(n,name,1);;
    //printf("value [%s] = %08x\n",name,val->type);
    switch ( val->type )
      {
        case XVALUE_OPT_VALTYPE_INT:
          Xvalue_Set_Int(xv,val->dec);
          break;
        case XVALUE_OPT_VALTYPE_FLT:
          Xvalue_Set_Flt(xv,val->flt);
          break;
        case XVALUE_OPT_VALTYPE_STR:
          Xvalue_Put_Str(xv,__Retain(val->txt));
          break;
        case XVALUE_OPT_VALTYPE_BIN:
          Xvalue_Put_Binary(xv,__Refe(val->dat));
          break;
        case XVALUE_OPT_VALTYPE_FLT_ARR:
          Xvalue_Put_Flt_Array(xv,__Refe(val->dat));
          break;
        case XVALUE_OPT_VALTYPE_STR_ARR:
          Xvalue_Put_Str_Array(xv,__Refe(val->arr));
          break;
        default:
          __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
      }
      
  }
#endif
  ;

void Def_Parse_In_Node( YOYO_DEFPARSE_STATE *st, YOYO_XNODE *n )
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    Def_Parse_Skip_Spaces(st);
    
    for ( ; *st->text && *st->text != '}' ; Def_Parse_Skip_Spaces(st) ) 
      {
        int go_deeper = 0;
        YOYO_XNODE *nn = 0;
        
        //printf("<<%s>>\n",st->text);
        __Auto_Release
          {
            YOYO_DEFPARS_VALUE value = {0};
            char *name; 
            
            name = Def_Parse_Get_Literal(st);
            Def_Parse_Skip_Spaces(st);

            //printf("name[%s]\n",name);

            if ( *st->text == '(' )
              {
                char *dflt;
                ++st->text;
                Def_Parse_Skip_Spaces(st);
                dflt = Def_Parse_Get_Literal(st);
                Def_Parse_Skip_Spaces(st);
                if ( *st->text != ')' )
                  __Raise(YOYO_ERROR_ILLFORMED,__Format("expected ')' at line %d",st->lineno));
                ++st->text;
                Def_Parse_Skip_Spaces(st);

                nn = Xnode_Append(n,name);
                Xnode_Value_Set_Str(nn,"@",dflt);
              }
              
            if ( *st->text == '=' )
              {
                ++st->text;
                Def_Parse_Skip_Spaces(st);
                Def_Parse_Get_Value(st,&value);
                Def_Parse_Skip_Spaces(st);
              }
            
            if ( *st->text == '{' )
              {
                ++st->text;
                go_deeper = 1;
                if ( !nn )
                  nn = Xnode_Append(n,name);
                if ( value.type )
                  Def_Parse_In_Node_Set_Value(nn,"$",&value);
              }
            else if ( value.type )
              {
                Def_Parse_In_Node_Set_Value(n,name,&value);
              }
              
          }
        
        if ( go_deeper )
          {
            Def_Parse_In_Node(st,nn);
            if ( *st->text != '}' )
              __Raise(YOYO_ERROR_ILLFORMED,__Format("expected '}' at line %d",st->lineno));
            ++st->text;
          }
      }
  }
#endif
  ;

YOYO_XDATA *Def_Parse_Str(char *text)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    /*
      number => [0-9]+(\.[0-9]*)?
      hexseq => ([0-f][0-f])+
      binary => \[ hexseq* \]
      literal => [^][() \n\t\r]*
      text => \"[^"]\"|literal
      value => number|text|binary
      node => literal \( value \) [ \= value ] [ \{ (node|attr)* \} ]
      node => literal [ \= value ] \{ (node|attr)* \}
      attr => literal \= value
      file => (node|attr)*
    */
    YOYO_DEFPARSE_STATE st = { text, 1 };
    YOYO_XDATA *doc = Xdata_Init();
    Def_Parse_In_Node(&st,&doc->root);
    return doc;
  }
#endif
  ;

YOYO_XDATA *Def_Parse_File(char *filename)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    YOYO_XDATA *ret = 0;
    
    __Auto_Ptr(ret)
      {
        YOYO_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"rt"));
        ret = Def_Parse_Str(bf->at);
      }
    return ret;
  }
#endif
  ;

void Def_Format_Node_In_Depth(YOYO_BUFFER *bf, YOYO_XNODE *r, int flags, int indent)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    __Gogo
      {
        YOYO_XVALUE *val = Xnode_First_Value(r);
        for ( ; val; val = Xnode_Next_Value(r,val) )
          {
            char *tag = Xnode_Value_Get_Tag(r,val);
            
            Buffer_Fill_Append(bf,'\t',indent);
            Buffer_Append(bf,tag,-1);
            Buffer_Append(bf," = ",-1);
            
            switch ( val->opt&XVALUE_OPT_VALTYPE_MASK )
              {
                case XVALUE_OPT_VALTYPE_NONE:
                  Buffer_Append(bf,"#none",-1);
                  break;
                  
                case XVALUE_OPT_VALTYPE_BOOL:
                  if ( val->bval )
                    Buffer_Append(bf,"#yes",-1);
                  else
                    Buffer_Append(bf,"#no",-1);
                  break;
                  
                case XVALUE_OPT_VALTYPE_INT:
                  Buffer_Printf(bf,"%d",val->dec);
                  break;
                  
                case XVALUE_OPT_VALTYPE_FLT:
                  Buffer_Printf(bf,"%.3f",val->flt);
                  break;
                  
                case XVALUE_OPT_VALTYPE_STR:
                  Buffer_Append(bf,"\"",1);
                  Buffer_Quote_Append(bf,val->txt,-1,'"');
                  Buffer_Append(bf,"\"",1);
                  break;
                  
                case XVALUE_OPT_VALTYPE_LIT:
                  Buffer_Append(bf,"\"",1);
                  Buffer_Quote_Append(bf,(char*)&val->down,-1,'"');
                  Buffer_Append(bf,"\"",1);
                  break;
                  
                case XVALUE_OPT_VALTYPE_BIN:
                  {
                    int bytes_per_line = 30;
                    int q = 0;
                    
                    Buffer_Append(bf,"[[",2);
                    
                    if ( val->binary->count > bytes_per_line )
                      {  
                        Buffer_Append(bf,"\n",1);
                        Buffer_Fill_Append(bf,'\t',indent+1);
                      }
                      
                    while ( q < val->binary->count )
                      {
                        int l = val->binary->count - q;
                        if ( l > bytes_per_line ) l = bytes_per_line;
                        Buffer_Hex_Append(bf,val->binary->at+q,l);
                        q += l;
                        if ( q < val->binary->count )
                          {
                            Buffer_Append(bf,"\n",1);
                            Buffer_Fill_Append(bf,'\t',indent+1);
                          }
                      }
                      
                    Buffer_Append(bf,"]]",2);
                    break;
                  }
                  
                case XVALUE_OPT_VALTYPE_STR_ARR:
                  {
                    int q = 0;
                    int count = Array_Count(val->strarr);
                    
                    Buffer_Append(bf,"[",2);
                    Buffer_Append(bf,"\n",1);
                    Buffer_Fill_Append(bf,'\t',indent+1);
                      
                    for ( ; q < count; ++q )
                      {
                        Buffer_Append(bf,"\"",1);
                        Buffer_Quote_Append(bf,val->strarr->at[q],-1,'"');
                        Buffer_Append(bf,"\"\n",2);
                        Buffer_Fill_Append(bf,'\t',indent+1);
                      }
                      
                    Buffer_Append(bf,"]",2);
                    break;
                  }
                case XVALUE_OPT_VALTYPE_FLT_ARR:
                  {
                    int q = 0;
                    int nums_per_line = 5;
                    
                    Buffer_Append(bf,"[",2);
                    
                    if ( val->binary->count > nums_per_line*sizeof(double) )
                      {  
                        Buffer_Append(bf,"\n",1);
                        Buffer_Fill_Append(bf,'\t',indent+1);
                      }
                      
                    while ( q+sizeof(double) <= val->binary->count )
                      {
                        int l = (val->binary->count - q)/sizeof(double);
                        if ( l > nums_per_line ) l = nums_per_line;
                        for ( ; l > 0; --l )
                          {
                            double d = *(double*)(val->binary->at+q*sizeof(double));
                            
                            if ( (d - floor(d)) > 0.000999999 )
                              Buffer_Printf(bf,"%.3f",d);
                            else
                              Buffer_Printf(bf,"%.f",d);
                            
                            q += sizeof(double);
                            if ( q+sizeof(double) <= val->binary->count )
                            Buffer_Append(bf,",",1);
                          }
                        if ( q+sizeof(double) <= val->binary->count )
                          {
                            Buffer_Append(bf,"\n",1);
                            Buffer_Fill_Append(bf,'\t',indent+1);
                          }
                      }
                      
                    Buffer_Append(bf,"]",2);
                    break;
                  }
              }
            
            Buffer_Append(bf,"\n",1);
          }
      }

    __Gogo
      {
        YOYO_XNODE *n = Xnode_Down(r);
        for ( ; n; n = Xnode_Next(n) )
          {
            Buffer_Fill_Append(bf,'\t',indent);
            Buffer_Append(bf,Xnode_Get_Tag(n),-1);
            Buffer_Append(bf," {\n",3);
            Def_Format_Node_In_Depth(bf,n,flags,indent+1);
            Buffer_Fill_Append(bf,'\t',indent);
            Buffer_Append(bf,"}\n",2);
          }
      }
  }
#endif
  ;

char *Def_Format_Into(YOYO_BUFFER *bf, YOYO_XNODE *r, int flags)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
    if ( !bf ) bf = Buffer_Init(0);
    Def_Format_Node_In_Depth(bf,r,flags,0);
    return bf->at;
  }
#endif
  ;
  
void Def_Format_File(char *fname, YOYO_XNODE *r, int flags)
#ifdef _YOYO_DEFPARS_BUILTIN
  {
  }
#endif
  ;

#endif /* C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF */

