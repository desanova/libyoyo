
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

#ifndef C_once_6973F3BA_26FA_434D_9ED9_FF5389CE421C
#define C_once_6973F3BA_26FA_434D_9ED9_FF5389CE421C

/* markers */
#define __Acquire /* a function acquire the ownership of argument */

#ifndef __yoTa
# define __yoTa(Text,NumId) Text
#endif

#define __FOUR_CHARS(C1,C2,C3,C4) ((uint_t)(C4)<<24)|((uint_t)(C3)<<16)|((uint_t)(C2)<<8)|((uint_t)(C1))
#define __USE_GNU

#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>
#include <time.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <limits.h>
#include <wctype.h>
#include <wchar.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <locale.h>

#if defined __WIN32 || defined _MSC_VER || defined __MINGW32_VERSION
# define __windoze
# if !defined _WINDOWS_
#  if !defined _X86_ 
#   if !defined __x86_64 && !defined __i386__
#     define _X86_ 1
#   endif
#  endif
# endif
# if !defined WINVER
#  define WINVER 0x500
# endif
# include <windef.h>
# include <winbase.h>
# include <excpt.h>
# include <objbase.h>
# include <io.h>
# include <malloc.h> /* alloca */
# define backtrace(Ptrs,Lim) (0)
#else
# include <unistd.h>
# include <dlfcn.h>
# if defined __APPLE__
#   include <execinfo.h> /* backtrace */
# else
#   define backtrace(Ptrs,Lim) (0)
# endif
# if defined __APPLE__
#   include <malloc/malloc.h> /* malloc_size */
# elif defined __NetBSD__ && !defined _NBSDHACK
/*
  NetBSD has malloc_usable_size commented
  you need to manually modify & rebuild libc
*/
#   ifndef _NBSDMUTE
#     warning {! NetBSD has malloc_usable_size commented !}
#   endif
#   define malloc_size(Ptr) (0)
# else 
#   define malloc_size(Ptr) malloc_usable_size(Ptr)
# endif
#endif

typedef unsigned char  byte_t;
typedef unsigned short ushort_t;
typedef unsigned int   uint_t;
typedef unsigned long  ulong_t;

#ifndef __windoze
  typedef unsigned long long  uquad_t;
# if defined __APPLE__
    typedef long long  quad_t;
# endif
#else
  typedef unsigned __int64  uquad_t;
  typedef __int64  quad_t;
#endif

#ifdef __x86_64
  typedef uint_t   halflong_t;
  typedef ulong_t  longptr_t;
#else
  typedef ushort_t halflong_t;
  typedef ulong_t  longptr_t;
#endif

#ifndef _NO__FILE__
# define __Yo_FILE__ __FILE__
# define __Yo_Expr__(Expr) #Expr
# define Yo_Raise(Error,Msg,File,Line) _Yo_Raise(Error,Msg,File,Line)
# define Yo_Fatal(Error,Msg,File,Line) _Yo_Fatal(Error,Msg,File,Line)
#else
# define __Yo_FILE__ 0
# define __Yo_Expr__(Expr) 0
# define Yo_Raise(Error,Msg,File,Line) _Yo_Raise(Error,0,0,0)
# define Yo_Fatal(Error,Msg,File,Line) _Yo_Fatal(Error,0,0,0)
#endif

#define Yo_MIN(a,b) ( (a) < (b) ? (a) : (b) )
#define Yo_MAX(a,b) ( (a) > (b) ? (a) : (b) )

#define YOYO_COMPOSE2(a,b) a##b
#define YOYO_COMPOSE3(a,b,c) a##b##_##c
#define YOYO_ID(Name,Line) YOYO_COMPOSE3(_YoYo_Label_,Name,Line)
#define YOYO_LOCAL_ID(Name) YOYO_ID(Name,__LINE__)

#ifdef _YOYO_CORE_BUILTIN
# define _YOYO_CORE_BUILTIN_CODE(Code) Code
# define _YOYO_CORE_EXTERN 
#else
# define _YOYO_CORE_BUILTIN_CODE(Code)
# define _YOYO_CORE_EXTERN extern 
#endif

_YOYO_CORE_EXTERN char Oj_Destruct_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = "~/@" );
_YOYO_CORE_EXTERN char Oj_Destruct_Element_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = "~1/@" );
_YOYO_CORE_EXTERN char Oj_Compare_Elements_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = "?2/**" );
_YOYO_CORE_EXTERN char Oj_Compare_Keys_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = "?3/**" );
_YOYO_CORE_EXTERN char Oj_Clone_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = "$=/@" );
_YOYO_CORE_EXTERN char Oj_Count_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = "$#/@" );
_YOYO_CORE_EXTERN char Oj_Set_Key_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">+S>/@*" );
_YOYO_CORE_EXTERN char Oj_Find_Key_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">?S>/@*" );
_YOYO_CORE_EXTERN char Oj_Take_Key_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">-S>/@*" );
_YOYO_CORE_EXTERN char Oj_Del_Key_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">~S>/@*" );
_YOYO_CORE_EXTERN char Oj_Set_Lkey_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">+L>/@L" );
_YOYO_CORE_EXTERN char Oj_Find_Lkey_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">?L>/@L" );
_YOYO_CORE_EXTERN char Oj_Take_Lkey_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">-L>/@L" );
_YOYO_CORE_EXTERN char Oj_Del_Lkey_OjMID[] _YOYO_CORE_BUILTIN_CODE ( = ">~L>/@L" );

enum
  {
    KILOBYTE = 1024,
    MEGABYTE = 1024*KILOBYTE,
    GIGABYTE = 1024*MEGABYTE,
  };

