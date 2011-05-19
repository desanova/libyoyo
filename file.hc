
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

#ifndef C_once_E9479D04_5D69_4A1A_944F_0C99A852DC0B
#define C_once_E9479D04_5D69_4A1A_944F_0C99A852DC0B

#include "core.hc"
#include "string.hc"
#include "buffer.hc"

#ifndef __windoze
# include <dirent.h>
#endif

#ifdef _YOYO_FILE_BUILTIN
# define _YOYO_FILE_BUILTIN_CODE(Code) Code
# define _YOYO_FILE_EXTERN
#else
# define _YOYO_FILE_BUILTIN_CODE(Code)
# define _YOYO_FILE_EXTERN extern
#endif

char *Path_Basename(char *path, char *sfx)
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

char *Path_Dirname(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

char *Path_Absname(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

char *Path_Join(char *dir, char *name)
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

char *Path_Suffix(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

char *Current_Directory()
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

void File_Check_Error(char *op, FILE *f, char *fname, int look_to_errno)
#ifdef _YOYO_FILE_BUILTIN
  {
    int err = 0;
    char *errS = 0;
    
    if ( look_to_errno )
      {
        if ( (err = errno) ) 
          errS = strerror(err);
      }
    else if ( f && !feof(f) && ( err = ferror(f) ) )
      {
        errS = strerror(err);
        clearerr(f);
      }
    
    if (err)
      Yo_Raise(YO_ERROR_IO,
        Yo_Format("%s failed on file '%s': %s",op,fname,errS),
        __FILE__,__LINE__);
  }
#endif
  ;

typedef struct _YOYO_FILE_STATS
  {
    time_t ctime;
    time_t mtime;
    quad_t length;
    
    struct {
      int exists: 1;
      int is_regular: 1;
      int is_tty: 1;
      int is_symlink: 1;
      int is_unisok: 1;
      int is_directory: 1;
      int is_writable: 1;
      int is_readable: 1;
      int is_executable: 1;
    } f;
  
  } YOYO_FILE_STATS;

#ifdef __windoze
  #if !defined _FILEi32  
    typedef struct __stat64 _YOYO_stat;
  #else
    typedef struct _stat _YOYO_stat;
  #endif
  #if !defined S_IWUSR 
    enum 
      { 
        S_IWUSR = _S_IWRITE,
        S_IRUSR = _S_IREAD,
        S_IXUSR = _S_IEXEC,
      };
  #endif  
#else
  typedef struct stat _YOYO_stat;
#endif        

YOYO_FILE_STATS *File_Translate_Filestats(_YOYO_stat *fst,YOYO_FILE_STATS *st)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( !st ) st = Yo_Malloc(sizeof(YOYO_FILE_STATS));
    memset(st,0,sizeof(*st));

    st->f.exists = fst->st_mode?1:0;
    st->f.is_regular   = (fst->st_mode&S_IFMT) == S_IFREG;
    st->f.is_directory = (fst->st_mode&S_IFMT) == S_IFDIR;
  #ifndef __windoze  
    st->f.is_symlink = (fst->st_mode&S_IFMT) == S_IFLNK;    
    st->f.is_unisok  = (fst->st_mode&S_IFMT) == S_IFSOCK;
  #endif  
    st->f.is_writable = (fst->st_mode&S_IWUSR) != 0;
    st->f.is_readable = (fst->st_mode&S_IRUSR) != 0;
    st->f.is_executable = (fst->st_mode&S_IXUSR) != 0;
    st->length = fst->st_size;
    st->ctime  = fst->st_ctime;
    st->mtime  = fst->st_mtime;
    
    return st;
  }
#endif
  ;

YOYO_FILE_STATS *File_Get_Stats(char *name,YOYO_FILE_STATS *st,int ignorerr)
#ifdef _YOYO_FILE_BUILTIN
  {
    _YOYO_stat fst = {0};
    int err;
  #ifdef __windoze
    wchar_t *uni_name = Str_Utf8_To_Unicode(name);
    #ifndef _FILEi32  
      err = _wstat64(uni_name,&fst);
    #else
      err = _wstat(uni_name,&fst);
    #endif
    Yo_Release(uni_name);
  #else
    err = stat(name,&fst);
  #endif        
    if ( !err || ignorerr )
      File_Translate_Filestats(&fst,st);
    if ( err && !ignorerr )              
      if ( errno != ENOENT && errno != ENOTDIR )
        File_Check_Error("getting stats",0,name,1); 
    return st;
  }
#endif
  ;

YOYO_FILE_STATS *File_Get_Stats_Reuse(char *name, YOYO_FILE_STATS **stp)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( stp && *stp ) 
      return *stp;
    else
      {
        YOYO_FILE_STATS *st = File_Get_Stats(name,0,0);
        if ( stp ) *stp = st;
        return st;
      }
  }
#endif
  ;

time_t File_Ctime(char *name) 
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->ctime;});
time_t File_Mtime(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->mtime;});
quad_t File_Length(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->length;});
int File_Exists(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,1)->f.exists;});
int File_Is_Regular(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->f.is_regular;});
int File_Is_Direcory(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->f.is_directory;});
int File_Is_Writable(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->f.is_writable;});
int File_Is_Readable(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->f.is_readable;});
int File_Is_Executable(char *name)
  _YOYO_FILE_BUILTIN_CODE({YOYO_FILE_STATS st={0}; return File_Get_Stats(name,&st,0)->f.is_executable;});

