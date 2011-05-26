
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

#ifndef C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95
#define C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95

#include "core.hc"
#include "string.hc"
#include "dicto.hc"

#define XNODE_MAX_NAME_INDEX_PTR  ((char*)0x07fff)
#define XNODE_NUMBER_OF_NODE_LISTS 9

enum XVALUE_OPT_VALTYPE
  {
    XVALUE_OPT_VALTYPE_NONE     = 0x08000,
    XVALUE_OPT_VALTYPE_INT      = 0x08001,
    XVALUE_OPT_VALTYPE_FLT      = 0x08002,
    XVALUE_OPT_VALTYPE_STR      = 0x08003,
    XVALUE_OPT_VALTYPE_BIN      = 0x08004,
    XVALUE_OPT_VALTYPE_BOOL     = 0x08005,
    XVALUE_OPT_VALTYPE_LIT      = 0x08006,
    XVALUE_OPT_VALTYPE_STR_ARR  = 0x08007,
    XVALUE_OPT_VALTYPE_FLT_ARR  = 0x08008,
    XVALUE_OPT_VALTYPE_MASK     = 0x0800f,
    XVALUE_OPT_IS_VALUE         = 0x08000,
  };

struct _YOYO_XNODE;
struct _YOYO_XDATA;
struct _YOYO_XVALUE_BINARY;

typedef struct _YOYO_XNODE
  {
    ushort_t tag;
    ushort_t opt;
    ushort_t next;
    ushort_t down; 
    union       
      {
        char   *txt;
        double  flt;
        int     dec;
        byte_t  bval;
        YOYO_BUFFER *binary;
        YOYO_ARRAY  *strarr;
        struct _YOYO_XDATA *xdata;
        char   holder[Yo_MAX(sizeof(double),sizeof(void*))];
      };
  } YOYO_XNODE;

typedef YOYO_XNODE YOYO_XVALUE;

typedef struct _YOYO_XDATA
  {
    struct _YOYO_XNODE root;    
    struct _YOYO_XNODE *nodes[XNODE_NUMBER_OF_NODE_LISTS];
    char **tags;
    YOYO_DICTO *dicto;
    ushort_t last_tag;
    ushort_t last_node;
  } YOYO_XDATA;

void *YOYO_XDATA_RAISE_DOESNT_EXIST 
#ifdef _YOYO_XDATA_BUILTIN
  = (void*)-1
#endif
  ;

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
            return Str_From_Int(val->dec,10);
          case XVALUE_OPT_VALTYPE_FLT:          
            return Str_From_Flt(val->flt,0);
          case XVALUE_OPT_VALTYPE_STR:
            return Str_Copy(val->txt,-1);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_Copy((char*)&val->down,-1);
          case XVALUE_OPT_VALTYPE_NONE:
            return Str_Copy("",-1);
          case XVALUE_OPT_VALTYPE_BOOL:
            if ( val->bval )
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
            return val->txt;
          case XVALUE_OPT_VALTYPE_LIT:
            return (char*)&val->down;
          case XVALUE_OPT_VALTYPE_NONE:
            return "";
          case XVALUE_OPT_VALTYPE_BOOL:
            if ( val->bval )
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

YOYO_BUFFER *Xvalue_Get_Binary(YOYO_XVALUE *val)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_BIN:
            return val->binary;
          default:
            __Raise(YOYO_ERROR_UNEXPECTED_VALUE,0);
        }
    return 0;
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
            return val->dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return (int)val->flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Int(val->txt);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Int((char*)&val->down);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          case XVALUE_OPT_VALTYPE_BOOL:
            return val->bval;
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
            return (double)val->dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Flt(val->txt);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Flt((char*)&val->down);
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
            return val->dec?1:0;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->flt?1:0;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Bool(val->txt);
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
        val->txt = Str_Copy_Npl(S,L);
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
    STRICT_REQUIRE( val != 0 );
    STRICT_REQUIRE( S != 0 );
    Xvalue_Purge(val);
    val->txt = S;
    val->opt = XVALUE_OPT_VALTYPE_STR;
  }