enum _YOYO_ERRORS
  {
    YOYO_FATAL_ERROR_GROUP          = 0x70000000,
    YOYO_USER_ERROR_GROUP           = 0x00010000,
    YOYO_IO_ERROR_GROUP             = 0x00020000,
    YOYO_TCPIP_ERROR_GROUP          = 0x00040000,
    YOYO_RUNTIME_ERROR_GROUP        = 0x00080000,
    YOYO_SELFCHECK_ERROR_GROUP      = 0x00100000,
    YOYO_ENCODING_ERROR_GROUP       = 0x00200000,
    YOYO_ILLFORMED_ERROR_GROUP      = 0x00400000,
    YOYO_RANGE_ERROR_GROUP          = 0x00800000,
    YOYO_CORRUPTED_ERROR_GROUP      = 0x01000000,
    YOYO_STORAGE_ERROR_GROUP        = 0x02000000,
    
    YOYO_XXXX_ERROR_GROUP           = 0x7fff0000,
    YO_RERAISE_CURRENT_ERROR        = 0x7fff7fff,
    
    YOYO_TRACED_ERROR_GROUP     = YOYO_FATAL_ERROR_GROUP
                                |YOYO_RANGE_ERROR_GROUP
                                |YOYO_SELFCHECK_ERROR_GROUP,
    
    YOYO_ERROR_BASE             = 0x00008000,
    
    YOYO_ERROR_OUT_OF_MEMORY    = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+1),
    YOYO_FATAL_ERROR            = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+2),
    YOYO_ERROR_DYNCO_CORRUPTED  = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+3),
    YOYO_ERROR_METHOD_NOT_FOUND = YOYO_RUNTIME_ERROR_GROUP|(YOYO_ERROR_BASE+4),
    YOYO_ERROR_REQUIRE_FAILED   = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+5),
    YOYO_ERROR_ILLFORMED        = YOYO_ILLFORMED_ERROR_GROUP|(YOYO_ERROR_BASE+6),
    YOYO_ERROR_OUT_OF_POOL      = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+7),
    YOYO_ERROR_UNEXPECTED       = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+8),
    YOYO_ERROR_OUT_OF_RANGE     = YOYO_RANGE_ERROR_GROUP|(YOYO_ERROR_BASE+9),
    YOYO_ERROR_NULL_PTR         = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+10),
    YOYO_ERROR_CORRUPTED        = YOYO_CORRUPTED_ERROR_GROUP|(YOYO_ERROR_BASE+11),
    YOYO_ERROR_IO               = YOYO_IO_ERROR_GROUP|(YOYO_ERROR_BASE+12),
    YOYO_ERROR_UNSORTABLE       = YOYO_RUNTIME_ERROR_GROUP|(YOYO_ERROR_BASE+13),
    YOYO_ERROR_DOESNT_EXIST     = YOYO_IO_ERROR_GROUP|(YOYO_ERROR_BASE+14),
    YOYO_ERROR_ACCESS_DENAIED   = YOYO_IO_ERROR_GROUP|(YOYO_ERROR_BASE+15),
    YOYO_ERROR_NO_ENOUGH        = YOYO_ILLFORMED_ERROR_GROUP|(YOYO_ERROR_BASE+16),
    YOYO_ERROR_UNALIGNED        = YOYO_ILLFORMED_ERROR_GROUP|(YOYO_ERROR_BASE+17),
    YOYO_ERROR_COMPRESS_DATA    = YOYO_ENCODING_ERROR_GROUP|(YOYO_ERROR_BASE+18),
    YOYO_ERROR_ENCRYPT_DATA     = YOYO_ENCODING_ERROR_GROUP|(YOYO_ERROR_BASE+19),
    YOYO_ERROR_DECOMPRESS_DATA  = YOYO_ENCODING_ERROR_GROUP|(YOYO_ERROR_BASE+20),
    YOYO_ERROR_DECRYPT_DATA     = YOYO_ENCODING_ERROR_GROUP|(YOYO_ERROR_BASE+21),
    YOYO_ERROR_INVALID_PARAM    = YOYO_RUNTIME_ERROR_GROUP|(YOYO_ERROR_BASE+22),
    YOYO_ERROR_UNEXPECTED_VALUE = YOYO_FATAL_ERROR_GROUP|(YOYO_ERROR_BASE+23),
    YOYO_ERROR_ALREADY_EXISTS   = YOYO_IO_ERROR_GROUP|(YOYO_ERROR_BASE+24),
    YOYO_ERROR_INCONSISTENT     = YOYO_STORAGE_ERROR_GROUP|(YOYO_ERROR_BASE+25),
    YOYO_ERROR_TO_BIG           = YOYO_STORAGE_ERROR_GROUP|(YOYO_ERROR_BASE+26),
  };

#define YOYO_ERROR_IS_USER_ERROR(err) !(err&YOYO_XXXX_ERROR_GROUP)

enum _YOYO_FLAGS
  {
    YO_RAISE_ERROR            = 0x70000000,
    YO_PRINT_FLUSH            = 1,
    YO_PRINT_NEWLINE          = 2,
  };

void _Yo_Fatal(int err,void *ctx,char *filename,int lineno);
void _Yo_Raise(int err,char *msg,char *filename,int lineno);

#ifndef _THREADS

# define Yo_Atomic_Increment(Ptr) (++*(Ptr))
# define Yo_Atomic_Decrement(Ptr) (--*(Ptr))
# define Yo_Atomic_CmpXchg(Ptr,Val,Comp) ( *(Ptr) == (Comp) ? (*(Ptr) = (Val), 1) : 0 )
# define Yo_Atomic_CmpXchg_Ptr(Ptr,Val,Comp) ( *(Ptr) == (Comp) ? (*(Ptr) = (Val), 1) : 0 )
# define Yo_Wait_Xchg_Lock(Ptr)
# define Yo_Xchg_Unlock(Ptr)  
# define YO_TLS_DEFINE(Name)  void * volatile Name = 0
# define YO_TLS_DECLARE(Name) extern void * volatile Name
# define Yo_Tls_Set(Name,Val) ((Name) = (Val))
# define Yo_Tls_Get(Name)     (Name)
# define YO_MULTITHREADED(Expr)
# define __Xchg_Interlock if (0) {;} else
# define __Xchg_Sync(Lx)  if (0) {;} else

#else

# define _xchg_YOYO_LOCAL_LX static int volatile YOYO_LOCAL_ID(lx)
# define _xchg_YOYO_LOCAL_ID_REF &YOYO_LOCAL_ID(lx)
# define __Xchg_Interlock \
              __Interlock_Opt( _xchg_YOYO_LOCAL_LX, _xchg_YOYO_LOCAL_ID_REF, \
                  Yo_Wait_Xchg_Lock,Yo_Xchg_Unlock,Yo_Xchg_Unlock_Proc)

# define __Xchg_Sync(Lx) \
              __Interlock_Opt(((void)0),Lx, \
                  Yo_Wait_Xchg_Lock,Yo_Xchg_Unlock,Yo_Xchg_Unlock_Proc)

# define Yo_Wait_Xchg_Lock(Ptr) while ( !Yo_Atomic_CmpXchg(Ptr,1,0) ) Yo_Switch_to_Thread()
# define Yo_Xchg_Unlock(Ptr) Yo_Atomic_CmpXchg(Ptr,0,1)

void Yo_Xchg_Unlock_Proc(int volatile *p) _YOYO_CORE_BUILTIN_CODE({Yo_Atomic_CmpXchg(p,0,1);});

#endif

#define REQUIRE(Expr) \
  if (Expr); else Yo_Fatal(YOYO_ERROR_REQUIRE_FAILED,__Yo_Expr__(Expr),__Yo_FILE__,__LINE__)
#define PANICA(msg) Yo_Fatal(YOYO_FATAL_ERROR,msg,__Yo_FILE__,__LINE__)

#ifdef _STRICT
# define STRICT_REQUIRE(Expr) REQUIRE(Expr)
# define STRICT_CHECK(Expr) (Expr)
#else
# define STRICT_REQUIRE(Expr) ((void)0)
# define STRICT_CHECK(Expr) (1)
#endif /* _STRICT */

uint_t Two_To_Unsigned(void *b)
#ifdef _YOYO_CORE_BUILTIN
  {
    uint_t q =   (unsigned int)((unsigned char*)b)[0]
              | ((unsigned int)((unsigned char*)b)[1] << 8);
    return q;
  }
#endif
  ;

uint_t Four_To_Unsigned(void *b)
#ifdef _YOYO_CORE_BUILTIN
  {
    uint_t q =   (unsigned int)((unsigned char*)b)[0]
              | ((unsigned int)((unsigned char*)b)[1] << 8)
              | ((unsigned int)((unsigned char*)b)[2] << 16)
              | ((unsigned int)((unsigned char*)b)[3] << 24);
    return q;
  }
#endif
  ;

void Unsigned_To_Four(uint_t q, void *b)
#ifdef _YOYO_CORE_BUILTIN
  {
    byte_t *p = b;
    p[0] = (byte_t)q;
    p[1] = (byte_t)(q>>8);
    p[2] = (byte_t)(q>>16);
    p[3] = (byte_t)(q>>24);
  }
#endif
  ;

void Unsigned_To_Two(uint_t q, void *b)
#ifdef _YOYO_CORE_BUILTIN
  {
    byte_t *p = b;
    p[0] = (byte_t)q;
    p[1] = (byte_t)(q>>8);
  }
#endif
  ;

uint_t Bitcount_8(uint_t q)
#ifdef _YOYO_CORE_BUILTIN
  {
    static byte_t Q[256]= {0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4,
                           5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
                           6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
                           6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
                           7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 
                           7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
                           7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 
                           7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 
                           8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                          };
    return Q[q&0x0ff];
  }
#endif
  ;
  
uint_t Bitcount_Of( uint_t u )
#ifdef _YOYO_CORE_BUILTIN
    {
      int i;
      uint_t q;
      if ( u )
        for ( i = sizeof(u)*8-8; i >= 0; i-=8 )
          if ( !!(q = Bitcount_8(u>>i)) )
            return q+i;
      return 0;
    }