void Create_Directory(char *name)
#ifdef _YOYO_FILE_BUILTIN
  {
    YOYO_FILE_STATS st;
    if ( !File_Get_Stats(name,&st,1)->f.is_directory )
      {
      #ifdef __windoze
        if ( _wmkdir(Str_Utf8_To_Unicode(name)) < 0 )
      #else
        if ( mkdir(name,0755) < 0 )
      #endif  
          File_Check_Error("mkdir",0,name,1);
      }
  }
#endif
  ;

void Create_Directory_In_Depth(char *name)
#ifdef _YOYO_FILE_BUILTIN
  {
    int nL = name ? strlen(name) : 0;
    if ( nL 
        && !(nL == 2 && name[1] == ':')  
        && !(nL == 1 && (name[0] == '/' || name[0] == '\\') ))
      {
        Create_Directory_In_Depth(Path_Dirname(name));
        Create_Directory(name);
      }
  }
#endif
  ;

void Create_Required_Dirs(char *name)
#ifdef _YOYO_FILE_BUILTIN
  {
    __Auto_Release
      {
        char *dirpath = Path_Dirname(name);
        Create_Directory_In_Depth(dirpath);
      }
  }
#endif
  ;

enum _YOYO_DIRLIST_FLAGS
  {
    FILE_LIST_ALL = 0,
    FILE_LIST_DIRECTORIES = 1,
    FILE_LIST_FILES = 2,
  };

void *File_List_Directory(char *dirname, unsigned flags)
#ifdef _YOYO_FILE_BUILTIN
  {
  #ifdef __windoze
    WIN32_FIND_DATAW fdtw;
    HANDLE hfnd;
  #else
    DIR *dir;
  #endif
    void *L = Array_Pchars();
  
    __Auto_Release
      {
        if (!flags) flags = FILE_LIST_DIRECTORIES|FILE_LIST_FILES;
    
      #ifdef __windoze
        hfnd = FindFirstFileW(Str_Utf8_To_Unicode(Path_Join(dirname,"*.*")),&fdtw);
        if ( hfnd && hfnd != INVALID_HANDLE_VALUE )
          {
            do
              if ( wcscmp(fdtw.cFileName,L".") && wcscmp(fdtw.cFileName,L"..") )
                {
                  int m = fdtw.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY ?
                    FILE_LIST_DIRECTORIES : FILE_LIST_FILES;
                  if ( m & flags )
                    Array_Push(L,Str_Unicode_To_Utf8_Npl(fdtw.cFileName));
                }
            while( FindNextFileW(hfnd,&fdtw) );
            FindClose(hfnd);
          }
      #else
        dir = Yo_Pool_Ptr(opendir(dirname),closedir);
        if ( dir )
          {
            struct dirent *dp = 0;
            while ( 0 != (dp = readdir(dir)) )
              if ( strcmp(dp->d_name,".") && strcmp(dp->d_name,"..") )
                {
                  int m = dp->d_type == DT_DIR ?
                    FILE_LIST_DIRECTORIES : FILE_LIST_FILES;
                  if ( m & flags )
                    Array_Push(L,Str_Copy_Npl(dp->d_name,-1));
                }
          }
      #endif
      }
      
    return L;
  }
