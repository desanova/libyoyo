
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

#define XNODE_MAX_NAME_INDEX_PTR  ((void*)0x0ffff)
#define XNODE_NUMBER_OF_NODE_LISTS 10

enum XVALUE_OPT_VALTYPE
  {
    XVALUE_OPT_VALTYPE_NONE   = 0,
    XVALUE_OPT_VALTYPE_INT    = 1,
    XVALUE_OPT_VALTYPE_FLT    = 2,
    XVALUE_OPT_VALTYPE_STR    = 3,
    XVALUE_OPT_VALTYPE_NODE   = 7,
    XVALUE_OPT_VALTYPE_MASK   = 7,
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
    int last_name;
    int last_node;
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

void YOYO_XDATA_Drstruct(YOYO_XDATA *self)
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
                Xnode_Purge_Value(r);
            }
          free(self->nodes[i]);
        }
    free(names);
    __Unrefe(self->dicto);
    __Destruct(self);
  }

void *Xdata_Init()
  {
    YOYO_XDATA *doc = __Object(sizeof(YOYO_XDATA),YOYO_XDATA_Destruct);
    self->dicto = Dicto_Init();
  }

YOYO_XDATA *Xnode_Get_Xdata(YOYO_XNODE *node)
  {
    if ( node->opt&XVALUE_OPT_VALTYPE_MASK != XVALUE_OPT_VALTYPE_NODE )
      __Raise(YOYO_ERROR_INVALID_PARAM,0);
    return node->xdata;
  }

char *Xnode_Resolve_Name(YOYO_XNODE *node, char *name, int create_if_not_exist)
  {
    if ( name && name > XNODE_MAX_NAME_INDEX_PTR )
      {
        char *q;
        YOYO_XDATA *doc = node->xdata;
        q = Dicto_Get(doc->dicto,name);
        if ( q )
          ;
        else if ( create_if_no_exist )
          {
            char *stored;
            q = (void*)(++doc->last_name);
            REQUIRE(idx < XNODE_MAX_NAME_INDEX_PTR);
            stored = Dicto_Put(doc->dicto,name,q);
            doc->names = __Resize_Npl(doc->names,sizeof(char*)*doc->last_name,0);
            doc->names[doc->last_name-1] = stored;
          }
        return q;
      }
    else
      return name;
  }

int Xnode_Idxref_No(YOYO_XDOC *doc, ushort_t idx, int *no)
  {
    --idx;
    
    if ( idx >= 32 )
      {
        int ref = Min_Pow2(idx);
        *no  = idx - ((1<<ref)-32);
        REQUIRE(ref >= 5);
        REQUIRE(ref < XNODE_NUMBER_OF_NODE_LISTS+5);
        return ref-5;
      }
    else
      {
        *no = idx;
        return 0;
      }
  }

YOYO_XNODE *Xnode_Idxref(YOYO_XNODE *node, ushort_t idx)
  {
    if ( node && idx )
      {
        int no;
        int ref = Xnode_Idxref_No(node->xdata,idx,&no);
        return node->xdata->nodes[ref]+no;
      }
    return 0;
  }

YOYO_XNODE *Xnode_Down(YOYO_XNODE *node)
  {
    return Xnode_Idxref(node,node->down);
  }

YOYO_XNODE *Xnode_Next(YOYO_XNODE *node)
  {
    return Xnode_Idxref(node,node->next);
  }

YOYO_XNODE *Xnode_Last(YOYO_XNODE *node)
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

YOYO_XNODE *Xnode_Create_Node(YOYO_XDATA *doc, char *name, ushort_t *idx)
  {
    int no;
    int ref = Xnode_Idxref_No(doc,idx,&no);
  }

YOYO_XNODE *Xnode_Append(YOYO_XNODE *node, char *name)
  {
    ushort_t idx;
    YOYO_XNODE *n;
    
    node = Xnode_Last(node);
    n = Xnode_Create_Node(node->xdata,name,&idx);
    node->next = idx;
    return n;
  }

YOYO_XNODE *Xnode_Insert(YOYO_XNODE *node, char *name)
  {
    ushort_t idx;
    YOYO_XNODE *n = Xnode_Create_Node(node->xdata,name,&idx);
    n->next = node->next;
    node->next = idx;
    return n;
  }

YOYO_XNODE *Xnode_Down_If(YOYO_XNODE *node, char *name)
  {
  }

YOYO_XNODE *Xnode_Next_If(YOYO_XNODE *node, char *name)
  {
  }

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
  {
    if ( valname > XNODE_MAX_NAME_INDEX_PTR )
      valname = Xnode_Resolve_Name(node,valname,create_if_not_exist);
  }
  
int Xnode_Opt_Of_Value(void *node, char *valname)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    if ( val )
      return val->opt;
    return 0; 
  }
  
int Xnode_Get_Int(void *node, char *valname, int dfltval)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return val->p.dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return (int)val->p.flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Int(val->p.txt,0);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
  
void Xnode_Set_Int(void *node, char *valname, int i)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,1);
    Xnode_Purge_Value(val);
    val->p.dec = i;
  }
  
double Xnode_Get_Flt(void *node, char *valname, double dfltval)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return (double)val->p.dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->p.flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Flt(val->p.txt,0);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
  
void Xnode_Set_Flt(void *node, char *valname, double d)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,1);
    Xnode_Purge_Value(val);
    val->p.flt = d;
  }
  
char *Xnode_Get_Str(void *node, char *valname, char *dfltval)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_STR:
            return val->p.text;
          case XVALUE_OPT_VALTYPE_NONE:
            return "";
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
  
char *Xnode_Copy_Str(void *node, char *valname, char *dfltval)
  {
    YOYO_XVALUE *val = Xnode_Query_Value(node,valname,0);
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return Str_From_Int(val->p.dec,10);
          case XVALUE_OPT_VALTYPE_FLT:          
            return Str_From_Flt(val->p.flt,0);
          case XVALUE_OPT_VALTYPE_STR:
            return Str_Copy(val->p.txt,-1);
          case XVALUE_OPT_VALTYPE_NONE:
            return Str_Copy("",-1);
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
  
void Xnode_Take_Str(void *node, char *valname, __Acquire char *S)
  {
    YOYO_XVALUE *val;
    __Pool(S);
    val = Xnode_Query_Value(node,valname,1);
    Xnode_Purge_Value(val);
    val->p.txt = __Retain(S);
  }
  
void Xnode_Set_Str(void *node, char *valname, char *S)
  {
    Xnode_Take_Str(node,valname,Str_Copy_Npl(S,-1));
  }
  
#endif /*C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95*/