#endif
  ;

uint_t Min_Pow2(uint_t a)
#ifdef _YOYO_CORE_BUILTIN
  {
    if ( a ) --a; 
    return 1<<Bitcount_Of(a);
  }
#endif
  ;

uint_t Align_To_Pow2(uint_t a, uint_t mod)
#ifdef _YOYO_CORE_BUILTIN
  {
    uint_t Q;
    if ( !mod ) mod = 1;
    Q = Min_Pow2(mod) - 1;
    return (a+Q)&~Q;
  }
#endif
  ;

#ifdef __windoze
size_t malloc_size(void *p) _YOYO_CORE_BUILTIN_CODE({return _msize(p);});
#endif /* __windoze */

void *Yo_Malloc_Npl(unsigned size)
#ifdef _YOYO_CORE_BUILTIN
  {
    void *p = malloc(size);
    if ( !p )
      Yo_Fatal(YOYO_ERROR_OUT_OF_MEMORY,0,0,0);
    return p;
  }
#endif
  ;

void *Yo_Realloc_Npl(void *p,unsigned size)
#ifdef _YOYO_CORE_BUILTIN
  {
    p = realloc(p,size);
    if ( !p )
      Yo_Fatal(YOYO_ERROR_OUT_OF_MEMORY,0,0,0);
    return p;
  }
#endif
  ;

void *Yo_Resize_Npl(void *p,unsigned size,int granularity)
#ifdef _YOYO_CORE_BUILTIN
  {
    int capacity = p?malloc_size(p):0;
    if ( !p || capacity < size )
      {
        if ( !granularity )
          capacity = Min_Pow2(size);
        else if ( granularity > 1 )
          {
            capacity = size+granularity-1;
            capacity -= capacity % granularity;
          }
        else
          capacity = size;
        p = realloc(p,capacity);
        if ( !p )
          Yo_Fatal(YOYO_ERROR_OUT_OF_MEMORY,0,0,0);
      }
    return p;
  }
#endif
  ;

void *Yo_Memcopy_Npl(void *src,unsigned size)
#ifdef _YOYO_CORE_BUILTIN
  {
    void *p = malloc(size);
    if ( !p )
      Yo_Fatal(YOYO_ERROR_OUT_OF_MEMORY,0,0,0);
    memcpy(p,src,size);
    return p;
  }
#endif
  ;

typedef struct _YOYO_AUTORELEASE
  {
    void *ptr;
    void (*cleanup)(void *);
  }
  YOYO_AUTORELEASE;

enum { YOYO_MAX_ERROR_BTRACE = 25 };

typedef struct _YOYO_ERROR_INFO
  {
    char *msg;
    char *filename;
    int  code;
    int  lineno;
    int  bt_count;
    void *bt_cbk[YOYO_MAX_ERROR_BTRACE];
  } YOYO_ERROR_INFO;

enum { YOYO_MAX_CS_COUNT = 7 };
enum { YOYO_INI_JB_COUNT = 5 };
enum { YOYO_EXT_JB_COUNT = 3 };
enum { YOYO_INI_POOL_COUNT = 256 };
enum { YOYO_EXT_POOL_COUNT = 128 };

typedef void (*Yo_JMPBUF_Unlock)(void *);

typedef struct _YOYO_JMPBUF_LOCK
  {
    void *cs;
    Yo_JMPBUF_Unlock unlock;
  } YOYO_JMPBUF_LOCK;

typedef struct _YOYO_JMPBUF
  {
    jmp_buf b;
    YOYO_JMPBUF_LOCK locks[YOYO_MAX_CS_COUNT];
    int auto_top;
  } YOYO_JMPBUF;

typedef struct _YOYO_C_SUPPORT_INFO
  {
    int auto_count;
    int auto_top;
    int jb_count;
    int jb_top;
    struct
      {
        unsigned unwinding: 1;
      } stats;
    YOYO_ERROR_INFO err;
    YOYO_AUTORELEASE *auto_pool;
    YOYO_JMPBUF jb[YOYO_INI_JB_COUNT];
  } YOYO_C_SUPPORT_INFO;

#ifdef _YOYO_CORE_BUILTIN
YO_TLS_DEFINE(Yo_Csup_Nfo_Tls);
#else
YO_TLS_DECLARE(Yo_Csup_Nfo_Tls);
#endif

YOYO_C_SUPPORT_INFO *Yo_Acquire_Csup_Nfo()
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Malloc_Npl(sizeof(YOYO_C_SUPPORT_INFO));
    memset(nfo,0,sizeof(*nfo));
    nfo->jb_count = sizeof(nfo->jb)/sizeof(nfo->jb[0]);
    nfo->jb_top = -1;
    nfo->auto_pool = Yo_Malloc_Npl(sizeof(*nfo->auto_pool)*YOYO_INI_POOL_COUNT);
    nfo->auto_count = YOYO_INI_POOL_COUNT;
    nfo->auto_top = -1;
    Yo_Tls_Set(Yo_Csup_Nfo_Tls,nfo);
    return nfo;
  }
#endif
  ;

YOYO_C_SUPPORT_INFO *Yo_C_Support_Nfo()
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    if ( !nfo ) nfo = Yo_Acquire_Csup_Nfo();
    return nfo;
  }
#endif
  ;

YOYO_C_SUPPORT_INFO *Yo_Extend_Csup_JmpBuf()
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    nfo = Yo_Realloc_Npl(nfo,sizeof(YOYO_C_SUPPORT_INFO) 
              + (nfo->jb_count - YOYO_INI_JB_COUNT + YOYO_EXT_JB_COUNT)*sizeof(YOYO_JMPBUF));
    nfo->jb_count += YOYO_EXT_JB_COUNT;
    Yo_Tls_Set(Yo_Csup_Nfo_Tls,nfo);
    return nfo;
  }
#endif
  ;

void Yo_Extend_Csup_Autopool()
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    uint_t ncount = nfo->auto_count + YOYO_EXT_POOL_COUNT; 
    nfo->auto_pool = Yo_Realloc_Npl(nfo->auto_pool,sizeof(*nfo->auto_pool)*ncount);
    nfo->auto_top = ncount;
  }
#endif
  ;

void Yo_Pool_Marker_Tag(void *o) _YOYO_CORE_BUILTIN_CODE({});


YOYO_AUTORELEASE *Yo_Find_Ptr_In_Pool(YOYO_C_SUPPORT_INFO *nfo, void *p)
#ifdef _YOYO_CORE_BUILTIN  
  {
    int n = nfo->auto_top;
    while ( n >= 0 )
      {
        if ( nfo->auto_pool[n].ptr == p )
          return &nfo->auto_pool[n];
        --n;
      }
    return 0;
  }
#endif
  ;
  
#define Yo_Push_Scope() Yo_Pool_Ptr(0,Yo_Pool_Marker_Tag)
#define Yo_Pool(Ptr) Yo_Pool_Ptr(Ptr,0)

void *Yo_Pool_Ptr(void *ptr,void *cleanup)
#ifdef _YOYO_CORE_BUILTIN
  {
    if ( ptr || cleanup == Yo_Pool_Marker_Tag )
      {
        YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
        if ( !nfo ) nfo = Yo_Acquire_Csup_Nfo();
        STRICT_REQUIRE( (cleanup == Yo_Pool_Marker_Tag) || !Yo_Find_Ptr_In_Pool(nfo,ptr) );

        ++nfo->auto_top;
        if ( nfo->auto_top == nfo->auto_count )
          Yo_Extend_Csup_Autopool();
        nfo->auto_pool[nfo->auto_top].ptr = ptr;
        nfo->auto_pool[nfo->auto_top].cleanup = cleanup?cleanup:free; 
      }
    return ptr;
  }
#endif
  ;
  
#define Yo_Release(Pooled) ((void)Yo_Unpool((Pooled),1))
#define Yo_Retain(Pooled) Yo_Unpool((Pooled),0)