#endif
  ;

void File_Unlink(char *name, int force)
#ifdef _YOYO_FILE_BUILTIN
  {
    YOYO_FILE_STATS st;
    int i, err = 0;
    
    __Auto_Release
      {
        File_Get_Stats(name,&st,0);
    
        if ( st.f.exists )
          {
            if ( st.f.is_directory && force )
              {
                YOYO_ARRAY *L = File_List_Directory(name,0);
                for ( i = 0; i < L->count; ++i )
                  File_Unlink(Path_Join(name,L->at[i]),force);
              }
            else
              err =
              #ifdef __windoze
                _wunlink(Str_Utf8_To_Unicode(name));
              #else
                unlink(name);
              #endif
          }
      
        if ( err < 0 )
          File_Check_Error("unlink",0,name,1); 
      }
  }
#endif
  ;

void File_Rename(char *old_name, char *new_name)
#ifdef _YOYO_FILE_BUILTIN
  {
    int err = 0;
  #ifdef __windoze
    wchar_t *So = Str_Utf8_To_Unicode(old_name);
    wchar_t *Sn = Str_Utf8_To_Unicode(new_name);
    err = _wrename(So,Sn);
    Yo_Release(Sn);
    Yo_Release(So);
  #else
    err = rename(old_name,new_name);
  #endif
    if ( err < 0 )
      File_Check_Error("rename",0,old_name,1); 
  }
#endif
  ;
  
typedef struct _YOYO_CFILE
  {
    FILE *fd;
    char *name;
    int shared;
  } YOYO_CFILE;

int Raise_If_Cfile_Is_Not_Opened(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( !f || !f->fd )
      Yo_Raise(YO_ERROR_IO,
        Yo_Format("file '%s' is already closed",f->name)
        ,__Yo_FILE__,__LINE__);
    return 1;
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Close_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "close/@"); 
void Oj_Close(void *f) _YOYO_FILE_BUILTIN_CODE(
  { ((void(*)(void*))Yo_Find_Method_Of(&f,Oj_Close_OjMID,YO_RAISE_ERROR))
        (f); });

void Cfile_Close(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( f->fd )
      {
        fclose(f->fd);
        f->fd = 0;
      }
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Flush_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "flush/@"); 
void Oj_Flush(void *f) _YOYO_FILE_BUILTIN_CODE(
  { ((void(*)(void*))Yo_Find_Method_Of(&f,Oj_Flush_OjMID,YO_RAISE_ERROR))
        (f); });

void Cfile_Flush(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( f->fd )
      if ( fflush(f->fd) )
        {
          File_Check_Error("flush",0,f->name,1); 
        }
  }
#endif
  ;

void Cfile_Destruct(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    Cfile_Close(f);
    free(f->name);
    Yo_Object_Destruct(f);
  }
#endif
  ;

YOYO_FILE_STATS *Cfile_Stats(YOYO_CFILE *f,YOYO_FILE_STATS *st)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        _YOYO_stat fst = {0};
        int err;

      #ifdef __windoze
        #if !defined _FILEi32  
          err = _fstat64(fileno(f->fd),&fst);
        #else
          err = _fstat(fileno(f->fd),&fst);
        #endif
      #else
        err = fstat(fileno(f->fd),&fst);
      #endif        
        if ( err )
          File_Check_Error("getting stats",f->fd,f->name,0); 
        return File_Translate_Filestats(&fst,st);
      }
    return 0;
  };
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Eof_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "eof/@"); 
int Oj_Eof(void *f) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((int(*)(void*))Yo_Find_Method_Of(&f,Oj_Eof_OjMID,YO_RAISE_ERROR))
        (f); });

int Cfile_Eof(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( f->fd )
      {
        return feof(f->fd);
      }
    return 1;
  }
#endif
  ;

#define Oj_Read_Full(File,Buf,Count) Oj_Read(File,Buf,Count,-1)
_YOYO_FILE_EXTERN char Oj_Read_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "read/@*ii"); 
int Oj_Read(void *f,void *buf,int count,int min_count) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((int(*)(void*,void*,int,int))Yo_Find_Method_Of(&f,Oj_Read_OjMID,YO_RAISE_ERROR))
        (f,buf,count,min_count); });

