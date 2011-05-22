
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

#ifndef C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95
#define C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95

#include "core.hc"
#include "string.hc"
#include "dicto.hc"

#define XNODE_MAX_NAME_INDEX_PTR  ((void*)0x07fff)
#define XNODE_NUMBER_OF_NODE_LISTS 9

enum XVALUE_OPT_VALTYPE
  {
    XVALUE_OPT_VALTYPE_NONE   = 0x08000,
    XVALUE_OPT_VALTYPE_INT    = 0x08001,
    XVALUE_OPT_VALTYPE_FLT    = 0x08002,
    XVALUE_OPT_VALTYPE_STR    = 0x08003,
    XVALUE_OPT_VALTYPE_BIN    = 0x08004,
    XVALUE_OPT_VALTYPE_BOOL   = 0x08005,
    XVALUE_OPT_VALTYPE_LIT    = 0x08006,
    XVALUE_OPT_VALTYPE_MASK   = 0x08007,
    XVALUE_OPT_IS_VALUE       = 0x08000,
  };

struct _YOYO_XNODE;
struct _YOYO_XDATA;
struct _YOYO_XVALUE_BINARY;

typedef struct _YOYO_XDATA
  {
    struct _YOYO_XNODE root;    
    union _YOYO_XNODE *nodes[XNODE_NUMBER_OF_NODE_LISTS];
    char *names;
    void *dicto;
    ushort_t last_name;
    ushort_t last_node;
  } YOYO_XDATA;

typedef struct _YOYO_XNODE
  {
    ushort_t name;
    ushort_t opt;
    ushort_t next;
    ushort_t down;
    union       
      {
        char   *txt;
        double  flt;
        int     dec;
        struct _YOYO_XVALUE_BINARY *binary;
        struct _YOYO_XDATA *xdata;
        char   holder[Yo_MAX(sizeof(double),sizeof(void*))];
      };
  } YOYO_XNODE;

typedef YOYO_XNODE YOYO_XVALUE;

typedef struct _YOYO_XVALUE_BINARY
  {
    uint_t len;
    byte_t kind;
    byte_t data[1];
  } YOYO_XVALUE_BINARY;

#define Number_Of_Nodes_In_List(No) (1<<(5+(No)))

void Xvalue_Purge(YOYO_XVALUE *val)
#ifdef _YOYO_XDATA_BUILTIN
  {
    ushort_t tp = val->opt & XVALUE_OPT_VALTYPE_MASK;
    
    switch ( tp )
      {
        case XVALUE_OPT_VALTYPE_STR:
          free(val->txt);
          break;
        case XVALUE_OPT_VALTYPE_BIN:
          free(val->binary);
          break;
        case XVALUE_OPT_VALTYPE_NONE:
        case XVALUE_OPT_VALTYPE_INT:
        case XVALUE_OPT_VALTYPE_FLT:
        case XVALUE_OPT_VALTYPE_LIT:
          break;
        default:
          __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
      }
      
    val->opt = XVALUE_OPT_VALTYPE_NONE;
    val->down = 0;
    memset(val->holder,0,sizeof(val->holder));
  }
#endif
  ;
  
char *Xvalue_Copy_Str(YOYO_XVALUE *val, char *dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return Str_From_Int(val->p.dec,10);
          case XVALUE_OPT_VALTYPE_FLT:          
            return Str_From_Flt(val->p.flt,0);
          case XVALUE_OPT_VALTYPE_STR:
            return Str_Copy(val->p.txt,-1);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_Copy((char*)&val->down,-1);
          case XVALUE_OPT_VALTYPE_NONE:
            return Str_Copy("",-1);
          case XVALUE_OPT_VALTYPE_BOOL:
            if ( val->p.bval )
              return Str_Copy("yes",3);
            else
              return Str_Copy("no",2);
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval?Str_Copy(dfltval,-1):0;
  }
#endif
  ;
  