void *Yo_Unpool(void *pooled,int do_cleanup)
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    if ( nfo && pooled )
      {
        int n = nfo->auto_top;
        while ( n >= 0 )
          {
            if ( nfo->auto_pool[n].ptr == pooled )
              {
                YOYO_AUTORELEASE *q = &nfo->auto_pool[n];
                if ( do_cleanup && q->ptr ) q->cleanup(q->ptr);
                
                if ( nfo->jb_top < 0 || nfo->jb[nfo->jb_top].auto_top < n )
                  {
                    if ( nfo->auto_top != n )
                        memmove(nfo->auto_pool+n,nfo->auto_pool+n+1,(nfo->auto_top-n)*sizeof(*q));
                    --nfo->auto_top;
                  }
                else
                  {
                    q->ptr = 0;
                    q->cleanup = 0;
                  }
                
                break; // while
              }
            --n;
          }
      }
    return pooled;
  }
#endif
  ;

void *Yo_Unwind_Scope(void *pooled,int min_top)
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    int L = min_top>=0?min_top:0;
    int counter = 0;
    if ( nfo )
      {
        YOYO_AUTORELEASE *q_p = 0;
        nfo->stats.unwinding = 1;
        while ( nfo->auto_top >= L )
          {
            YOYO_AUTORELEASE *q = &nfo->auto_pool[nfo->auto_top];
            if ( q->ptr )
              {
                //printf("%p/%p ?= %p\n", q->ptr, q->cleanup, pooled);
                if ( !pooled || q->ptr != pooled )
                  { 
                    q->cleanup(q->ptr);
                    ++counter;
                  }
                else
                  q_p = q;
              }
            --nfo->auto_top;
            if ( q->cleanup == Yo_Pool_Marker_Tag && !min_top )
              break;
          }
        if ( q_p )
          {
            ++nfo->auto_top;
            nfo->auto_pool[nfo->auto_top] = *q_p;
          }
        nfo->stats.unwinding = 0;
      }
    //printf("unwind: released %d ptrs, still pooled %d ptrs\n",counter,nfo->auto_top+1);
    return pooled;
  }
#endif
  ;
  
#define Yo_Refresh(Old,New) Yo_Refresh_Ptr(Old,New,0)
void *Yo_Refresh_Ptr(void *old,void *new,void *cleaner)
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo;
    REQUIRE( new != 0 );
    if ( old && !!(nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls)) )
      {
        YOYO_AUTORELEASE *p = Yo_Find_Ptr_In_Pool(nfo,old);
        if ( !p ) Yo_Fatal(YOYO_ERROR_OUT_OF_POOL,old,0,0);
        p->ptr = new;
      }
    else
      Yo_Pool_Ptr(new,cleaner);
    return new;
  }
#endif
  ;

int Yo_Pool_Purge(int *thold, int cap)
#ifdef _YOYO_CORE_BUILTIN
  {
    return 1;
  }
#endif
  ;

void Yo_Thread_Cleanup()
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_C_SUPPORT_INFO *nfo;
    Yo_Unwind_Scope(0,-1);
    if ( !!(nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls)) )
      {
        free(nfo->err.msg);
        free(nfo->auto_pool);
        free(nfo);
        Yo_Tls_Set(Yo_Csup_Nfo_Tls,0);
      }
  }
#endif
  ;

void Yo_Global_Cleanup()
#ifdef _YOYO_CORE_BUILTIN
  {
  }
#endif
  ;

void *Yo_Malloc(unsigned size)
  _YOYO_CORE_BUILTIN_CODE({return Yo_Pool(Yo_Malloc_Npl(size));});
void *Yo_Realloc(void *p,unsigned size)
  _YOYO_CORE_BUILTIN_CODE({return Yo_Refresh(p,Yo_Realloc_Npl(p,size));});
void *Yo_Memcopy(void *p,unsigned size)
  _YOYO_CORE_BUILTIN_CODE({return Yo_Pool(Yo_Memcopy_Npl(p,size));});

void *Yo_Resize(void *p,unsigned size,int granularity)
#ifdef _YOYO_CORE_BUILTIN
  {
    void *q = Yo_Resize_Npl(p,size,granularity);
    if ( p && q != p )
      Yo_Refresh(p,q);
    else if ( !p )
      Yo_Pool(q);
    return q;
  }
#endif
  ;
  
#ifdef __windoze
  #ifdef __VSCPRINTF
int _vscprintf(char *fmt,va_list va)
  {
    static char simulate[4096*4] = {0};
    return vsprintf(simulate,fmt,va);
  }
  #endif
#endif
  
  
int Yo_Detect_Required_Buffer_Size(char *fmt,va_list va)
#ifdef _YOYO_CORE_BUILTIN
  {
  #ifdef __windoze
    return _vscprintf(fmt,va)+1;
  #else
    va_list qva;
    va_copy(qva,va);
    return vsnprintf(0,0,fmt,qva)+1;
  #endif
  }
#endif
  ;

char *Yo_Format_(char *fmt,va_list va)
#ifdef _YOYO_CORE_BUILTIN
  {
    int rq_len = Yo_Detect_Required_Buffer_Size(fmt,va)+1;
    char *b = Yo_Malloc_Npl(rq_len);
  #ifdef __windoze
    vsprintf(b,fmt,va);
  #else
    vsnprintf(b,rq_len,fmt,va);
  #endif
    return b;
  }
#endif
  ;

char *Yo_Format_Npl(char *fmt,...)
  _YOYO_CORE_BUILTIN_CODE({va_list va;char *t; va_start(va,fmt); t = Yo_Format_(fmt,va);va_end(va); return t;});
  
char *Yo_Format(char *fmt,...) 
  _YOYO_CORE_BUILTIN_CODE({va_list va;char *t; va_start(va,fmt); t = Yo_Pool(Yo_Format_(fmt,va));va_end(va); return t;});
  
void Yo_Print_FILE(FILE *st, char *text, unsigned flags)
#ifdef _YOYO_CORE_BUILTIN
  {
    __Xchg_Interlock
      {
        fputs(text,st);
        if ( flags & YO_PRINT_NEWLINE ) fputc('\n',st);
        if ( flags & YO_PRINT_FLUSH ) fflush(st);
      }
  }
#endif
  ;

#define StdOut_Print(Text) Yo_Print_FILE(stdout,Text,YO_PRINT_FLUSH)
#define StdOut_Print_Nl(Text) Yo_Print_FILE(stdout,Text,YO_PRINT_FLUSH|YO_PRINT_NEWLINE)
#define StdErr_Print(Text) Yo_Print_FILE(stderr,Text,YO_PRINT_FLUSH)
#define StdErr_Print_Nl(Text) Yo_Print_FILE(stderr,Text,YO_PRINT_FLUSH|YO_PRINT_NEWLINE)

typedef struct _YOYO_FUNCTABLE
  {
    char *name;
    void *func;
  } YOYO_FUNCTABLE;

typedef struct _YOYO_CORE_DYNAMIC
  {
    longptr_t contsig;
    longptr_t typeid;
    YOYO_FUNCTABLE funcs[1];
  }
  YOYO_DYNAMIC;

typedef struct _YOYO_CORE_OBJECT
  {
    YOYO_DYNAMIC *dynamic;
    uint_t signature; /* YOYO_OBJECT_SIGNATURE */
    uint_t rc;
  }
  YOYO_OBJECT;

#define YOYO_BASE(Ptr)          ((YOYO_OBJECT*)(Ptr) - 1)
#define YOYO_RC(Ptr)            (YOYO_BASE(Ptr)->rc)
#define YOYO_SIGNAT(Ptr)        (YOYO_BASE(Ptr)->signature)
#define YOYO_SIGNAT_IS_OK(Ptr)  ((YOYO_BASE(Ptr)->signature)==YOYO_OBJECT_SIGNATURE)