int Cfile_Read(YOYO_CFILE *f, void *buf, int count, int min_count)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        int cc = 0;
        byte_t *d = (byte_t *)buf;
        if ( min_count < 0 ) min_count = count; 
        for ( ; cc < count ; )
          {
            int q = fread(d,1,count-cc,f->fd);
            if ( q <= 0 )
              {
                if ( feof(f->fd) )
                  {
                    if ( cc >= min_count ) 
                      break;
                    else 
                      Yo_Raise(YO_ERROR_IO,
                        Yo_Format("end of file '%s'",f->name), __FILE__,__LINE__);
                  }
                else 
                  File_Check_Error("read",f->fd,f->name,0);
              }
            if ( !q && cc >= min_count) break;
            cc += q;
            d += q;
          }
        return cc;
      }
    return 0;
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Read_Line_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "readline/@"); 
char *Oj_Read_Line(void *f) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((void *(*)(void*))Yo_Find_Method_Of(&f,Oj_Read_Line_OjMID,YO_RAISE_ERROR))
        (f); });

char *Cfile_Read_Line(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        int S_len = 0;
        char *S = 0;
        for(;;)
          {
            char S_local[512];
            char *q = fgets(S_local,sizeof(S_local),f->fd);
            if ( !q )
              {
                if ( feof(f->fd) )
                  break;
                else
                  File_Check_Error("readline",f->fd,f->name,0);
              }
            else
              {
                int q_len = strlen(q);
                S = Yo_Realloc(S,S_len+q_len+1);
                memcpy(S+S_len,q,q_len);
                S_len += q_len;
                if ( S[S_len-1] == '\n' ) 
                  {
                    S[S_len-1] = 0; 
                    break;
                  }
                else S[S_len] = 0;
              }
          }
        return S;
      }
    return 0;
  }
#endif
  ;

#define Oj_Write_Full(File,Buf,Count) Oj_Write(File,Buf,Count,-1)
_YOYO_FILE_EXTERN char Oj_Write_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "write/@*ii"); 
int Oj_Write(void *f,void *buf,int count,int min_count) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((int(*)(void*,void*,int,int))Yo_Find_Method_Of(&f,Oj_Write_OjMID,YO_RAISE_ERROR))
        (f,buf,count,min_count); });

int Cfile_Write(YOYO_CFILE *f, void *buf, int count, int min_count)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        int cc = 0;
        char *d = buf;
        for ( ; cc < count ; )
          {
            int q = fwrite(d,1,count-cc,f->fd);
            if ( q <= 0 )
              File_Check_Error("write",f->fd,f->name,0);
            if ( !q && cc >= min_count) 
              return cc;
            cc += q;
            d += q;
          }
        return cc;
      }
    return 0;
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Write_Line_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "writeline/@*"); 
void Oj_Write_Line(void *f,char *text) _YOYO_FILE_BUILTIN_CODE(
  { ((void(*)(void*,void*))Yo_Find_Method_Of(&f,Oj_Write_Line_OjMID,YO_RAISE_ERROR))
        (f,text); });

void Cfile_Write_Line(YOYO_CFILE *f, char *text)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        int Ln = text?strlen(text):0;
        if ( Ln )
          Cfile_Write(f,text,Ln,Ln);
        Cfile_Write(f,"\n",1,1);
        Cfile_Flush(f);
      }
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Tell_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "tell/@"); 
quad_t Oj_Tell(void *f) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((quad_t(*)(void*))Yo_Find_Method_Of(&f,Oj_Tell_OjMID,YO_RAISE_ERROR))
        (f); });

quad_t Cfile_Tell(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        quad_t q = 
        #ifdef __windoze 
          #if !defined _FILEi32  
            _ftelli64(f->fd);
          #else
            ftell(f->fd);
          #endif
        #else
            ftello(f->fd);
        #endif
        if ( q < 0 )
          File_Check_Error("tell",f->fd,f->name,0);
        return q;
      }
    return 0;
  }
#endif
  ;
  
_YOYO_FILE_EXTERN char Oj_Length_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "length/@"); 
quad_t Oj_Length(void *f) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((quad_t(*)(void*))Yo_Find_Method_Of(&f,Oj_Length_OjMID,YO_RAISE_ERROR))
        (f); });

