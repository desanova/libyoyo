
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
#include "random.hc"

#ifndef __windoze
# include <dirent.h>
# include <sys/file.h>
#endif

enum { YOYO_FILE_COPY_BUFFER_SIZE = 4096, };

#ifdef _YOYO_FILE_BUILTIN
# define _YOYO_FILE_BUILTIN_CODE(Code) Code
# define _YOYO_FILE_EXTERN
#else
# define _YOYO_FILE_BUILTIN_CODE(Code)
# define _YOYO_FILE_EXTERN extern
#endif

char *Path_Basename(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
    char *ret = 0;
    char *p = strrchr(path,'/');
  #ifdef __windoze
    char *p2 = strrchr(path,'\\');
    if ( !p || p < p2 ) p = p2;
  #endif
    if ( p )
      ret = Str_Copy(p+1,-1);
    return ret;
  }
#endif
  ;

char *Path_Dirname(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
    char *ret = 0;
    char *p = strrchr(path,'/');
  #ifdef __windoze
    char *p2 = strrchr(path,'\\');
    if ( !p || p < p2 ) p = p2;
  #endif
    if ( p )
      {
        if ( p-path > 0 )
          ret = Str_Copy(path,p-path);
        else
        #ifdef __windoze
          ret = Str_Copy("\\",1);
        #else
          ret = Str_Copy("/",1);
        #endif
      }
    return ret;
  }
#endif
  ;

char *Current_Directory()
#ifdef _YOYO_FILE_BUILTIN
  {
    enum { tmp_len = 512 };
    char *ptr = 0;
    __Auto_Ptr(ptr)
      {
      #ifdef __windoze
        wchar_t *tmp = __Malloc((tmp_len+1)*sizeof(wchar_t));
        ptr = Str_Unicode_To_Utf8(_wgetcwd(tmp,tmp_len));
      #else
        char *tmp = __Malloc(tmp_len+1);
        ptr = Str_Copy(getcwd(tmp,tmp_len),-1);
      #endif
      }
    return ptr;
  }
#endif
  ;

char *Path_Unique_Name(char *dirname,char *pfx, char *sfx)
  {
  #ifdef __windoze
    char DELIMITER[] = "\\";
  #else
    char DELIMITER[] = "/";
  #endif
    char unique[2+4+6] = {0};
    char out[(sizeof(unique)*8+5)/6+1] = {0};
    int pid = getpid();
    uint_t tmx = (uint_t)time(0);
    Unsigned_To_Two(pid,unique);
    Unsigned_To_Four(tmx,unique+2);
    System_Random(unique+6,sizeof(unique)-6);
    Str_Xbit_Encode(unique,sizeof(unique)*8,6,Str_6bit_Encoding_Table,out);
    if ( dirname )
      return Str_Join_5(0,dirname,DELIMITER,(pfx?pfx:""),out,(sfx?sfx:""));
    else
      return Str_Join_3(0,(pfx?pfx:""),out,(sfx?sfx:""));
  }

char *Path_Join(char *dir, char *name)
#ifdef _YOYO_FILE_BUILTIN
  {
  #ifdef __windoze
    enum { DELIMITER = '\\' };
  #else
    enum { DELIMITER = '/' };
  #endif
    if ( dir && *dir )
      {
        int L = strlen(dir);
        while ( *name == DELIMITER ) ++name;
        if ( dir[L-1] == DELIMITER )
          return Str_Concat(dir,name);
        else
          return Str_Join_2(DELIMITER,dir,name);
      }
    else
      return Str_Copy(name,-1);
  }
#endif
  ;

char *Path_Suffix(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
    char *ret = 0;
    char *p = strrchr(path,'.');
    if ( p )
      {
        char *p1 = strrchr(path,'/');
        if ( p1 && p1 > p ) p = p1;
      #ifdef __windoze
        __Gogo 
          {
            char *p2 = strrchr(path,'\\');
            if ( p2 && p2 > p ) p = p2;
          }
      #endif
      }
    if ( p && *p == '.' )
      ret = Str_Copy(p,-1);
    return ret;
  }
#endif
  ;

char *Path_Fullname(char *path)
#ifdef _YOYO_FILE_BUILTIN
  {
  #ifdef __windoze
    if ( path )
      {
        wchar_t *foo;
        char *ret;
        __Auto_Ptr(ret)
          {
            wchar_t *tmp = __Malloc((MAX_PATH+1)*sizeof(wchar_t));
            *tmp = 0;
            GetFullPathNameW(Str_Utf8_To_Unicode(path),MAX_PATH,tmp,&foo);
            ret = Str_Unicode_To_Utf8(tmp);
          }
        return ret;
      }
  #else
    if ( path && *path != '/' )
      {
        char *ret = 0;
        __Auto_Ptr(ret) ret = Path_Join(Current_Directory(),path);
        return ret;
      }
  #endif
    return Str_Copy(path,-1);
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
      Yo_Raise(YOYO_ERROR_IO,
        Yo_Format("%s failed on file '%s': %s",op,fname,errS),
        __FILE__,__LINE__);
  }