void *Yo_Unrefe(void *p);

#ifdef _YOYO_CORE_BUILTIN
uint_t Yo_Typeid_Counter = 0;
#endif

enum { YOYO_DYNCO_NYD = 0x4e5944/*'NYD'*/, YOYO_DYNCO_ATS = 0x415453/*'ATS'*/ };

void *Yo_Clone_Dynamic( YOYO_DYNAMIC *dynco, int extra )
#ifdef _YOYO_CORE_BUILTIN
  {
    int count = dynco->contsig&0x0ff;
    int fc = count?count-1:0;
    int fcc = count+extra?count+extra-1:0;
    YOYO_DYNAMIC *d = Yo_Malloc_Npl(sizeof(YOYO_DYNAMIC)+sizeof(YOYO_FUNCTABLE)*fcc);
    *d = *dynco;
    if ( fc )
      memcpy(d->funcs+1,dynco->funcs+1,sizeof(YOYO_FUNCTABLE)*fc);
    d->contsig = (YOYO_DYNCO_NYD<<8)|count;
    return d;
  }
#endif
  ;

void *Yo_Extend_Dynamic( YOYO_DYNAMIC *dynco, int extra )
#ifdef _YOYO_CORE_BUILTIN
  {
    int count = dynco->contsig&0x0ff;
    int fcc = count+extra?count+extra-1:0;
    YOYO_DYNAMIC *d = Yo_Realloc_Npl(dynco,sizeof(YOYO_DYNAMIC)+sizeof(YOYO_FUNCTABLE)*fcc);
    return d;
  }
#endif
  ;

void *Yo_Object_Extend( void *o, char *func_name, void *func )
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_OBJECT *T = YOYO_BASE(o);
    YOYO_FUNCTABLE *f;
    if ( !T )
      Yo_Raise(YOYO_ERROR_NULL_PTR,__yoTa("failed to extend nullptr",0),__Yo_FILE__,__LINE__);
    
    if ( T->dynamic )
      {
        if ( (T->dynamic->contsig >> 8) == YOYO_DYNCO_ATS )
          T->dynamic = Yo_Clone_Dynamic(T->dynamic,1);
        else
          T->dynamic = Yo_Extend_Dynamic(T->dynamic,1);
      }
    else
      {
        T->dynamic = Yo_Malloc_Npl(sizeof(YOYO_DYNAMIC));
        T->dynamic->contsig = YOYO_DYNCO_NYD<<8;
      }
      
    T->dynamic->typeid = Yo_Atomic_Increment(&Yo_Typeid_Counter);
    f = T->dynamic->funcs+(T->dynamic->contsig&0x0ff);
    ++T->dynamic->contsig;
    f->name = func_name;
    f->func = func;
    
    return o;
  }
#endif
  ;

enum { YOYO_OBJECT_SIGNATURE =  0x4f594f59 /*'YOYO'*/  }; 

void *Yo_Object_Clone(int size, void *orign)
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_OBJECT *o;
    YOYO_OBJECT *T = YOYO_BASE(orign);
    if ( !T )
      Yo_Raise(YOYO_ERROR_NULL_PTR,__yoTa("failed to clone nullptr",0),__Yo_FILE__,__LINE__);
    
    o = Yo_Malloc_Npl(sizeof(YOYO_OBJECT)+size);
    o->signature = YOYO_OBJECT_SIGNATURE;
    o->rc = 1;
    memcpy(o+1,orign,size);
    
    if ( T->dynamic )
      {
        if ( (T->dynamic->contsig>>8) == YOYO_DYNCO_ATS )
          o->dynamic = T->dynamic;
        else
          {
            STRICT_REQUIRE( (T->dynamic->contsig>>8) == YOYO_DYNCO_NYD );
            o->dynamic = Yo_Clone_Dynamic(T->dynamic,0);
          }
      }
    else
      o->dynamic = 0;
    
    return Yo_Pool_Ptr(o+1,Yo_Unrefe);
  }
#endif
  ;

void *Yo_Object(int size,YOYO_FUNCTABLE *tbl)
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_OBJECT *o = Yo_Malloc_Npl(sizeof(YOYO_OBJECT)+size);
    memset(o,0,sizeof(YOYO_OBJECT)+size);
    o->signature = YOYO_OBJECT_SIGNATURE;
    o->rc = 1;
    o->dynamic = (YOYO_DYNAMIC*)tbl;
    
    if ( tbl )
      {__Xchg_Interlock
        {
          YOYO_DYNAMIC *dynco = (YOYO_DYNAMIC*)tbl;
          if ( !dynco->contsig )
            {
              int count;
              for ( count = 0; tbl[count+1].name; ) { ++count; }
              dynco->contsig = (YOYO_DYNCO_ATS<<8)|count;
              dynco->typeid = Yo_Atomic_Increment(&Yo_Typeid_Counter);
            }
        }}

    return Yo_Pool_Ptr(o+1,Yo_Unrefe);
  }
#endif
  ;

ulong_t Yo_Align(ulong_t val)
#ifdef _YOYO_CORE_BUILTIN
  {
    return (val + 7)&~7;
  }
#endif
  ;

void *Yo_Object_Dtor(int size,void *dtor)
#ifdef _YOYO_CORE_BUILTIN
  {  
    int Sz = Yo_Align(sizeof(YOYO_OBJECT)+size);
    YOYO_OBJECT *o = Yo_Malloc_Npl(Sz+sizeof(YOYO_DYNAMIC));
    memset(o,0,Sz+sizeof(YOYO_DYNAMIC));
    o->signature = YOYO_OBJECT_SIGNATURE;
    o->rc = 1;
    o->dynamic = (YOYO_DYNAMIC*)((char*)o + Sz);
    o->dynamic->contsig = (YOYO_DYNCO_ATS<<8)|1;
    o->dynamic->funcs[0].name = Oj_Destruct_OjMID;
    o->dynamic->funcs[0].func = dtor;
    o->dynamic->typeid = Yo_Atomic_Increment(&Yo_Typeid_Counter);
    return Yo_Pool_Ptr(o+1,Yo_Unrefe);
  }
#endif
  ;

void Yo_Object_Destruct(void *ptr)
#ifdef _YOYO_CORE_BUILTIN
  {
    if ( ptr )
      {
        YOYO_OBJECT *o = (YOYO_OBJECT *)ptr - 1;
        if ( o->dynamic && (o->dynamic->contsig>>8) == YOYO_DYNCO_NYD )
          free(o->dynamic);
        o->dynamic = 0;
        free(o);
      }
  }
#endif
  ;

void *Yo_Find_Method_In_Table(char *name,YOYO_FUNCTABLE *tbl,int count,int flags)
#ifdef _YOYO_CORE_BUILTIN
  {
    int i;
    for ( i = 0; i < count; ++i )
      if ( strcmp(tbl[i].name,name) == 0 )
        return tbl[i].func;
    return 0;
  }
#endif
  ;

void *Yo_Find_Method_Of(void **self,char *name,unsigned flags)
#ifdef _YOYO_CORE_BUILTIN
  {
    void *o = *self;
    if ( o && STRICT_CHECK(YOYO_SIGNAT_IS_OK(o)) )
      {
        YOYO_DYNAMIC *dynco = YOYO_BASE(o)->dynamic;
        if ( dynco )
          {
            if ( 1 && STRICT_CHECK((dynco->contsig>>8) == YOYO_DYNCO_ATS || (dynco->contsig>>8) == YOYO_DYNCO_NYD) )
              {
                void *f = Yo_Find_Method_In_Table(name,dynco->funcs,(dynco->contsig&0x0ff),flags);
                if ( !f && (flags & YO_RAISE_ERROR) )
                  Yo_Raise(YOYO_ERROR_METHOD_NOT_FOUND,name,__Yo_FILE__,__LINE__);
                return f;
              }
            else
              Yo_Fatal(YOYO_ERROR_DYNCO_CORRUPTED,o,__Yo_FILE__,__LINE__);
          }
        else if (flags & YO_RAISE_ERROR) 
          Yo_Raise(YOYO_ERROR_METHOD_NOT_FOUND,name,__Yo_FILE__,__LINE__);
      }
    else if (flags & YO_RAISE_ERROR)
      Yo_Raise(YOYO_ERROR_METHOD_NOT_FOUND,name,__Yo_FILE__,__LINE__);
    return 0;
  }