quad_t Cfile_Length(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        YOYO_FILE_STATS st;
        return Cfile_Stats(f,&st)->length; 
      }
    return 0;
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Available_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "available/@"); 
quad_t Oj_Available(void *f) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((quad_t(*)(void*))Yo_Find_Method_Of(&f,Oj_Available_OjMID,YO_RAISE_ERROR))
        (f); });

quad_t Cfile_Available(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        YOYO_FILE_STATS st;
        return Cfile_Stats(f,&st)->length - Cfile_Tell(f); 
      }
    return 0;
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Read_All_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "readall/@"); 
YOYO_BUFFER *Oj_Read_All(void *f) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((void *(*)(void*))Yo_Find_Method_Of(&f,Oj_Read_All_OjMID,YO_RAISE_ERROR))
        (f); });

YOYO_BUFFER *Cfile_Read_All(YOYO_CFILE *f)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        void *L;
        quad_t len = Cfile_Available(f);
        if ( len > INT_MAX )
          Yo_Raise(YO_ERROR_IO,
            "file to big to be read in one pass",__Yo_FILE__,__LINE__);
        L = Buffer_Init((int)len);
        if ( len )
          Cfile_Read(f,Buffer_Begin(L),(int)len,(int)len);
        return L;
      }
    return 0;
  }
#endif
  ;

_YOYO_FILE_EXTERN char Oj_Seek_OjMID[] _YOYO_FILE_BUILTIN_CODE( = "seek/@qi"); 
quad_t Oj_Seek(void *f, quad_t pos, int whence) _YOYO_FILE_BUILTIN_CODE(
  { return 
      ((quad_t (*)(void*,quad_t,int whence))Yo_Find_Method_Of(&f,Oj_Seek_OjMID,YO_RAISE_ERROR))
        (f,pos,whence); });

quad_t Cfile_Seek(YOYO_CFILE *f, quad_t pos, int whence)
#ifdef _YOYO_FILE_BUILTIN
  {
    quad_t old = Cfile_Tell(f);
    if ( old < 0 ) return -1;
    
    if ( Raise_If_Cfile_Is_Not_Opened(f) )
      {
        int q = 
        #ifdef __windoze 
          #if !defined _FILEi32  
            _fseeki64(f->fd,pos,whence);
          #else
            fseek(f->fd,(long)pos,whence);
          #endif
        #else
            fseeko(f->fd,pos,whence);
        #endif
        if ( q < 0 )
          File_Check_Error("seek",f->fd,f->name,0);
        return old;
      }
    return 0;
  }
#endif
  ;

YOYO_CFILE *Cfile_Object(FILE *fd, char *name, int share)
#ifdef _YOYO_FILE_BUILTIN
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    Cfile_Destruct},
        {Oj_Close_OjMID,       Cfile_Close},
        {Oj_Read_OjMID,        Cfile_Read},
        {Oj_Write_OjMID,       Cfile_Write},
        {Oj_Read_Line_OjMID,   Cfile_Read_Line},
        {Oj_Write_Line_OjMID,  Cfile_Write_Line},
        {Oj_Read_All_OjMID,    Cfile_Read_All},
        {Oj_Seek_OjMID,        Cfile_Seek},
        {Oj_Tell_OjMID,        Cfile_Tell},
        {Oj_Length_OjMID,      Cfile_Length},
        {Oj_Available_OjMID,   Cfile_Available},
        {Oj_Eof_OjMID,         Cfile_Eof},
        {Oj_Flush_OjMID,       Cfile_Flush},
        {0}};
    YOYO_CFILE *f = Yo_Object(sizeof(YOYO_CFILE),funcs);
    f->fd = fd;
    f->shared = share;
    f->name = name?Str_Copy_Npl(name,-1):"<file>";
    return f;
  }
#endif
  ;