#endif
  ;
  
void Xvalue_Put_Binary(YOYO_XVALUE *val, __Acquire YOYO_BUFFER *bf)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( val != 0 );
    STRICT_REQUIRE( bf != 0 );
    Xvalue_Purge(val);
    val->binary = bf;
    val->opt = XVALUE_OPT_VALTYPE_BIN;
  }
#endif
  ;

void Xvalue_Set_Binary(YOYO_XVALUE *val, void *S, int L)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_BUFFER *bf = Buffer_Copy(S,L);
    Xvalue_Put_Binary(val,bf);
  }
#endif
  ;

void Xvalue_Put_Flt_Array(YOYO_XVALUE *val, __Acquire YOYO_BUFFER *bf)
#ifdef _YOYO_XDATA_BUILTIN
  {
    Xvalue_Put_Binary(val,bf);
    val->opt = XVALUE_OPT_VALTYPE_FLT_ARR;
  }
#endif
  ;

void Xvalue_Put_Str_Array(YOYO_XVALUE *val, __Acquire YOYO_ARRAY *arr)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( val != 0 );
    STRICT_REQUIRE( arr != 0 );
    Xvalue_Purge(val);
    val->strarr = arr;
    val->opt = XVALUE_OPT_VALTYPE_STR_ARR;
  }
#endif
  ;

void Xvalue_Set_Int(YOYO_XVALUE *val, int i)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE ( val );
    Xvalue_Purge(val);
    val->dec = i;
    val->opt = XVALUE_OPT_VALTYPE_INT;
  }
#endif
  ;
  
void Xvalue_Set_Flt(YOYO_XVALUE *val, double d)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE ( val );
    Xvalue_Purge(val);
    val->flt = d;
    val->opt = XVALUE_OPT_VALTYPE_FLT;
  }
#endif
  ;
  
void Xvalue_Set_Bool(YOYO_XVALUE *val, int b)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE ( val );
    Xvalue_Purge(val);
    val->bval = b?1:0;
    val->opt = XVALUE_OPT_VALTYPE_BOOL;
  }
#endif
  ;

void YOYO_XDATA_Destruct(YOYO_XDATA *self)
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
    free(self->tags);
    __Unrefe(self->dicto);
    __Destruct(self);
  }
#endif
  ;

void *Xdata_Init()
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XDATA *doc = __Object_Dtor(sizeof(YOYO_XDATA),YOYO_XDATA_Destruct);
    doc->dicto = __Refe(Dicto_Init());
    doc->root.xdata = doc;
    return doc;
  }
#endif
  ;

YOYO_XDATA *Xnode_Get_Xdata(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( node->opt&XVALUE_OPT_IS_VALUE )
      __Raise(YOYO_ERROR_INVALID_PARAM,0);
    return node->xdata;
  }
#endif
  ;

#define Xnode_Resolve_Name(Node,Name,Cine) Xdata_Resolve_Node(Node->xdata,tag,Cine)
char *Xdata_Resolve_Name(YOYO_XDATA *doc, char *tag, int create_if_doesnt_exist)
#ifdef _YOYO_XDATA_BUILTIN
  {
    if ( tag && tag > XNODE_MAX_NAME_INDEX_PTR )
      {
        char *q;
        q = Dicto_Get(doc->dicto,tag,0);
        if ( q )
          ;
        else if ( create_if_doesnt_exist )
          {
            char *stored;
            q = (char*)(longptr_t)(++doc->last_tag);
            STRICT_REQUIRE(q < XNODE_MAX_NAME_INDEX_PTR);
            stored = Dicto_Put(doc->dicto,tag,q);
            doc->tags = __Resize_Npl(doc->tags,sizeof(char*)*doc->last_tag,0);
            doc->tags[doc->last_tag-1] = stored;
          }
        return q;
      }
    else
      return tag;
  }
#endif
  ;