#endif
  ;
  
void *Yo_Refe(void *p)
#ifdef _YOYO_CORE_BUILTIN
  {
    if ( p && STRICT_CHECK(YOYO_SIGNAT_IS_OK(p)) )
      Yo_Atomic_Increment(&YOYO_RC(p));
    return p;
  }
#endif
  ;

#ifdef _YOYO_CORE_BUILTIN
void *Yo_Unrefe(void *p)
  {
    if ( p && STRICT_CHECK(YOYO_SIGNAT_IS_OK(p)) 
           && !(Yo_Atomic_Decrement(&YOYO_RC(p))&0x7fffff) )
      {
        void (*destruct)(void *) = Yo_Find_Method_Of(&p,Oj_Destruct_OjMID,0);
        if ( !destruct )
          Yo_Object_Destruct(p);
        else
          destruct(p);
        return 0;
      }
    return p;
  }
#endif
  ;

void *Oj_Clone(void *p)
#ifdef _YOYO_CORE_BUILTIN
  {
    if ( p )
      {
        void *(*clone)(void *) = Yo_Find_Method_Of(&p,Oj_Clone_OjMID,YO_RAISE_ERROR);
        return clone(p);
      }
    return p;
  }
#endif
  ;

int Oj_Count(void *self)
#ifdef _YOYO_CORE_BUILTIN
  {
    int (*count)(void *) = Yo_Find_Method_Of(&self,Oj_Count_OjMID,YO_RAISE_ERROR);
    return count(self);
  }
#endif
  ;

#define __Try  \
  switch ( setjmp(Yo_Push_JmpBuf()->b) ) \
    if ( 1 ) \
      while ( 1 ) \
        if ( 1 ) \
          { Yo_Pop_JmpBuf(); break; } \
        else if ( 1 ) \
          default: Yo_Raise_If_Occured(); \
        else \
          case 0:

#define __Try_Abort  \
  switch ( setjmp(Yo_Push_JmpBuf()->b) ) \
    if ( 1 ) \
      while ( 1 ) \
        if ( 1 ) \
          { Yo_Pop_JmpBuf(); break; } \
        else if ( 1 ) \
          default: Error_Abort(); \
        else \
          case 0:

#define __Try_Exit(pfx)  \
  switch ( setjmp(Yo_Push_JmpBuf()->b) ) \
    if ( 1 ) \
      while ( 1 ) \
        if ( 1 ) \
          { Yo_Pop_JmpBuf(); break; } \
        else if ( 1 ) \
          default: Error_Exit(pfx); \
        else \
          case 0:

#define __Try_Except  \
  switch ( setjmp(Yo_Push_JmpBuf()->b) ) \
    if ( 1 ) \
      while ( 1 ) \
        if ( 1 ) \
          { Yo_Pop_JmpBuf(); break; } \
        else \
          case 0:

#define __Catch(Code) \
    else if ( 1 ) \
      case (Code):

#define __Except \
    else \
      default:

YOYO_ERROR_INFO *Error_Info()
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    if ( nfo && nfo->err.code )
      return &nfo->err;
    else
      return 0;
  }
#endif
  ;
  
char *Error_Message(void) 
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_ERROR_INFO *info = Error_Info();
    if ( info && info->msg )
      return info->msg;
    return "";
  }
#endif
  ;

int Error_Code(void) 
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_ERROR_INFO *info = Error_Info();
    if ( info )
      return info->code;
    return 0;
  }
#endif
  ;

char *Error_File(void) 
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_ERROR_INFO *info = Error_Info();
    if ( info && info->filename )
      return info->filename;
    return __yoTa("<file>",0);
  }
#endif
  ;

int Error_Line(void) 
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_ERROR_INFO *info = Error_Info();
    if ( info )
      return info->lineno;
    return 0;
  }
#endif
  ;

char *Error_Print_N_Exit(char *prefix, int code) 
#ifdef _YOYO_CORE_BUILTIN  
  {
    StdErr_Print_Nl(Yo_Format(__yoTa("%s: %s",0),prefix,Error_Message()));
    exit(code);
  }
#endif
  ;

#define Yo_Pop_JmpBuf() \
   (--((YOYO_C_SUPPORT_INFO *)Yo_Tls_Get(Yo_Csup_Nfo_Tls))->jb_top)

YOYO_JMPBUF *Yo_Push_JmpBuf(void)
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_C_Support_Nfo();
    YOYO_JMPBUF *jb;
    
    STRICT_REQUIRE(nfo->jb_top < nfo->jb_count);
    STRICT_REQUIRE(nfo->jb_top >= -1);
    
    if ( nfo->jb_top == nfo->jb_count-1 ) 
      nfo = Yo_Extend_Csup_JmpBuf();
    ++nfo->jb_top;

    jb = &nfo->jb[nfo->jb_top];
    memset(jb->locks,0,sizeof(jb->locks));
    jb->auto_top = nfo->auto_top+1;
    
    return jb;
  }
#endif
  ;

void Yo_JmpBuf_Push_Cs(void *cs,Yo_JMPBUF_Unlock unlock)
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    STRICT_REQUIRE ( cs );
    if ( nfo && cs )
      {
        STRICT_REQUIRE(nfo->jb_top < nfo->jb_count);
        STRICT_REQUIRE(nfo->jb_top >= -1);
        if ( nfo->jb_top > -1 && !nfo->stats.unwinding )
          {
            int i;
            YOYO_JMPBUF_LOCK *locks = nfo->jb[nfo->jb_top].locks;
            for ( i = YOYO_MAX_CS_COUNT-1; i >= 0; --i ) 
              if ( !locks[i].cs )
                {
                  locks[i].cs = cs;
                  locks[i].unlock = unlock;
                  return;
                }
            Yo_Fatal(YOYO_FATAL_ERROR,__yoTa("no enough lock space",0),__FILE__,__LINE__);
          }
      }
  }
#endif
  ;

  
void Yo_JmpBuf_Pop_Cs(void *cs)
#ifdef _YOYO_CORE_BUILTIN  
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    if ( nfo && cs )
      {
        STRICT_REQUIRE(nfo->jb_top < nfo->jb_count);
        STRICT_REQUIRE(nfo->jb_top >= -1);
        if ( nfo->jb_top > -1 && !nfo->stats.unwinding )
          { 
            int i;
            YOYO_JMPBUF_LOCK *locks = nfo->jb[nfo->jb_top].locks;
            for ( i = YOYO_MAX_CS_COUNT-1; i >= 0; --i ) 
              if ( locks[i].cs == cs )
                {
                  memset(&locks[i],0,sizeof(locks[i]));
                  return;
                }
            Yo_Fatal(YOYO_FATAL_ERROR,__yoTa("trying to pop unexistent lock",0),__FILE__,__LINE__);
          }
      }
  }
#endif
  ;
  
