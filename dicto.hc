
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

#ifndef C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203
#define C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203

#ifdef _LIBYOYO
#define _YOYO_DICTO_BUILTIN
#endif

#include "yoyo.hc"
#include "crc.hc"

typedef struct _YOYO_DICTO_REC
  {
    struct _YOYO_DICTO_REC *next;
    void *ptr;
    byte_t hashcode;
    char key[1];
  } YOYO_DICTO_REC;

typedef struct _YOYO_DICTO
  {
    struct _YOYO_DICTO_REC **table; 
    int count;
    int width;
  } YOYO_DICTO;


#define Dicto_Count(Dicto) ((int)((YOYO_DICTO*)(Dicto))->count+0)
  void Dicto_Rehash(YOYO_DICTO *o);

#ifdef _YOYO_DICTO_BUILTIN  
int Dicto_Width_Values[] = {5,11,23,47,97,181,256};
#endif

YOYO_DICTO_REC **Dicto_Backet(YOYO_DICTO *o, byte_t hashcode, char *key)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    YOYO_DICTO_REC **nrec;
    
    if ( !o->table )
      {
        o->width = Dicto_Width_Values[0];
        o->table = Yo_Malloc_Npl(o->width*sizeof(void*));
        memset(o->table,0,o->width*sizeof(void*));
      }
      
    nrec = &o->table[hashcode%o->width];
    
    while ( *nrec )
      {
        if ( hashcode == (*nrec)->hashcode && !strcmp((*nrec)->key,key) )
          break;
        nrec = &(*nrec)->next;
      }
    
    return nrec;
  }
#endif
  ;

YOYO_DICTO_REC *Dicto_Allocate(char *key)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    int keylen = strlen(key);
    YOYO_DICTO_REC *Q = Yo_Malloc_Npl(sizeof(YOYO_DICTO_REC) + keylen);
    memcpy(Q->key,key,keylen+1);
    Q->hashcode = Crc_8_Of_Cstr(key);
    Q->next = 0;
    Q->ptr = 0;
    return Q;
  }
#endif
  ;

void *Dicto_Get(YOYO_DICTO *o, char *key, void *dflt)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Crc_8_Of_Cstr(key);
        YOYO_DICTO_REC *Q = *Dicto_Backet(o,hashcode,key);
        if ( Q )
          return Q->ptr;
      }
    return dflt;
  }
#endif
  ;

void *Dicto_Get_Key_Ptr(YOYO_DICTO *o, char *key)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Crc_8_Of_Cstr(key);
        YOYO_DICTO_REC *Q = *Dicto_Backet(o,hashcode,key);
        if ( Q )
          return Q->key;
      }
    return 0;
  }
#endif
  ;

int Dicto_Has(YOYO_DICTO *o, char *key)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Crc_8_Of_Cstr(key);
        if ( *Dicto_Backet(o,hashcode,key) )
          return 1;
      }
    return 0;
  }
#endif
  ;

void *Dicto_Put(YOYO_DICTO *o, char *key, void *val)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Crc_8_Of_Cstr(key);
        YOYO_DICTO_REC **Q = Dicto_Backet(o,hashcode,key);
        if ( *Q )
          {
            YOYO_DICTO_REC *p = *Q;
            void *self = o;
            void (*destructor)(void*) = Yo_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
            if ( destructor )
              (*destructor)(p->ptr);
            p->ptr = val;
            key = (*Q)->key;
          }
        else
          {
            *Q = Dicto_Allocate(key);
            key = (*Q)->key;
            (*Q)->ptr = val;
            ++o->count;
            if ( o->count > o->width*3 )
              Dicto_Rehash(o);
          }
        return key;
      }
    else
      return 0;
  }
#endif
  ;

void Dicto_Del(YOYO_DICTO *o, char *key)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Crc_8_Of_Cstr(key);
        YOYO_DICTO_REC **Q = Dicto_Backet(o,hashcode,key);
        if ( *Q )
          {
            YOYO_DICTO_REC *p = *Q;
            void *self = o;
            void (*destructor)(void*) = Yo_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
            if ( destructor )
              (*destructor)(p->ptr);
            *Q = (*Q)->next;
            free(p);
            STRICT_REQUIRE ( o->count >= 1 );
            --o->count;
          }
      }
  }