#endif
  ;

#define Raise_If_File_Error(Op,Fname) File_Check_Error(Op,0,Fname,1)
  

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
      Yo_Raise(YOYO_ERROR_IO,
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
                      Yo_Raise(YOYO_ERROR_IO,
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
          Yo_Raise(YOYO_ERROR_IO,
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
        Yo_Raise(YOYO_ERROR_IO,
          Yo_Format("file '%s' is directory",path),__Yo_FILE__,__LINE__);
      else if ( (access & YOYO_FILE_CREATE_MASK) == YOYO_FILE_CREATENEW  )
        Yo_Raise(YOYO_ERROR_IO,
          Yo_Format("file '%s' already exists",path),__Yo_FILE__,__LINE__);
      else if ( (access & YOYO_FILE_CREATE_MASK) == YOYO_FILE_CREATEALWAYS )
        File_Unlink(path,0);
      else;
    else if ( (access & YOYO_FILE_CREATE_MASK) == YOYO_FILE_OPENEXISTS )
      Yo_Raise(YOYO_ERROR_DOESNT_EXIST,
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
          case 'n': access |= YOYO_FILE_WRITE|YOYO_FILE_CREATENEW; break;
          case 't': access |= YOYO_FILE_TEXT; break;
          case 'P': access |= YOYO_FILE_CREATE_PATH; break;
          default: break;
        }
    return access;
  }
#endif
  ;

#define File_Open(Name,Access) Cfile_Open(Name,Access)

void Cfile_Remove_Nonstandard_AC(char *nonst, char *ac)
#ifdef _YOYO_FILE_BUILTIN
  {
    int ac_a = 0;
    int ac_r = 0;
    int ac_w = 0;
    int ac_plus = 0;
    int ac_t = 0;
    int ac_b = 0;
    
    for ( ; *nonst; ++nonst )
      switch ( *nonst )
        {
          case '+': ac_plus = 1; break;
          case 'r': ac_r = 1; break;
          case 'w': ac_w = 1; break;
          case 'a': ac_a = 1; break;
          case 't': ac_t = 1; break;
          case 'b': ac_b = 1; break;
          case 'n': ac_w = ac_plus = 1; break;
        }
        
    if ( ac_w ) *ac++ = 'w';
    else if ( ac_r ) *ac++ = 'r';
    if ( ac_plus ) *ac++ = '+';
    if ( ac_t ) *ac++ = 't';
    else *ac++ = 'b';    
    *ac = 0;
  }
#endif
  ;

void *Cfile_Open_Raw(char *name, char *access)
#ifdef _YOYO_FILE_BUILTIN
  {
    char ac[9];
    void *f = 0;
    
    // always binary mode if 't' not declared manualy
    Cfile_Remove_Nonstandard_AC(access,ac);
    
    #ifdef __windoze
      if ( 0 != (f = _wfopen(Str_Utf8_To_Unicode(name),Str_Utf8_To_Unicode(ac))) )
    #else
      if ( 0 != (f = fopen(name,ac)) )
    #endif
        f = Cfile_Object(f,name,0);
        
    return f;
  }
#endif
  ;

void *Cfile_Open(char *name, char *access)
#ifdef _YOYO_FILE_BUILTIN
  {
    void *f = 0;
    __Auto_Ptr(f)
      {
        File_Check_Access_Is_Satisfied(name,File_Access_From_Str(access));
        f = Cfile_Open_Raw(name,access);
        if ( !f )
          File_Check_Error("open file",0,name,1);
      }
    return f;
  }
#endif
  ;

#define Cfile_Acquire(Name,Fd) Cfile_Object(Fd,Name,0)
#define Cfile_Share(Name,Fd)   Cfile_Object(Fd,Name,1)

int Oj_Write_BOM(void *f,int bom)
#ifdef _YOYO_FILE_BUILTIN
  {
    switch( bom )
      {
        case YOYO_BOM_DOESNT_PRESENT:
          return 0; // none
        case YOYO_BOM_UTF16_LE:
          return Oj_Write(f,"\xff\xfe",2,2);
        case YOYO_BOM_UTF16_BE:
          return Oj_Write(f,"\xfe\xff",2,2);
        case YOYO_BOM_UTF8:
          return Oj_Write(f,"\xef\xbb\xbf",3,3);
        default:
          __Raise(YOYO_ERROR_INVALID_PARAM,__yoTa("bad BOM identifier",0));
      }
      
    return 0; /*fake*/
  }
#endif
  ;

#define __Pfd_Lock(Pfd) __Interlock_Opt( (void)0, Pfd, __Pfd_Lock_In, __Pfd_Lock_Out, __Pfd_Lock_Out )

#ifdef __windoze

#define   LOCK_SH   1    /* shared lock */
#define   LOCK_EX   2    /* exclusive lock */
#define   LOCK_NB   4    /* don't block when locking */
#define   LOCK_UN   8    /* unlock */

int flock(int fd, int opt)
#ifdef _YOYO_FILE_BUILTIN
  {
    return 0;
  }
#endif
  ;

#endif /* __windoze */

void __Pfd_Lock_In(int *pfd) 
#ifdef _YOYO_FILE_BUILTIN
  {
    STRICT_REQUIRE(pfd);
    
    if ( flock(*pfd,LOCK_EX) )
      __Raise(YOYO_ERROR_IO,"failed to lock file");
  }
#endif
  ;

void __Pfd_Lock_Out(int *pfd) 
#ifdef _YOYO_FILE_BUILTIN
  {
    STRICT_REQUIRE(pfd);
    
    if ( flock(*pfd,LOCK_UN) )
      if ( errno != EBADF )
        __Fatal(YOYO_FATAL_ERROR,"failed to unlock file");
  }
#endif
  ;

#define __Pfd_Guard(Pfd) __Interlock_Opt( (void)0, Pfd, (void), __Pfd_Guard_Out, __Pfd_Guard_Out )
void __Pfd_Guard_Out(int *pfd) 
#ifdef _YOYO_FILE_BUILTIN
  {
    STRICT_REQUIRE(pfd);
    
    if ( *pfd >= 0 )
      {
        close(*pfd);
        *pfd = -1;
      }
  }
#endif
  ;

int Oj_Copy_File(void *src, void *dst)
#ifdef _YOYO_FILE_BUILTIN
  {
    char bf[YOYO_FILE_COPY_BUFFER_SIZE];
    int count = 0;
    int (*xread)(void*,void*,int,int) = Yo_Find_Method_Of(&src,Oj_Read_OjMID,YO_RAISE_ERROR);
    int (*xwrite)(void*,void*,int,int) = Yo_Find_Method_Of(&dst,Oj_Write_OjMID,YO_RAISE_ERROR);
    for ( ;; )
      {
        int i = xread(src,bf,YOYO_FILE_COPY_BUFFER_SIZE,0);
        if ( !i ) break;
        xwrite(dst,bf,i,i);
        count += i;
      }
    return count;
  }
#endif
  ;

#define Write_Out(Fd,Data,Count) Fd_Write_Out(Fd,Data,Count,0)
#define Write_Out_Raise(Fd,Data,Count) Fd_Write_Out(Fd,Data,Count,1)
int Fd_Write_Out(int fd, void *data, int count, int do_raise) 
#ifdef _YOYO_FILE_BUILTIN
  {
    int i;
    
    for ( i = 0; i < count;  )
      {
        int r = write(fd,(char*)data+i,count-i);
        if ( r >= 0 )
          i += r;
        else if ( errno != EAGAIN )
          {
            int err = errno;
            if ( do_raise )
              __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to write file: %s",0),strerror(err)));
            return err;
          }
      }
      
    return 0;
  }
#endif
  ;

#define Read_Into(Fd,Data,Count) Fd_Read_Into(Fd,Data,Count,0)
#define Read_Into_Raise(Fd,Data,Count) Fd_Read_Into(Fd,Data,Count,1)
int Fd_Read_Into(int fd, void *data, int count, int do_raise) 
#ifdef _YOYO_FILE_BUILTIN
  {
    int i;
    
    for ( i = 0; i < count;  )
      {
        int r = read(fd,(char*)data+i,count-i);
        if ( r >= 0 )
          i += r;
        else if ( errno != EAGAIN )
          {
            int err = errno;
            if ( do_raise )
              __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to read file: %s",0),strerror(err)));
            return err;
          }
      }
      
    return 0;
  }
#endif
  ;

#define Lseek(Fd,Pos) Fd_Lseek(Fd,Pos,0)
#define Lseek_Raise(Fd,Pos) Fd_Lseek(Fd,Pos,1)
int Fd_Lseek(int fd, quad_t pos, int do_raise)
#ifdef _YOYO_FILE_BUILTIN
  {
    if ( lseek(fd,pos,(pos<0?SEEK_END:SEEK_SET)) < 0 )
      {
        int err = errno;
        if ( do_raise )
          __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to seek file: %s",0),strerror(err)));
        return err;
      }
    return 0;
  }
#endif
  ;

#define Open_File(Name,Opt) Fd_Open_File(Name,Opt,0600,0)
#define Open_File_Raise(Name,Opt) Fd_Open_File(Name,Opt,0600,1)
int Fd_Open_File(char *name, int opt, int secu, int do_raise)
#ifdef _YOYO_FILE_BUILTIN
  {
    int fd;
    #ifdef __windoze
      fd = _wopen(Str_Utf8_To_Unicode(name),opt,secu);
    #else
      fd = open(name,opt,secu);
    #endif
    if ( fd < 0 )
      {
        int err = errno;
        if ( do_raise )
          __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to seek file: %s",0),strerror(err)));
        return -err;
      }
    return fd;
  }
#endif
  ;
  
void File_Move(char *old_name, char *new_name)
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
    if ( errno == EXDEV )
      __Auto_Release 
        {
          void *src = Cfile_Open(old_name,"r");
          void *dst = Cfile_Open(new_name,"w+P");
          Oj_Copy_File(src,dst);
          File_Unlink(old_name,0);
        }
    else if ( err < 0 )
      {
        File_Check_Error("rename",0,old_name,1); 
      }
  }
#endif
  ;

enum 
  { 
    YOYO_STDF_PUMP_BUFFER = 1*KILOBYTE,
    YOYO_STDF_PUMP_BUFFER_W = YOYO_STDF_PUMP_BUFFER-1,
  };

int Stdf_Read_In(FILE *stdf,char *buf, int L)
#ifdef _YOYO_FILE_BUILTIN
  {
    int i;
    for ( i = 0; i < L; )
      {
        int q = fread(buf+i,1,L-i,stdf);
        if ( q ) 
          i += q;
        else if ( feof(stdf) )
          break;
        else
          {
            int err = ferror(stdf);
            if ( err == EAGAIN ) continue;
            __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to read: %s",0),strerror(err)));
          }
      }
    buf[i] = 0;
    return i;
  }
#endif
  ;
  
#define Stdf_Pump(stdf,buf) Stdf_Read_In(stdf,buf,YOYO_STDF_PUMP_BUFFER_W)

char *Stdf_Pump_Part(FILE *stdf, char *buf, char *S, int *L)
#ifdef _YOYO_FILE_BUILTIN
  {
    int l = *L;
    if ( !S ) S = buf+l;
    l -= ( S-buf);
    if ( l ) memmove(buf,S,l);
    l += Stdf_Read_In(stdf,buf+l,YOYO_STDF_PUMP_BUFFER_W-l);
    *L = l;
    STRICT_REQUIRE(l <= YOYO_STDF_PUMP_BUFFER_W);
    buf[l] = 0;
    return buf;
  }
#endif
  ;
  
#define Stdin_Pump(B) Stdf_Pump(stdin,B)
#define Stdin_Pump_Part(B,S,L) Stdf_Pump_Part(stdin,B,S,L)

/* returns -1 if error and read bytes count on success */
typedef int Unknown_Write_Proc(void *buf, longptr_t f, int count, int *err);

int Stdf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_FILE_BUILTIN
  {
    int q = fwrite(buf,1,count,(FILE*)f);
    if ( !q )
      {
        *err = ferror((FILE*)f);
        q = -1;
      }
    return q;
  }
#endif
  ;

int Fdf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_FILE_BUILTIN
  {
    int q = write((int)f,buf,count);
    if ( q < 0 )
      q = errno;
    return q;
  }
#endif
  ;

int Bf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_FILE_BUILTIN
  {
    Buffer_Append((YOYO_BUFFER*)f,buf,count);
    return count;
  }
#endif
  ;

int Cf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_FILE_BUILTIN
  {
    return Stdf_Write(buf,(longptr_t)((YOYO_CFILE*)f)->fd,count,err);
  }
#endif
  ;

int Unknown_Write(longptr_t f, void *bf, int count, Unknown_Write_Proc xwrite)
#ifdef _YOYO_FILE_BUILTIN
  {
    int i;
    for ( i = 0; i < count; )
      {
        int err = 0;
        int r = xwrite((char*)bf+i,f,count-i,&err);
        if ( r > 0 ) i += r;
        else if ( err != EAGAIN )
          __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to write: %s",0),strerror(err)));
      }
    return i;
  }
#endif
  ;

#endif /* C_once_E9479D04_5D69_4A1A_944F_0C99A852DC0B */