#ifdef _YOYO_CORE_BUILTIN
void _Yo_Raise(int err,char *msg,char *filename,int lineno)
  {
    YOYO_C_SUPPORT_INFO *nfo = Yo_Tls_Get(Yo_Csup_Nfo_Tls);
    STRICT_REQUIRE( !nfo || nfo->jb_top < nfo->jb_count );
    
    if ( err == YO_RERAISE_CURRENT_ERROR && (!nfo || !nfo->err.code) )
      return;
    
    if ( nfo && nfo->jb_top >= 0 && !nfo->stats.unwinding )
      {
        int i; 
        char *old_msg = nfo->err.msg;
        YOYO_JMPBUF_LOCK *locks = nfo->jb[nfo->jb_top].locks;
        
        if ( err != YO_RERAISE_CURRENT_ERROR )
          {
            nfo->err.msg = msg ? strdup(msg) : 0;
            nfo->err.code = err?err:-1;
            nfo->err.filename = filename;
            nfo->err.lineno = lineno;
            nfo->err.bt_count = backtrace(nfo->err.bt_cbk,YOYO_MAX_ERROR_BTRACE);
            free( old_msg );
          }
          
        for ( i = YOYO_MAX_CS_COUNT-1; i >= 0; --i ) 
          if (  locks[i].cs ) 
            locks[i].unlock(locks[i].cs);
        
        Yo_Unwind_Scope(0,nfo->jb[nfo->jb_top].auto_top);
        
        --nfo->jb_top;
        STRICT_REQUIRE(nfo->jb_top >= -1);
        
        longjmp(nfo->jb[nfo->jb_top+1].b,err?err:-1);
      }
    else
      {
        if ( err != YO_RERAISE_CURRENT_ERROR )
          Yo_Fatal(err,msg,filename,lineno);
        else
          Yo_Fatal(nfo->err.code,nfo->err.msg,nfo->err.filename,nfo->err.lineno);
      }
  }
#endif

#define Yo_Raise_If_Occured() _Yo_Raise(YO_RERAISE_CURRENT_ERROR,0,0,0)

void Yo_Abort(char *msg)
#ifdef _YOYO_CORE_BUILTIN
  {
    StdErr_Print_Nl(msg);
    abort();
  }
#endif
  ;

char *Yo__basename(char *S)
#ifdef _YOYO_CORE_BUILTIN
  {
    if ( S )
      {
        char *a = strrchr(S,'/');
        char *b = strrchr(S,'\\');
        if ( b > a ) a = b;
        return a ? a+1 : S;
      }
    return 0;
  }
#endif
  ;

char *Yo_Btrace_Format(int frames, void **cbk)
#ifdef _YOYO_CORE_BUILTIN
  {
  #ifdef __windoze
    return __yoTa("--backtrace--",0);
  #elif !defined __linux__
    int  max_bt = 4096;
    char *bt = Yo_Malloc(max_bt);
    char *bt_p = bt;
    int i;
    
    i = snprintf(bt_p,max_bt,__yoTa("--backtrace--",0));
    bt_p+=i;
    max_bt-=i;
    memset(bt_p,0,max_bt--);
    
    for ( i = 0; i < frames; ++i )
      {
        Dl_info dlinfo = {0};
        if ( dladdr(cbk[i], &dlinfo) )
          {
            int dif = (char*)cbk[i]-(char*)dlinfo.dli_saddr;
            char c = dif > 0?'+':'-'; 
            int l = snprintf(bt_p,max_bt,__yoTa("\n %-2d=> %s %c%x (%p at %s)",0),
               i,
               dlinfo.dli_sname, 
               c, 
               dif>0?dif:-dif,
               cbk[i],
               Yo__basename((char*)dlinfo.dli_fname));
            if ( l > 0 )
              {
                max_bt -= l;
                bt_p += l;
              }
          }
      }
    
    return bt;
  #else
    return __yoTa("--backtrace--",0);
  #endif
  }
#endif
  ;

char *Yo_Btrace(void)
#ifdef _YOYO_CORE_BUILTIN
  {
  #ifdef __windoze
    return __yoTa("--backtrace--",0);
  #else
    void *cbk[128] = {0};
    int frames = backtrace(cbk,127);
    return Yo_Btrace_Format(frames,cbk);
  #endif
  }
#endif
  ;

char *Yo_Error_Format_Btrace(void)
#ifdef _YOYO_CORE_BUILTIN
  {
    YOYO_ERROR_INFO *info = Error_Info();
    if ( info && info->bt_count )
      {
        return Yo_Btrace_Format(info->bt_count,info->bt_cbk);
      }
    return __yoTa("--backtrace--\n   unavailable",0);
  }
#endif
  ;

void Yo_Btrace_N_Abort(char *prefix, char *msg, char *filename, int lineno)
#ifdef _YOYO_CORE_BUILTIN
  {
    char *at = filename?Yo_Format_Npl(__yoTa(" [%s(%d)]",0),Yo__basename(filename),lineno):"";
    char *pfx = prefix?Yo_Format_Npl(__yoTa("%s: ",0),prefix):"";
    StdErr_Print_Nl(Yo_Btrace());
    Yo_Abort(Yo_Format_Npl(__yoTa("%s%s%s",0),pfx,msg,at));
  }
#endif
  ;

#ifdef _YOYO_CORE_BUILTIN
void _Yo_Fatal(int err,void *ctx,char *filename,int lineno)
  {
    switch (err)
      {
        case YOYO_ERROR_OUT_OF_MEMORY:
          Yo_Abort(__yoTa("out of memory",0));
        case YOYO_ERROR_REQUIRE_FAILED:
          Yo_Btrace_N_Abort(__yoTa("require",0),ctx,filename,lineno);
        case YOYO_FATAL_ERROR:
          Yo_Btrace_N_Abort(__yoTa("fatal",0),ctx,filename,lineno);
        case YOYO_ERROR_DYNCO_CORRUPTED:
          Yo_Btrace_N_Abort(__yoTa("fatal",0),
            Yo_Format_Npl(__yoTa("corrupted dynco (%p)",0),ctx),filename,lineno);
        default:
          {
            char err_pfx[60];
            sprintf(err_pfx,__yoTa("unexpected(%08x)",0),err); 
            Yo_Btrace_N_Abort(err_pfx,ctx,filename,lineno);
          }
      }
  }
#endif
  ;

void Error_Abort()
#ifdef _YOYO_CORE_BUILTIN
  {
    Yo_Btrace_N_Abort(
      Yo_Format_Npl(__yoTa("\ncaught(0x%08x)",0),Error_Code()),
      Error_Message(),Error_File(),Error_Line());
  }
#endif
  ;

char *Yo_Error_Format()
#ifdef _YOYO_CORE_BUILTIN
  {
    int code = Error_Code();
    char *msg = Error_Message();

    if ( YOYO_ERROR_IS_USER_ERROR(code) )
      return Yo_Format(__yoTa("\nerror(%d): %s",0),code,msg);
    else
      return Yo_Format(__yoTa("\nerror(%08x): %s",0),code,msg);
  }
#endif
  ;
  
void Error_Exit(char *pfx)
#ifdef _YOYO_CORE_BUILTIN
  {
    int code = Error_Code();
    char *msg = Error_Message();
    
  #ifndef _BACKTRACE
    if ( (code & YOYO_TRACED_ERROR_GROUP) || !Error_Info()->msg )
  #endif
      StdErr_Print_Nl(Yo_Error_Format_Btrace());
    
    if ( YOYO_ERROR_IS_USER_ERROR(code) )
      StdErr_Print_Nl(Yo_Format(__yoTa("\n%s(%d): %s",0),(pfx?pfx:__yoTa("error",0)),code,msg));
    else
      StdErr_Print_Nl(Yo_Format(__yoTa("\n%s(%08x): %s",0),(pfx?pfx:__yoTa("error",0)),code,msg));
    if ( code & YOYO_FATAL_ERROR_GROUP )
      abort();
    Yo_Unwind_Scope(0,-1);
    exit(code);
  }
#endif
  ;