enum _YOYO_FILE_ACCESS_FLAGS
  {
    YOYO_FILE_READ        = 1,
    YOYO_FILE_WRITE       = 2,
    YOYO_FILE_READWRITE   = YOYO_FILE_READ|YOYO_FILE_WRITE,
    YOYO_FILE_FORWARD     = 32,
    YOYO_FILE_TEXT        = 64, // by default is binary mode
    YOYO_FILE_CREATE_PATH = 128, // create expected path if doesn't exists
    YOYO_FILE_APPEND      = 256,
    
    //_YOYO_FILE_NEED_EXITENT_FILE = 0x080000,
    YOYO_FILE_OPENEXISTS  = 0x000000, // open if exists
    YOYO_FILE_CREATENEW   = 0x010000, // error if exists
    YOYO_FILE_OPENALWAYS  = 0x020000, // if not exists create new
    YOYO_FILE_CREATEALWAYS= 0x030000, // if exists unlink and create new
    YOYO_FILE_OVERWRITE   = 0x040000, // if exists truncate
    YOYO_FILE_CREATE_MASK = 0x0f0000,
    
    YOYO_FILE_CREATE      = YOYO_FILE_READWRITE|YOYO_FILE_CREATE_PATH|YOYO_FILE_CREATEALWAYS,
    YOYO_FILE_REUSE       = YOYO_FILE_READWRITE|YOYO_FILE_OPENALWAYS,
    YOYO_FILE_CONSTANT    = YOYO_FILE_READ|YOYO_FILE_OPENEXISTS,
    YOYO_FILE_MODIFY      = YOYO_FILE_READWRITE|YOYO_FILE_OPENEXISTS, 
  };

void File_Check_Access_Is_Satisfied(char *path, uint_t access)
#ifdef _YOYO_FILE_BUILTIN
  {
    YOYO_FILE_STATS st = {0};
    File_Get_Stats(path,&st,0);

    if ( (access & YOYO_FILE_CREATE_PATH) && !st.f.exists )
      Create_Required_Dirs(path);

    if ( st.f.exists )
      if (st.f.is_directory )
        Yo_Raise(YO_ERROR_IO,
          Yo_Format("file '%s' is directory",path),__Yo_FILE__,__LINE__);
      else if ( (access & YOYO_FILE_CREATE_MASK) == YOYO_FILE_CREATENEW  )
        Yo_Raise(YO_ERROR_IO,
          Yo_Format("file '%s' already exists",path),__Yo_FILE__,__LINE__);
      else if ( (access & YOYO_FILE_CREATE_MASK) == YOYO_FILE_CREATEALWAYS )
        File_Unlink(path,0);
      else;
    else if ( (access & YOYO_FILE_CREATE_MASK) == YOYO_FILE_OPENEXISTS )
      Yo_Raise(YO_ERROR_DOESNT_EXIST,
        Yo_Format("file '%s' does not exist",path),__Yo_FILE__,__LINE__);
  }
#endif
  ;

uint_t File_Access_From_Str(char *S)
#ifdef _YOYO_FILE_BUILTIN
  {
    uint_t access = 0;
    for ( ;*S; ++S )
      switch (*S)
        {
          case '+': access |= YOYO_FILE_WRITE; /*falldown*/
          case 'r': access |= YOYO_FILE_READ; break;
          case 'a': access |= 
            YOYO_FILE_WRITE
            |YOYO_FILE_APPEND
            |YOYO_FILE_FORWARD
            |YOYO_FILE_OPENALWAYS;
          case 'w': access |= YOYO_FILE_WRITE|YOYO_FILE_OVERWRITE; break;
          case 'c': access |= YOYO_FILE_WRITE|YOYO_FILE_CREATEALWAYS; break;
          case 't': access |= YOYO_FILE_TEXT; break;
          case 'P': access |= YOYO_FILE_CREATE_PATH; break;
          default: break;
        }
    return access;
  }
#endif
  ;

#define File_Open(Name,Access) Cfile_Open(Name,Access)
void *Cfile_Open(char *name, char *access)
#ifdef _YOYO_FILE_BUILTIN
  {
    void *f = 0;
    __Auto_Ptr(f)
      {
        File_Check_Access_Is_Satisfied(name,File_Access_From_Str(access));
      #ifdef __windoze
        if ( 0 != (f = _wfopen(Str_Utf8_To_Unicode(name),Str_Utf8_To_Unicode(access))) )
      #else
        if ( 0 != (f = fopen(name,access)) )
      #endif
          f = Cfile_Object(f,name,0);
        else
          File_Check_Error("open file",0,name,1);
      }
    return f;
  }
#endif
  ;

#define Cfile_Acquire(Name,Fd) Cfile_Object(Fd,Name,0)
#define Cfile_Share(Name,Fd)   Cfile_Object(Fd,Name,1)

#endif /* C_once_E9479D04_5D69_4A1A_944F_0C99A852DC0B */