int Xdata_Idxref_No(YOYO_XDATA *doc, ushort_t idx, int *no)
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
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    if ( node->down )
      return Xdata_Idxref(node->xdata,node->down);
  
    return 0;
  }
#endif
  ;

YOYO_XVALUE *Xnode_First_Value(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    if ( node->opt )
      return (YOYO_XVALUE*)Xdata_Idxref(node->xdata,node->opt);
  
    return 0;
  }
#endif
  ;

YOYO_XVALUE *Xnode_Next_Value(YOYO_XNODE *node, YOYO_XVALUE *value)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( value );
    STRICT_REQUIRE( (value->opt&XVALUE_OPT_IS_VALUE) != 0 );

    if ( value->next )
      return (YOYO_XVALUE*)Xdata_Idxref(node->xdata,value->next);
  
    return 0;
  }
#endif
  ;

YOYO_XNODE *Xnode_Next(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    if ( node->next )
      {
        YOYO_XNODE *n = Xdata_Idxref(node->xdata,node->next);
        STRICT_REQUIRE( n != node );
        return n;
      }
      
    return 0;
  }
#endif
  ;

YOYO_XNODE *Xnode_Last(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XNODE *n = 0;

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    node = Xnode_Down(node);
    
    while ( node ) 
      {
        n = node;
        node = Xnode_Next(node);
      }
    
    return n;
  }
#endif
  ;

void *Xdata_Allocate(YOYO_XDATA *doc, char *tag, ushort_t *idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    int no,ref,newidx;
    YOYO_XNODE *n;
    
    STRICT_REQUIRE( doc );
    STRICT_REQUIRE( tag );
    STRICT_REQUIRE( idx );
    
    newidx = ++doc->last_node;
    ref = Xdata_Idxref_No(doc,newidx,&no);
    if ( !doc->nodes[ref] )
      {
        int count = sizeof(YOYO_XNODE)*Number_Of_Nodes_In_List(ref);
        doc->nodes[ref] = __Malloc_Npl(count);
        memset(doc->nodes[ref],0xff,count);
      }

    *idx = newidx;
    n = doc->nodes[ref]+no;
    memset(n,0,sizeof(YOYO_XNODE));
    n->tag = (ushort_t)(longptr_t)Xdata_Resolve_Name(doc,tag,1);
    return n;
  }
#endif
  ;

YOYO_XNODE *Xdata_Create_Node(YOYO_XDATA *doc, char *tag, ushort_t *idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XNODE *n = Xdata_Allocate(doc,tag,idx);
    n->xdata = doc;
    return n;
  }
#endif
  ;

YOYO_XVALUE *Xdata_Create_Value(YOYO_XDATA *doc, char *tag, ushort_t *idx)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XNODE *n = Xdata_Allocate(doc,tag,idx);
    n->opt = XVALUE_OPT_VALTYPE_NONE;
    return n;
  }
#endif
  ;

YOYO_XNODE *Xnode_Append(YOYO_XNODE *node, char *tag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    ushort_t idx;
    YOYO_XNODE *n;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( tag );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    n = Xdata_Create_Node(node->xdata,tag,&idx);

    if ( node->down )
      {
        YOYO_XNODE *last = Xnode_Last(node);
        last->next = idx;
      }
    else
      {
        node->down = idx;
      }

    STRICT_REQUIRE( n->next != idx );
    return n;
  }
#endif
  ;

YOYO_XNODE *Xnode_Insert(YOYO_XNODE *node, char *tag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    ushort_t idx;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( tag );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    YOYO_XNODE *n = Xdata_Create_Node(node->xdata,tag,&idx);
    n->next = node->down;
    node->down = idx;
    
    STRICT_REQUIRE( n->next != idx );
    
    return n;
  }
#endif
  ;

YOYO_XNODE *Xnode_Down_If(YOYO_XNODE *node, char *tag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    return 0;
  }
#endif
  ;

YOYO_XNODE *Xnode_Next_If(YOYO_XNODE *node, char *tag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    return 0;
  }
#endif
  ;