char *Xvalue_Get_Str(YOYO_XVALUE *val, char *dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_STR:
            return val->p.text;
          case XVALUE_OPT_VALTYPE_LIT:
            return (char*)&val->down;
          case XVALUE_OPT_VALTYPE_NONE:
            return "";
          case XVALUE_OPT_VALTYPE_BOOL:
            if ( val->p.bval )
              return "yes";
            else
              return "no";
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;

int Xvalue_Get_Int(YOYO_XVALUE *val, int dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return val->p.dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return (int)val->p.flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Int(val->p.txt,0);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Int((char*)&val->down,0);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          case XVALUE_OPT_VALTYPE_BOOL:
            return val->p.bval;
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;
  
double Xvalue_Get_Flt(YOYO_XVALUE *val, double dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return (double)val->p.dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->p.flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Flt(val->p.txt,0);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Flt((char*)&val->down,0);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;
  
int Xvalue_Get_Bool(YOYO_XVALUE *val, int dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return val->p.dec?1:0;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->p.flt?1:0;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Bool(val->p.txt);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Bool((char*)&val->down);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;
  
void Xvalue_Set_Str(YOYO_XVALUE *val, char *S, int L)
#ifdef _YOYO_XDATA_BUILTIN
  {
    Xvalue_Purge(val);
    if ( L < 0 ) L = S?strlen(S):0;
    if ( L >= sizeof(val->down)+sizeof(val->holder) )
      {
        val->p.txt = Str_Copy_Npl(S,L);
        val->opt = XVALUE_OPT_VALTYPE_STR;
      }
    else
      {
        if (L) memcpy((char*)&val->down,S,L);
        /* already filled by 0 in Xvalue_Purge //((char*)&val->down)[L] = 0; */
        val->opt = XVALUE_OPT_VALTYPE_LIT;
      }
  }
#endif
  ;
  
void Xvalue_Put_Str(YOYO_XVALUE *val, __Acquire char *S)
#ifdef _YOYO_XDATA_BUILTIN
  {
    Xvalue_Purge(val);
    val->p.txt = S;
    val->opt = XVALUE_OPT_VALTYPE_STR;
  }
#endif
  ;
  
void Xvalue_Set_Int(YOYO_XVALUE *val, int i)
#ifdef _YOYO_XDATA_BUILTIN
  {
    REQUIRE ( val );
    Xvalue_Purge(val);
    val->p.dec = i;
    val->opt = XVALUE_OPT_VALTYPE_INT;
  }
#endif
  ;
  
void Xvalue_Set_Flt(YOYO_XVALUE *val, double d)
#ifdef _YOYO_XDATA_BUILTIN
  {
    REQUIRE ( val );
    Xvalue_Purge(val);
    val->p.flt = d;
    val->opt = XVALUE_OPT_VALTYPE_FLT;
  }
#endif
  ;
  
void Xvalue_Set_Bool(YOYO_XVALUE *val, int b)
#ifdef _YOYO_XDATA_BUILTIN
  {
    REQUIRE ( val );
    Xvalue_Purge(val);
    val->p.bval = b?1:0;
    val->opt = XVALUE_OPT_VALTYPE_BOOL;
  }
#endif
  ;

void YOYO_XDATA_Drstruct(YOYO_XDATA *self)
#ifdef _YOYO_XDATA_BUILTIN
  {
    int i,j;
    for ( i = 0; i < XNODE_NUMBER_OF_NODE_LISTS; ++i )
      if ( self->nodes[i] )
        {
          for ( j = 0; j < Number_Of_Nodes_In_List(i); ++j )
            {
              YOYO_XNODE *r = self->nodes[i]+j;
              if (((r->opt&XVALUE_OPT_VALTYPE_MASK) == XVALUE_OPT_VALTYPE_STR
                  || (r->opt&XVALUE_OPT_VALTYPE_MASK) == XVALUE_OPT_VALTYPE_BIN ))
                Xvalue_Purge(r);
            }
          free(self->nodes[i]);
        }
    free(names);
    __Unrefe(self->dicto);
    __Destruct(self);
  }
#endif
  ;

void *Xdata_Init()
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XDATA *doc = __Object(sizeof(YOYO_XDATA),YOYO_XDATA_Destruct);
    self->dicto = Dicto_Init();
  }
#endif
  ;

YOYO_XDATA *Xnode_Get_Xdata(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( node->opt&XVALUE_OPT_VALTYPE_MASK != XVALUE_OPT_VALTYPE_NODE )
      __Raise(YOYO_ERROR_INVALID_PARAM,0);
    return node->xdata;
  }
#endif
  ;

#define Xnode_Resolve_Name(Node,Name,Cine) Xdata_Resolve_Node(Node->xdata,name,Cine)
char *Xdata_Resolve_Name(YOYO_XDATA *doc, char *name, int create_if_not_exist)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( name && name > XNODE_MAX_NAME_INDEX_PTR )
      {
        char *q;
        q = Dicto_Get(doc->dicto,name);
        if ( q )
          ;
        else if ( create_if_no_exist )
          {
            char *stored;
            q = (void*)(++doc->last_name);
            STRICT_REQUIRE(idx < XNODE_MAX_NAME_INDEX_PTR);
            stored = Dicto_Put(doc->dicto,name,q);
            doc->names = __Resize_Npl(doc->names,sizeof(char*)*doc->last_name,0);
            doc->names[doc->last_name-1] = stored;
          }
        return q;
      }
    else
      return name;
  }
#endif
  ;

int Xdata_Idxref_No(YOYO_XDOC *doc, ushort_t idx, int *no)
#ifdef _YOYO_XDATA_BUILTIN
  {
    --idx;
    
    if ( idx >= 32 )
      {
        int ref = Min_Pow2(idx);
        *no  = idx - ((1<<ref)-32);
        STRICT_REQUIRE(ref >= 5);
        STRICT_REQUIRE(ref < XNODE_NUMBER_OF_NODE_LISTS+5);
        return ref-5;
      }
    else
      {
        *no = idx;
        return 0;
      }
  }
#endif
  ;

void *Xdata_Idxref(YOYO_XDATA *doc, ushort_t idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( doc );
    STRICT_REQUIRE( idx );
    __Gogo
      {
        int no;
        int ref = Xdata_Idxref_No(doc,idx,&no);
        return doc->nodes[ref]+no;
      }
  }
#endif
  ;

YOYO_XNODE *Xnode_Down(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    return Xdata_Idxref(node->xdata,node->down);
  }
#endif
  ;

YOYO_XNODE *Xnode_Next(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    return Xdata_Idxref(node->xdata,node->next);
  }
#endif
  ;

YOYO_XNODE *Xnode_Last(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XNODE *n;
    
    do
      {
        n = node;
        node = Xnode_Next(node);
      }
    while (node);
    
    return n;
  }
#endif
  ;

void *Xdata_Allocate(YOYO_XDATA *doc, char *name, ushort_t *idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    int no,ref,newidx;
    YOYO_XNODE *n;
    
    STRICT_REQUIRE( doc );
    STRICT_REQUIRE( name );
    STRICT_REQUIRE( idx );
    
    newidx = ++doc->last_node;
    ref = Xdata_Idxref_No(doc,newidx,&no);
    if ( !doc->nodes[ref] )
      {
        int count = sizeof(YOYO_NODE*)*Number_Of_Nodes_In_List(ref);
        doc->nodes[ref] = __Malloc_Npl(count);
        memset(doc->nodes[ref],0xff,count);
      }

    *idx = newidx;
    n = doc->nodes[ref]+no;
    memset(n,0,sizeof(YOYO_XNODE));
    n->name = (ushort_t)Xdata_Resolve_Name(doc,name,1);
    return n;
  }
#endif
  ;

YOYO_XNODE *Xdata_Create_Node(YOYO_XDATA *doc, char *name, ushort_t *idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XNODE *n = Xdata_Allocate(doc,name,idx);
    n->xdata = doc;
    return n;
  }
#endif
  ;

YOYO_XVALUE *Xdata_Create_Value(YOYO_XDATA *doc, char *name, ushort_t *idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XNODE *n = Xdata_Allocate(doc,name,idx);
    n->opt = XVALUE_OPT_VALTYPE_NONE;
    return n;
  }
#endif
  ;

YOYO_XNODE *Xnode_Append(YOYO_XNODE *node, char *name)
#ifdef _YOYO_XDATA_BUILTIN
  {
    ushort_t idx;
    YOYO_XNODE *n;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( name );
    
    node = Xnode_Last(node);
    n = Xdata_Create_Node(node->xdata,name,&idx);
    node->next = idx;
    return n;
  }
#endif
  ;

YOYO_XNODE *Xnode_Insert(YOYO_XNODE *node, char *name)
#ifdef _YOYO_XDATA_BUILTIN
  {
    ushort_t idx;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( name );
    
    YOYO_XNODE *n = Xdata_Create_Node(node->xdata,name,&idx);
    n->next = node->next;
    node->next = idx;
    return n;
  }
#endif
  ;

YOYO_XNODE *Xnode_Down_If(YOYO_XNODE *node, char *name)
#ifdef _YOYO_XDATA_BUILTIN
  {
    return 0;
  }
#endif
  ;

YOYO_XNODE *Xnode_Next_If(YOYO_XNODE *node, char *name)
#ifdef _YOYO_XDATA_BUILTIN
  {
    return 0;
  }
#endif
  ;

#define Xnode_Value_Is_Int(Node,Valname) \
  ((Xnode_Opt_Of_Value(Node,Valname)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_INT)

#define Xnode_Value_Is_Flt(Node,Valname) \
  ((Xnode_Opt_Of_Value(Node,Valname)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_FLT)

#define Xnode_Value_Is_Str(Node,Valname) \
  ((Xnode_Opt_Of_Value(Node,Valname)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_STR)

#define Xnode_Value_Is_None(Node,Valname) \
  ((Xnode_Opt_Of_Value(Node,Valname)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_NONE)

YOYO_XVALUE *Xnode_Query_Value(YOYO_XNODE *node, char *valname, int create_if_not_exist)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *value = 0;
    YOYO_XDATA  *doc;
    ushort_t *next;
    
    STRICT_REQUIRE( node )
    STRICT_REQUIRE( valname );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 )
    
    doc = node->xdata;

    if ( valname > XNODE_MAX_NAME_INDEX_PTR )
      valname = Xdata_Resolve_Name(doc,valname,create_if_not_exist);
    
    next = &node->opt;
    if ( valname ) while ( *next )
      {
        value = (YOYO_XVALUE *)Xdata_Idxref(doc,*next);
        STRICT_REQUIRE( value != 0 );
        if ( value->name == (ushort_t)valname )
          goto found;
        next = &value->next;
      }
    
    STRICT_REQUIRE( !*next );
    if ( create_if_not_exist )
      {
        STRICT_REQUIRE( valname );
        value = Xdata_Create_Value(doc,valname,next);
      }
      
  found:
    return value;
  }
#endif
  ;
  
int Xnode_Opt_Of_Value(void *node, char *valname)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    if ( val )
      return val->opt;
    return 0; 
  }
#endif
  ;
  

int Xnode_Value_Get_Int(void *value, char *valname, int dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    return Xvalue_Get_Int(YOYO_XVALUE *val, int dfltval)
  }
#endif
  ;
  
void Xnode_Value_Set_Int(void *node, char *valname, int i)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,1);
    Xvalue_Set_Int(val,i);
  }
#endif
  ;
  
double Xnode_Value_Get_Flt(void *node, char *valname, double dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    return Xvalue_Get_Flt(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Flt(void *node, char *valname, double d)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,1);
    Xvalue_Set_Flt(val,d);
  }
#endif
  ;
  
char *Xnode_Value_Get_Str(void *node, char *valname, char *dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    return Xvalue_Get_Str(val,dfltval);
  }
#endif
  ;
  
char *Xnode_Value_Copy_Str(void *node, char *valname, char *dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    return Xvalue_Copy_Str(val,dfltval);
  }
#endif
  ;
  
void Xnode_Set_Str(void *node, char *valname, char *S)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val;
    val = Xnode_Query_Value(node,valname,1);
    Xvalue_Set_Str(val,S,-1);
  }
#endif
  ;
  
void Xnode_Value_Put_Str(void *node, char *valname, __Acquire char *S)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val;
    __Pool(S);
    val = Xnode_Query_Value(node,valname,1);
    Xvalue_Put_Str(val,__Retain(S));
  }
#endif
  ;
  
  
#endif /*C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95*/
  