#define __Pool(Ptr)                     Yo_Pool_Ptr(Ptr,0)
#define __Release(Pooled)               Yo_Release(Pooled)
#define __Retain(Pooled)                Yo_Retain(Pooled)
#define __Purge(TholdPtr,Cap)           Yo_Pool_Purge(TholdPtr,Cap)
#define __Refe(Ptr)                     Yo_Refe(Ptr)
#define __Unrefe(Ptr)                   Yo_Unrefe(Ptr)
#define __Raise(Err,Msg)                Yo_Raise(Err,Msg,__Yo_FILE__,__LINE__)
#define __Raise_Format(Err,Fmt)         Yo_Raise(Err,(Yo_Format Fmt),__Yo_FILE__,__LINE__)
#define __Raise_If_Occured()            Yo_Raise_If_Occured()
#define __Fatal(Err,Ctx)                Yo_Fatal(Err,Ctx,__Yo_FILE__,__LINE__)
#define __Format                        Yo_Format
#define __Format_Npl                    Yo_Format_Npl
#define __Format_Error()                Yo_Error_Format()

#define __Malloc(Size)                  Yo_Malloc(Size)
#define __Malloc_Npl(Size)              Yo_Malloc_Npl(Size)
#define __Memcopy(Ptr,Size)             Yo_Memcopy(Ptr,Size)
#define __Memcopy_Npl(Ptr,Size)         Yo_Memcopy_Npl(Ptr,Size)
#define __Realloc(Ptr,Size)             Yo_Realloc(Ptr,Size)
#define __Realloc_Npl(Ptr,Size)         Yo_Realloc_Npl(Ptr,Size)
#define __Resize(Ptr,Size,Gran)         Yo_Resize(Ptr,Size,Gran)
#define __Resize_Npl(Ptr,Size,Gran)     Yo_Resize_Npl(Ptr,Size,Gran)

#define __Object(Size,Funcs)            Yo_Object(Size,Funcs)
#define __Object_Dtor(Size,Dtor)        Yo_Object_Dtor(Size,Dtor)
#define __Object_Extend(Obj,Name,Func)  Yo_Object_Extend(Obj,Name,Func)
#define __Destruct(Ptr)                 Yo_Object_Destruct(Ptr)
#define __Clone(Size,Ptr)               Yo_Object_Clone(Size,Ptr)

#define __Atomic_Increment(Ptr)         Yo_Atomic_Increment(Ptr)
#define __Atomic_Decrement(Ptr)         Yo_Atomic_Decrement(Ptr)
#define __Tls_Define(Name)              YO_TLS_DEDINE(Name)
#define __Tls_Declare(Name)             YO_TLS_DECLARE(Name)
#define __Tls_Set(Name,Val)             Yo_Tls_Set(Name,Val)
#define __Tls_Get(Name)                 Yo_Tls_Get(Name)

#define __Auto_Release \
  switch ( 0 ) \
    if ( 0 ); else \
      while ( 1 ) \
        if ( 1 ) \
          { \
            Yo_Unwind_Scope(0,0); \
            break; \
          case 0: Yo_Push_Scope(); \
            goto YOYO_LOCAL_ID(Body);\
          } \
        else \
          YOYO_LOCAL_ID(Body):

#define __Auto_Ptr(Ptr) \
  switch ( 0 ) \
    if ( 0 ); else \
      while ( 1 ) \
        if ( 1 ) \
          { \
            Yo_Unwind_Scope(Ptr,0); \
            break; \
          case 0: Yo_Push_Scope(); \
            goto YOYO_LOCAL_ID(Body);\
          } \
        else \
          YOYO_LOCAL_ID(Body):

#define __Interlock_Opt(Decl,Lx,Lock,Unlock,Unlock_Proc) \
  switch ( 0 ) \
    while ( 1 ) \
      if ( 1 ) \
        goto YOYO_LOCAL_ID(Do_Unlock); \
      else if ( 1 ) \
        case 0: \
          { \
            Decl;\
            Lock(Lx); \
            Yo_JmpBuf_Push_Cs(Lx,(Yo_JMPBUF_Unlock)Unlock_Proc); \
            goto YOYO_LOCAL_ID(Do_Code); \
          YOYO_LOCAL_ID(Do_Unlock): \
            Yo_JmpBuf_Pop_Cs(Lx); \
            Unlock(Lx); \
            break; \
          } \
      else \
        YOYO_LOCAL_ID(Do_Code):

#define __Gogo \
  if ( 1 ) goto YOYO_LOCAL_ID(__gogo); \
  else YOYO_LOCAL_ID(__gogo):

void Yo_Elm_Resize_Npl(void **inout, int L, int type_width, int *capacity_ptr)
#ifdef _YOYO_CORE_BUILTIN
  {
    int requires = 0;
    int capacity = capacity_ptr?*capacity_ptr:0;
    
    if ( L )
      {
        requires = (L+1)*type_width;
        
        if ( *inout )
          {
            if ( !capacity )
              capacity = malloc_size(*inout);
            if ( capacity < requires )
              {
                capacity = Min_Pow2(requires);
                *inout = Yo_Realloc_Npl(*inout,capacity);
              }
          }
        else
          {
            if ( capacity < requires )
              capacity = Min_Pow2(requires);
              
            *inout = Yo_Malloc_Npl(capacity);
          }
      }

    if ( capacity_ptr ) *capacity_ptr = capacity;
  }
#endif
  ;
  
#define __Elm_Insert_Npl(MemPptr,Pos,Count,S,L,Width,CpsPtr) Yo_Elm_Insert_Npl((void**)MemPptr,Pos,Count,S,L,Width,CpsPtr)
int Yo_Elm_Insert_Npl(void **inout, int pos, int count, void *S, int L, int type_width, int *capacity_ptr)
#ifdef _YOYO_CORE_BUILTIN
  {
    STRICT_REQUIRE(pos <= count);
    
    if ( L < 0 ) /* inserting Z-string */
      switch ( type_width )
        {
          case sizeof(wchar_t): L = wcslen(S); break;
          case 1: L = strlen(S); break;
          default: PANICA(__yoTa("invalid size of string element",0));
        }

    if ( L )
      {
        Yo_Elm_Resize_Npl(inout,count+L,type_width,capacity_ptr);
        
        if ( pos < count ) 
          memmove((byte_t*)*inout+(pos+L)*type_width,(byte_t*)*inout+pos*type_width,(count-pos)*type_width);
        memcpy((byte_t*)*inout+pos*type_width, S, L*type_width);
        count += L;
        memset((byte_t*)*inout+count*type_width, 0, type_width);
      }

    return L;
  }
#endif
  ;

#define __Elm_Insert(MemPptr,Pos,Count,S,L,Width,CpsPtr) Yo_Elm_Insert((void**)MemPptr,Pos,Count,S,L,Width,CpsPtr)
int Yo_Elm_Insert(void **inout, int pos, int count, void *S, int L, int type_width, int *capacity_ptr)
#ifdef _YOYO_CORE_BUILTIN
  {
    void *old = *inout;
    int r = Yo_Elm_Insert_Npl(inout,pos,count,S,L,type_width,capacity_ptr);
    if ( *inout != old )
      {
        if ( old ) 
          Yo_Refresh_Ptr(old,*inout,0);
        else
          Yo_Pool_Ptr(*inout,0);
      }
    return r;
  }
#endif
  ;

#define Yo_Elm_Append(Mem,Count,S,L,Width,CpsPtr) Yo_Elm_Insert(Mem,Count,Count,S,L,Width,CpsPtr)
#define Yo_Elm_Append_Npl(Mem,Count,S,L,Width,CpsPtr) Yo_Elm_Insert_Npl(Mem,Count,Count,S,L,Width,CpsPtr)
#define __Vector_Append(Mem,Count,Capacity,S,L) (void)(*Count += Yo_Elm_Append((void**)Mem,*Count,S,L,1,Capacity))
#define __Elm_Append(Mem,Count,S,L,Width,CpsPtr) Yo_Elm_Append((void**)Mem,Count,S,L,Width,CpsPtr)
#define __Elm_Append_Npl(Mem,Count,S,L,Width,CpsPtr) Yo_Elm_Append_Npl((void**)Mem,Count,S,L,Width,CpsPtr)

#endif /* C_once_6973F3BA_26FA_434D_9ED9_FF5389CE421C */