char *Xnode_Get_Tag(YOYO_XNODE *node)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XDATA *doc;
     
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( node->tag > 0 && node->tag <= node->xdata->last_tag );

    return node->xdata->tags[node->tag-1];
  }
#endif
  ;
  
char *Xnode_Value_Get_Tag(YOYO_XNODE *node,YOYO_XVALUE *value)
#ifdef _YOYO_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( value );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( (value->opt&XVALUE_OPT_IS_VALUE) != 0 );
    STRICT_REQUIRE( value->tag > 0 && value->tag <= node->xdata->last_tag );
    
    return node->xdata->tags[value->tag-1];
  }
#endif
  ;

#define Xnode_Value_Is_Int(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_INT)

#define Xnode_Value_Is_Flt(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_FLT)

#define Xnode_Value_Is_Str(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_STR)

#define Xnode_Value_Is_None(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_NONE)

YOYO_XVALUE *Xnode_Value(YOYO_XNODE *node, char *valtag, int create_if_not_exist)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *value = 0;
    YOYO_XDATA  *doc;
    ushort_t *next;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( valtag );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    doc = node->xdata;

    if ( valtag > XNODE_MAX_NAME_INDEX_PTR )
      valtag = Xdata_Resolve_Name(doc,valtag,create_if_not_exist);
    
    next = &node->opt;
    if ( valtag ) while ( *next )
      {
        value = (YOYO_XVALUE *)Xdata_Idxref(doc,*next);
        STRICT_REQUIRE( value != 0 );
        if ( value->tag == (ushort_t)(longptr_t)valtag )
          goto found;
        next = &value->next;
      }
    
    STRICT_REQUIRE( !*next );
    if ( create_if_not_exist )
      {
        STRICT_REQUIRE( valtag );
        value = Xdata_Create_Value(doc,valtag,next);
      }
      
  found:
    return value;
  }
#endif
  ;
  
int Xnode_Opt_Of_Value(void *node, char *valtag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    if ( val )
      return val->opt;
    return 0; 
  }
#endif
  ;
  

int Xnode_Value_Get_Int(void *node, char *valtag, int dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Int(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Int(void *node, char *valtag, int i)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Int(val,i);
  }
#endif
  ;
  
double Xnode_Value_Get_Flt(void *node, char *valtag, double dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Flt(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Flt(void *node, char *valtag, double d)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Flt(val,d);
  }
#endif
  ;
  
char *Xnode_Value_Get_Str(void *node, char *valtag, char *dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Str(val,dfltval);
  }
#endif
  ;
  
char *Xnode_Value_Copy_Str(void *node, char *valtag, char *dfltval)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Copy_Str(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Str(void *node, char *valtag, char *S)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val;
    val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Str(val,S,-1);
  }
#endif
  ;
  
void Xnode_Value_Put_Str(void *node, char *valtag, __Acquire char *S)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val;
    __Pool(S);
    val = Xnode_Value(node,valtag,1);
    Xvalue_Put_Str(val,__Retain(S));
  }
#endif
  ;
  
void Xnode_Value_Put_Binary(void *node,char *valtag, YOYO_BUFFER *bf)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    Xvalue_Put_Binary(val,__Refe(bf));
  }
#endif
  ;

void Xnode_Value_Set_Binary(void *node,char *valtag, void *data, int len)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    Xvalue_Set_Binary(val,data,len);
  }
#endif
  ;
  
YOYO_BUFFER *Xnode_Value_Get_Binary(void *node,char *valtag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Binary(val);
  }
#endif
  ;
  
YOYO_BUFFER *Xnode_Value_Copy_Binary(void *node,char *valtag)
#ifdef _YOYO_XDATA_BUILTIN
  {
    int lenout = 0;
    YOYO_XVALUE *val = Xnode_Value(node,valtag,0);
    YOYO_BUFFER *bf = Xvalue_Get_Binary(val);
    if ( bf )
      return Buffer_Copy(bf->at,bf->count);
    return 0;
  }
#endif
  ;

#endif /*C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95*/
  
