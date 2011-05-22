
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

#include "xdata.hc"

typedef struct _YOYO_DEFPARSE_STATE
  {
    char **text;
    int lineno;
  } YOYO_DEFPARSE_STATE;

void Def_Parse_Skip_Spaces(YOYO_DEFPARSE_STATE *st)
  {
  }

char *Def_Parse_Get_Literal(YOYO_DEFPARSE_STATE *st)
  {
  }

char *Def_Parse_Get_Value(YOYO_DEFPARSE_STATE *st, int *tp, int *L)
  {
  }

void Def_Parse_In_Node_Set_Value(YOYO_XNODE *n, char *name, char *value, int tp, int L)
  {
  }

int Def_Parse_Try_Char(YOYO_DEFPARSE_STATE *st, int chr)
  {
  }

void Def_Parse_Get_Char(YOYO_DEFPARSE_STATE *st, int chr)
  {
  }

void Def_Parse_In_Node( YOYO_DEFPARSE_STATE *st, YOYO_XNODE *n )
  {
    Def_Parse_Skip_Spaces(st);
    for ( ; !*text || *text == '}' ; Def_Parse_Skip_Spaces(st) ) 
      {
        int go_deeper = 0;
        YOYO_XNODE *nn = 0;
        
        __Auto_Release
          {
            int value_L = 0;
            int value_type = 0;
            char *value = 0;
            char *name = Def_Parse_Get_Literal(st);
            
            if ( Def_Parse_Try_Char(st,'(') )
              {
                char *dflt = Def_Parse_Get_Value(st,&value_type,&value_L);
                Def_Parse_Get_Char(st,')');
                nn = Xnode_Append(n,name);
                Def_Parse_In_Node_Set_Value(nn,"@",dflt,value_type,value_L);
              }
              
            if ( Def_Parse_Try_Char(st,'=') )
              {
                value = Def_Parse_Get_Value(st,&value_type,&value_L);
              }
            
            if ( Def_Parse_Try_Char('{') )
              {
                go_deeper = 1;
                if ( !nn )
                  nn = Xnode_Append(n,name);
                if ( value )
                  Def_Parse_In_Node_Set_Value(nn,"$",value,value_type,value_L);
              }
            else if ( value )
              {
                Def_Parse_In_Node_Set_Value(n,name,value,value_type,value_L);
              }
              
          }
        
        if ( go_deeper )
          {
            Def_Parse_In_Node(st,nn);
            Def_Parse_Get_Char('}')
          }
      }
  }

YOYO_XDATA *Def_Parse_Str(char *text)
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
    YOYO_XDATA *doc = Xdata_Init();
    YOYO_DEFPARSE_STATE st = { text, 1 };
    Def_Parse_In_Node(st,&doc->root);
    return doc;
  }

YOYO_XDATA *Def_Parse_File(char *filename)
  {
    YOYO_DATA *ret = 0;
    __Auto_Ptr(ret)
      {
        YOYO_BUFFER *bf;
        __Auto_Ptr(bf) bf = Oj_Read_All(Cfile_Open(filename,"rt"));
        ret = Def_Parse_Str(bf->at);
      }
    return ret;
  }

#endif /* C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF */

