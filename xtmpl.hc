
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

typedef struct _YOYO_XTMPL_UP
  {
    YOYO_XNODE *tmpl;
    struct _YOYO_XTMPL_UP *up;
  } YOYO_XTMPL_UP;

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
        YOYO_XVALUE *val = Xnode_Value(ext,"$",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Liftup_Template(YOYO_XNODE *n, char *source)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        YOYO_XNODE *ext = Xnode_Append(n,"liftup");
        YOYO_XVALUE *val = Xnode_Value(ext,"$",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Gadget_Template(YOYO_XNODE *n, char *source)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        YOYO_XNODE *ext = Xnode_Append(n,"gadget");
        YOYO_XVALUE *val = Xnode_Value(ext,"$",1);
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
    static char t_liftup[]  = "liftup{";
    static char t_gadget[]  = "gadget{";
    static char t_expand[]  = "{";
    char *S_source = source;
    char *Q;
    
    for ( Q = source; *source; )
      {
        if ( *source == '$' )
          {
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
            else if ( Str_Icmp(source+1,t_liftup,sizeof(t_liftup)-1) )
              {
                source += sizeof(t_liftup);
                source += Xtmpl_Liftup_Template(n,source);
                Q = source;
              }
            else if ( Str_Icmp(source+1,t_gadget,sizeof(t_gadget)-1) )
              {
                source += sizeof(t_gadget);
                source += Xtmpl_Gadget_Template(n,source);
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

void Xtmpl_Handle_Error_Out(YOYO_BUFFER *bf, char *tag, char *text)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    Buffer_Append(bf,"<span id=\"xtmpl-error\">{",-1);
    Buffer_Append(bf,tag,-1);
    Buffer_Append(bf,":",1);
    Buffer_Html_Quote_Append(bf,text,-1);
    Buffer_Append(bf,"}</span>",-1);
  }
#endif
  ;

void Xtmpl_Call_Gadget(YOYO_BUFFER *bf, char *operate)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    Xtmpl_Handle_Error_Out(bf,"gadget","unsupported");
  }
#endif
  ;

void Xtmpl_Handle_Node_Out(YOYO_BUFFER *bf, YOYO_XNODE *n, YOYO_XDATA *model)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    if ( Xnode_Tag_Is(n,"text") )
      {
        char *value = Xnode_Value_Get_Str(n,"$",0);
        Buffer_Append(bf,value,-1);
      }
    else if ( Xnode_Tag_Is(n,"expand") )
      {
        char *query = Xnode_Value_Get_Str(n,"$",0);
        if ( !query || !Xnode_Query_Str_Bf(bf,&model->root,query) )
          Xtmpl_Handle_Error_Out(bf,"expand",query);
      }
    else if ( Xnode_Tag_Is(n,"gadget") )
      {
        char *operate = Xnode_Value_Get_Str(n,"$",0);
        Xtmpl_Call_Gadget(bf,operate);
      }
    else
      /* skip */
      ;
  }
#endif
  ;

void Xtmpl_Step_Up(YOYO_BUFFER *bf, YOYO_XTMPL_UP *up, char *content, YOYO_XDATA *model)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    YOYO_XNODE *n = Xnode_Down(up->tmpl);
    while ( n )
      {
        if ( Xnode_Tag_Is(n,"liftup") )
          Xtmpl_Step_Up(bf,up->up,Xnode_Value_Get_Str(n,"$","content"),model);
        else
          Xtmpl_Handle_Node_Out(bf,n,model);
        n = Xnode_Next(n);
      }
  }
#endif
  ;

void Xtmpl_Step_Down(YOYO_BUFFER *bf, YOYO_XNODE *tmpl, YOYO_XTMPL_UP *up, YOYO_XDATA *model)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    YOYO_XTMPL_UP upstep = { tmpl, up };
    YOYO_XNODE *down = Xnode_Down_If(tmpl,"extends");
    if ( down )
      Xtmpl_Step_Down(bf,down,&upstep,model);
    else
      Xtmpl_Step_Up(bf,&upstep,"content",model);
  }
#endif
  ;

char *Xtmpl_Produce_Out(YOYO_BUFFER *bf, YOYO_XDATA *tmpl, YOYO_XDATA *model)
#ifdef _YOYO_XTMPL_BUILTIN 
  {
    if ( !bf ) bf = Buffer_Init(0);
    Buffer_Append(bf,"\n",1);
    Xtmpl_Step_Down(bf,&tmpl->root,0,model);
    return Buffer_Take_Data(bf);
  }
#endif
  ;

#endif /* C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413 */

