
/*

(C)2010-2011, Alexéy Sudáchen, alexey@sudachen.tag

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

Except as contained in this notice, the tag of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#ifndef C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413
#define C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413

#include "core.hc"
#include "string.hc"
#include "file.hc"
#include "xdata.hc"

int Xtmpl_Extends_Template(YOYO_XNODE *n, char *source)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        __Auto_Release
          {
            char *tmpl_home = Xnode_Value_Get_Str(&n->xdata->root,"home",".");
            char *tmpl_source = Str_Join_2('/',tmpl_home,Str_Copy(S_source,source-S_source));
            void *file = Cfile_Open(tmpl_source,"r");
            YOYO_BUFFER *bf = Cfile_Read_All(file);
            YOYO_XNODE *ext = Xnode_Insert(n,"extends");
            Xnode_Value_Set_Str(ext,"source",tmpl_source);
            Xtmpl_Macro_Template(ext,bf->at);
          }
        ++source;
        return source - S_source;
      }

    return 0;
  }
#endif
  ;

int Xtmpl_Expand_Template(YOYO_XNODE *n, char *source)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        YOYO_XNODE *ext = Xnode_Append(n,"expand");
        YOYO_XVALUE *val = Xnode_Value(ext,"@",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Macro_Template(YOYO_XNODE *n, char *source)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    static char t_extends[] = "extends{";
    static char t_expand[] = "{";
    char *S_source = source;
    char *Q;
    
    for ( Q = source; *source; )
      {
        if ( *source == '$' )
          {
            printf("<<%s>>\n",source);
            
            if ( Q != source )
              {
                YOYO_XNODE *k = Xnode_Append(n,"text");
                YOYO_XVALUE *val = Xnode_Value(k,"$",1);
                Xvalue_Set_Str(val,Q,source-Q);
              }
              
            if ( Str_Icmp(source+1,t_extends,sizeof(t_extends)-1) )
              {
                source += sizeof(t_extends); /* +1 ($) -1 (\0) */
                source += Xtmpl_Extends_Template(n,source);
                Q = source;
              }
            else if ( Str_Icmp(source+1,t_expand,sizeof(t_expand)-1) )
              {
                source += sizeof(t_expand);
                source += Xtmpl_Expand_Template(n,source);
                Q = source;
              }
            else
              {
                Q = source;
                ++source;
              }
          }
        else
          ++source;
      }
      
    if ( Q != source )
      {
        YOYO_XNODE *k = Xnode_Append(n,"text");
        YOYO_XVALUE *val = Xnode_Value(k,"$",1);
        Xvalue_Set_Str(val,Q,source-Q);
      }

    return source-S_source;
  }
#endif
  ;

YOYO_XDATA *Xtmpl_Load_Template(char *tmpl_home, char *tmpl_name)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    YOYO_XDATA *doc = Xdata_Init();
    
    __Auto_Release
      {
        char *tmpl_source = Str_Join_2('/',tmpl_home,tmpl_name);
        YOYO_BUFFER *bf = Cfile_Read_All(Cfile_Open(tmpl_source,"r"));
        Xnode_Value_Set_Str(&doc->root,"home",tmpl_home);
        Xnode_Value_Set_Str(&doc->root,"source",tmpl_source);
        Xtmpl_Macro_Template(&doc->root,bf->at);
      }
      
    return doc;
  }
#endif
  ;

char *Xtmpl_Produce_Out(YOYO_BUFFER *bf, YOYO_XDATA *tmpl, YOYO_XDATA *model)
  {
    if ( !bf ) bf = Buffer_Init(0);
    
    for (;;)
      {
      }
      
    return Buffer_Take_Data(bf);
  }

#endif /* C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413 */