#endif
  ;

/* returns unmanaged value */
void *Dicto_Take_Npl(YOYO_DICTO *o, char *key)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Crc_8_Of_Cstr(key);
        YOYO_DICTO_REC **Q = Dicto_Backet(o,hashcode,key);
        if ( *Q )
          {
            YOYO_DICTO_REC *p = *Q;
            void *ret = p->ptr;
            *Q = (*Q)->next;
            free(p);
            STRICT_REQUIRE ( o->count >= 1 );
            --o->count;
            return ret;
          }
      }
    return 0;
  }
#endif
  ;

void *Dicto_Take(YOYO_DICTO *o, char *key)
#ifdef _YOYO_ARRAY_BUILTIN
  {
    void *self = o;
    void (*destruct)(void *) = Yo_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,YO_RAISE_ERROR);
    void *Q = Dicto_Take_Npl(o,key);
    
    if ( Q )
      Yo_Pool_Ptr(Q,destruct);
      
    return Q;
  }
#endif
  ;

void Dicto_Clear(YOYO_DICTO *o)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    int i;
    void *self = o;
    void (*destructor)(void*) = Yo_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
    
    if ( o->table )
      for ( i = 0; i < o->width; ++i )
        while ( o->table[i] )
          {
            YOYO_DICTO_REC *Q = o->table[i];
            o->table[i] = Q->next;
            if ( destructor )
              (*destructor)(Q->ptr);
            free(Q);
          }

    if ( o->table ) free( o->table );
    o->table = 0;
    o->width = 0;
    o->count = 0;      
  }
#endif
  ;

#ifdef _YOYO_DICTO_BUILTIN  
void Dicto_Rehash(YOYO_DICTO *o)
  {
    if ( o->table && o->count )
      {
        int i;
        int width = 256;
        YOYO_DICTO_REC **table;
        
        for ( i = 0; Dicto_Width_Values[i] < 256; ++i )
          if ( o->count <= Dicto_Width_Values[i] + Dicto_Width_Values[i]/2  )
            {
              width = Dicto_Width_Values[i]; 
              break;
            }
        
        if ( width > o->width ) 
          {
            table = Yo_Malloc_Npl(width*sizeof(void*));
            memset(table,0,width*sizeof(void*));
        
            for ( i = 0; i < o->width; ++i )
              while ( o->table[i] )
                {
                  YOYO_DICTO_REC *Q = o->table[i];
                  o->table[i] = Q->next;
                  Q->next = table[Q->hashcode%width];
                  table[Q->hashcode%width] = Q;
                }
      
            free(o->table);
            o->width = width;
            o->table = table;    
          }
      }
  }
#endif
  ;

void Dicto_Destruct(YOYO_DICTO *o)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    Dicto_Clear(o);
    Yo_Object_Destruct(o);
  }
#endif
  ;

void *Dicto_Refs(void)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID, Dicto_Destruct},
        {Oj_Destruct_Element_OjMID, Yo_Unrefe},
        {0}};
    YOYO_DICTO *dicto = Yo_Object(sizeof(YOYO_DICTO),funcs);
    return dicto;
  }
#endif
  ;

void *Dicto_Ptrs(void)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID, Dicto_Destruct},
        {Oj_Destruct_Element_OjMID, free},
        {0}};
    YOYO_DICTO *dicto = Yo_Object(sizeof(YOYO_DICTO),funcs);
    return dicto;
  }
#endif
  ;

void *Dicto_Init(void)
#ifdef _YOYO_DICTO_BUILTIN  
  {
    YOYO_DICTO *dicto = Yo_Object_Dtor(sizeof(YOYO_DICTO),Dicto_Destruct);
    return dicto;
  }
#endif
  ;

#endif /* C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203 */

