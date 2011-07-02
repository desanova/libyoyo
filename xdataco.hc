
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

#ifndef C_once_019A9F9B_7D69_46F7_89D9_2C330BDFA526
#define C_once_019A9F9B_7D69_46F7_89D9_2C330BDFA526

#include "core.hc"
#include "buffer.hc"
#include "xdata.hc"
#include "file.hc"
#include "defpars.hc"
#include "mime.hc"
#include "datetime.hc"

#ifdef _YOYO_XDATACO_BUILTIN
# define _YOYO_XDATACO_BUILTIN_CODE(Code) Code
# define _YOYO_XDATACO_EXTERN 
#else
# define _YOYO_XDATACO_BUILTIN_CODE(Code)
# define _YOYO_XDATACO_EXTERN extern 
#endif

enum
  {
    YOYO_XDATA_CO_DOC_TEXT   = 'A',
    YOYO_XDATA_CO_DOC_BINARY = 'B',
    YOYO_XDATA_CO_DOC_ZIPPED = 'Z',
    YOYO_XDATA_CO_MEDIA_FS   = 0x4653 /* 'FS' */,
    YOYO_XDATA_CO_MEDIA_BDB  = 0x424424 /* 'BDB' */,
    YOYO_XDATA_CO_MAX_FS_KEYLEN = 128,
    YOYO_XDATA_CO_MAX_BDB_KEYLEN = 128,
    YOYO_XDATA_CO_UUID_LENGTH = 9,
  };

typedef struct _YOYO_XDATA_CO
  {
    char *basepath;
    int  jur_fd;
    int  fs_depth;
    int  media_type;
    int  doc_format;
    YOYO_XDATA *cf;
  } YOYO_XDATA_CO;
  
typedef struct _YOYO_XDATA_STREAM
  {
    YOYO_XDATA_CO *co;
    char *key;
    int  mimetype;
    int  length;
    int  finished;
    void (*Close)();
    char *(*Commit)();
    int  (*Read)();
    int  (*Write)();
    int  (*Rewind)();
    int  (*Skip)();
    int  (*Available)();
  } YOYO_XDATA_STREAM;
  
typedef struct _YOYO_XDATA_FS_STREAM
  {
    YOYO_XDATA_STREAM strm;
    char *tmp_path;
    int fd;
    int curpos;
  } YOYO_XDATA_FS_STREAM;

typedef struct _YOYO_XDATA_CO_FS_STRM_HEADER
  {
    char cr;
    char nl;
    char mimetype[4];
    char length[8];
    char lastacs[8];
    char created[8];
    char compressed;
    char keylen[2];
    char key[YOYO_XDATA_CO_MAX_FS_KEYLEN];
    char nulterm;
  } YOYO_XDATA_CO_FS_STRM_HEADER;

typedef struct _YOYO_XDATA_SEQ
  {
    YOYO_XDATA_CO *co;
    void (*Close)();
    void (*Add)();
    YOYO_XDATA *(*Next)();
    YOYO_ARRAY *(*Multi_Next)();
    void (*Erase)();
  } YOYO_XDATA_SEQ;

typedef struct _YOYO_XDATA_FS_SEQ_JUR
  {
    byte_t version[8];
    quad_t datetime;
    quad_t first_page;
    quad_t last_page;
    int    first_recno;
    int    reco_next;
  } YOYO_XDATA_SEQ_JUR;

typedef struct _YOYO_XDATA_FS_SEQ
  {
    YOYO_XDATA_SEQ seq;
    char *path;
    quad_t page;
    int    recno;
    int    jur_fd;
  } YOYO_XDATA_FS_SEQ;

enum { YOYO_XDATA_FS_SEQ_RECO_COUNT = 1024 }; /* 24K per page */

typedef struct _YOYO_XDATA_FS_SEQ_RECO
  {
    byte_t md5[16];
  } YOYO_XDATA_FS_SEQ_RECO;

#ifndef _YOYO_XDATACO_BUILTIN 
extern
#endif
byte_t YOYO_XDATA_SEQ_JUR_VERSION[8] 
#ifdef _YOYO_XDATACO_BUILTIN 
= {'S','E','Q','0','0','1','\r','\n'}
#endif
;
  
#ifndef _YOYO_XDATACO_BUILTIN 
extern
#endif
char YOYO_XDATA_CO_DEFAULT_CF[] 
#ifdef _YOYO_XDATACO_BUILTIN 
= "depth = 2\n"
  "media = fs\n" /* bdb is not implemented yet */
  "format = zipped\n"
#endif
  ;

#ifndef _YOYO_XDATACO_BUILTIN 
extern
#endif
char YOYO_XDATA_CO_DEVELOPER_CF[]
#ifdef _YOYO_XDATACO_BUILTIN 
= "depth = 0\n"
  "media = fs\n"
  "format = text\n"
#endif
  ;

void YOYO_XDATA_CO_Destruct(YOYO_XDATA_CO *co)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    free(co->basepath);
    if (co->jur_fd >= 0) close(co->jur_fd);
    __Unrefe(co->cf);
    __Destruct(co);
  }
#endif
  ;
  
char *Xdata_Get_Key(YOYO_XDATA *doc)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return Xnode_Value_Get_Str(&doc->root,"$key$",0);
  }
#endif
  ;
  
int Xdata_Get_Revision(YOYO_XDATA *doc)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return Xnode_Value_Get_Int((YOYO_XNODE*)doc,"$rev$",0);
  }
#endif
  ;
  
void Xdata_Set_Revision(YOYO_XDATA *doc, int rev)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    Xnode_Value_Set_Int((YOYO_XNODE*)doc,"$rev$",rev);
  }
#endif
  ;

YOYO_XDATA *Xdata_Co_Binary_Decode(byte_t *at,int count,int zipped)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA *doc = Xdata_Init();
    return doc;
  }
#endif
  ;

void Xdata_Co_Binary_Encode_Into(YOYO_BUFFER *bf, YOYO_XDATA *doc, int zipped)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
  }
#endif
  ;

YOYO_BUFFER *Xdata_Co_Encode(YOYO_XDATA_CO *co, YOYO_XDATA *doc)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    char prefix[] = ".,.,.,.,_\n\n\n";
    YOYO_BUFFER *bf = Buffer_Init(0);
    
    Unsigned_To_Hex8(Xdata_Get_Revision(doc),prefix);
    prefix[8] = (char)co->doc_format;
    Buffer_Append(bf,prefix,12);
    
    if ( co->doc_format == YOYO_XDATA_CO_DOC_TEXT )
      Def_Format_Into(bf,&doc->root,0);
    else if ( co->doc_format == YOYO_XDATA_CO_DOC_BINARY )
      Xdata_Co_Binary_Encode_Into(bf,doc,0);
    else if ( co->doc_format == YOYO_XDATA_CO_DOC_ZIPPED )
      Xdata_Co_Binary_Encode_Into(bf,doc,1);
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported document format");
      
    return bf;
  }
#endif
  ;

YOYO_XDATA *Xdata_Co_Decode(YOYO_XDATA_CO *co, byte_t *at,int count)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA *doc = 0;
    
    if ( count < 12 ) 
      __Raise(YOYO_ERROR_CORRUPTED,"document is corrupted");
    
    switch ( at[8] )
      {
        case YOYO_XDATA_CO_DOC_TEXT:
          doc = Def_Parse_Str(at+9); /* Yes, 9! Not 12!! */
          break;
        case YOYO_XDATA_CO_DOC_BINARY:
          doc = Xdata_Co_Binary_Decode(at+12,count-12,0);
          break;
        case YOYO_XDATA_CO_DOC_ZIPPED:
          doc = Xdata_Co_Binary_Decode(at+12,count-12,1);
          break;
        default:
          __Raise(YOYO_ERROR_INCONSISTENT,"unsupported document format");
      }
      
    return doc;
  }
#endif
  ;

int Xdata_Co_Parse_Media(char *S)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( S )
      {
        if ( !strcmp(S,"fs") ) return YOYO_XDATA_CO_MEDIA_FS;
        if ( !strcmp(S,"> bdb") ) return YOYO_XDATA_CO_MEDIA_BDB;
      }
    __Raise(YOYO_ERROR_ILLFORMED,"invalid media type, should be 'fs' or 'bdb'");
    return 0; /* fake */
  }
#endif 
  ;
  
int Xdata_Co_Parse_Format(char *S)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( S )
      {
        if ( !strcmp(S,"text") ) return YOYO_XDATA_CO_DOC_TEXT;
        if ( !strcmp(S,"binary") ) return YOYO_XDATA_CO_DOC_BINARY;
        if ( !strcmp(S,"zipped") ) return YOYO_XDATA_CO_DOC_ZIPPED;
      }
    __Raise(YOYO_ERROR_ILLFORMED,"invalid document format, should be 'text', 'binary' or 'zipped'");
    return 0; /* fake */
  }
#endif
  ;
  

YOYO_XDATA_CO *Xdata_Co_Init_(char *path, int create_new, char *default_cf)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    
    YOYO_XDATA_CO *co = 0;
    YOYO_FILE_STATS bp_stats = {0};
    YOYO_FILE_STATS jr_stats = {0};
    YOYO_FILE_STATS cf_stats = {0};
    
    __Auto_Ptr(co)
      {
        char *cf_name = Str_Join_2('/',path,".coconf");
        char *jr_name = Str_Join_2('/',path,".cojur");
        char *tmp_dir = Str_Join_2('/',path,"tmp");
    
        File_Get_Stats(path,&bp_stats,1);
        File_Get_Stats(cf_name,&cf_stats,1);
        File_Get_Stats(jr_name,&jr_stats,1);
    
        if ( create_new )
          {
            int foo;
            if ( jr_stats.f.exists )
              __Raise(YOYO_ERROR_ALREADY_EXISTS,__Format("collection '%s' already exists",path));
            if ( !cf_stats.f.exists )
              __Auto_Release 
              {
                char *dflt_coconf = default_cf?default_cf:YOYO_XDATA_CO_DEFAULT_CF;
                int dflt_coconf_L = strlen(dflt_coconf);
                Cfile_Write(Cfile_Open(cf_name,"nP"),
                              dflt_coconf,
                              dflt_coconf_L,
                              dflt_coconf_L);
              }
            foo = open(jr_name,O_CREAT|O_WRONLY,0660);
            if ( foo >= 0 )
              close(foo);
            else
              Raise_If_File_Error("create",jr_name);
          }
        else
          {
            if ( !bp_stats.f.exists || !cf_stats.f.exists || !jr_stats.f.exists )
              __Raise(YOYO_ERROR_DOESNT_EXIST,__Format("collection '%s' doesn't exist",path));
          }
        
        co = __Object_Dtor(sizeof(YOYO_XDATA_CO),YOYO_XDATA_CO_Destruct);
        co->basepath = Str_Copy_Npl(path,-1);
        co->cf = __Refe(Def_Parse_File(cf_name));
        co->fs_depth = Xnode_Value_Get_Int(co->cf,"depth",0);
        co->media_type = Xdata_Co_Parse_Media(Xnode_Value_Get_Str(co->cf,"media",0));
        co->doc_format = Xdata_Co_Parse_Format(Xnode_Value_Get_Str(co->cf,"format",0));
        
        co->jur_fd = open(jr_name,O_WRONLY|O_APPEND);
        if ( co->jur_fd < 0 ) 
          Raise_If_File_Error("open",jr_name); 
        
        if ( !File_Exists(tmp_dir) )
          Create_Directory(tmp_dir);
      }
      
    return co;
  }
#endif
  ;


YOYO_XDATA_CO *Xdata_Co_Open(char *path)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return Xdata_Co_Init_(path,0,0);
  }
#endif
  ;

YOYO_XDATA_CO *Xdata_Co_Create(char *path, char *default_cf)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return Xdata_Co_Init_(path,1,default_cf);
  }
#endif
  ;

char *Xdata_Co_Build_Unique_Key_Npl()
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int pid = getpid();
    time_t tmx = time(0);
    double clo = clock();
    
    byte_t uuid[YOYO_XDATA_CO_UUID_LENGTH] = {0,0,0,0,0,0,0,0}; /* 8 bytes garanty */
    char   out[(YOYO_XDATA_CO_UUID_LENGTH*8+5)/6 + 3 ] = {'=','=',0};
    
    Unsigned_To_Two(pid,uuid);
    Unsigned_To_Four((uint_t)tmx,uuid+2);
    Unsigned_To_Two((uint_t)((clo/CLOCKS_PER_SEC)*10000),uuid+6);
    System_Random(uuid+6,sizeof(uuid)-6);
    Str_Xbit_Encode(uuid,sizeof(uuid)*8,6,Str_6bit_Encoding_Table,out+2);
    
    STRICT_REQUIRE( out[sizeof(out)-1] == 0 );
    
    return __Memcopy_Npl(out,sizeof(out));
  }
#endif
  ;

char *Xdata_Co_Fs_Tmp_File_Path_Sfx(YOYO_XDATA_CO *co, char *sfx)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    char *S = __Pool(Xdata_Co_Build_Unique_Key_Npl());
    if ( sfx )
      S = Str_Concat(S,sfx);
    return Str_Join_3('/',co->basepath,"tmp",S);
  }
#endif
  ;

char *Xdata_Co_Fs_File_Path_Sfx_Md5(YOYO_XDATA_CO *co, byte_t *md5, char *sfx)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    char *S = 0;
    int i;
    char md5_hex[33] = {0};
    char hash[4*3] = "\0\0/\0\0/\0\0/\0\0";
    for ( i = 0; i < 16; ++i )
      Str_Hex_Byte(md5[i],0,md5_hex+i*2);
    if ( !co->fs_depth )
      {
        S = Str_Join_2('/',co->basepath,md5_hex);
      }
    else
      {
        switch ( co->fs_depth )
          {
            case 1:
              {
                byte_t c = Crc_8(0,md5,16);
                Str_Hex_Byte(c,0,hash);
                hash[2] = 0;
                break;
              }
            case 2:
              {
                ushort_t c = Crc_16(0,md5,16);
                for ( i = 0; i < 2; ++i )
                  Str_Hex_Byte((byte_t)(c>>(i*8)),0,hash+i*3);
                hash[5] = 0;
                break;
              }
            default:
              {
                uint_t c = Crc_32(0,md5,16);
                for ( i = 0; i < 4; ++i )
                  Str_Hex_Byte((byte_t)(c>>(i*8)),0,hash+i*3);
                break;
              }
          }
      
        S = Str_Join_3('/',co->basepath,hash,md5_hex);
      }
      
    if ( sfx )
      S = Str_Concat(S,sfx);

    return S;
  }
#endif
  ;
  
#define Xdata_Co_Fs_File_Path(Co,Key) Xdata_Co_Fs_File_Path_Sfx(Co,Key,0)
char *Xdata_Co_Fs_File_Path_Sfx(YOYO_XDATA_CO *co, char *key, char *sfx)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    char *S = 0;
    int i;

    if ( co->fs_depth < 0 )
      {
        int L = strlen(key);
        S = Str_Copy(key,L);
        for ( i = 0; i < L; ++i )
          {
            if ( S[i] == '/' )
              S[i] = '|';
            else if ( S[i] == '?' ) 
              S[i] = '&';
            else if ( S[i] == '*' ) 
              S[i] = '+';
          }
        S = Str_Join_2('/',co->basepath,S);
        if ( sfx )
          S = Str_Concat(S,sfx);
      }
    else
      {
        byte_t md5[16];
        Md5_Sign_Data(key,strlen(key),md5);
        S = Xdata_Co_Fs_File_Path_Sfx_Md5(co,md5,sfx);
      }
      
    return S;
  }
#endif
  ;
  
YOYO_BUFFER *Xdata_Co_Fs_Read_Id(YOYO_XDATA_CO *co, char *coid, int count)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_BUFFER *bf = 0;
    YOYO_FILE_STATS st = {0};
    File_Get_Stats(coid,&st,0);
        
    if ( st.f.exists )
      {
        void *foj = Cfile_Open_Raw(coid,"rb");
        if ( !foj )
          Raise_If_File_Error("open",coid);
        if ( count < 0 )
          bf = Cfile_Read_All(foj);
        else
          {
            bf = Buffer_Init(count);
            Cfile_Read(foj,bf->at,count,count);
          }
        Cfile_Close(foj);
      }
    
    return bf;
  }
#endif
  ;

void Xdata_Co_Fs_Write_Id(YOYO_XDATA_CO *co, char *coid, void *data, int count)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    void *foj = Cfile_Open(coid,"w+bP");
    Cfile_Write(foj,data,count,count);
    Cfile_Close(foj);
  }
#endif
  ;

YOYO_XDATA *Xdata_Co_Fs_Get(YOYO_XDATA_CO *co, char *key, YOYO_XDATA *dflt)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA *doc = dflt;
    
    __Auto_Ptr(doc)
      {
        char *coid;
        YOYO_BUFFER *bf;
        
        coid = Xdata_Co_Fs_File_Path(co,key);
        
        __Pfd_Lock(&co->jur_fd)
          bf = Xdata_Co_Fs_Read_Id(co,coid,-1);
        
        if ( bf )
          doc = Xdata_Co_Decode(co,bf->at,bf->count);
      }
    
    return doc;
  }
#endif
  ;
  
int Xdata_Co_Fs_Store(YOYO_XDATA_CO *co, YOYO_XDATA *doc, int strict_revision)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int revision = 0; 
    
    __Auto_Release
      {
        //byte_t md5[16];
        char *key;
        char *coid;
        
        key = Xnode_Value_Get_Str(&doc->root,"$key$",0);
        if ( !key )
          __Raise(YOYO_ERROR_ILLFORMED,"$key$ property doesn't present or has invalid value");
        
        //Md5_Sign_Data(key,strlen(key),md5);
        coid = Xdata_Co_Fs_File_Path(co,key);
        
        __Pfd_Lock(&co->jur_fd)
          {
            YOYO_BUFFER *bf = Xdata_Co_Fs_Read_Id(co,coid,8);
            if ( bf ) revision = Hex8_To_Unsigned(bf->at);
            
            if ( strict_revision )
              if ( revision && revision != Xdata_Get_Revision(doc) )
                __Raise(YOYO_ERROR_INCONSISTENT,
                  __Format("Inconsistent revision of document '%s', store:%d != docu:%d",
                           coid,
                           revision,
                           Xdata_Get_Revision(doc)));              
            
            ++revision;
            Xdata_Set_Revision(doc,revision);
            bf = Xdata_Co_Encode(co,doc);
            Xdata_Co_Fs_Write_Id(co,coid,bf->at,bf->count);
          }
      }
      
    return revision;
  }
#endif
  ;

YOYO_XDATA *Xdata_Co_Doc_Get(YOYO_XDATA_CO *co, char *key, YOYO_XDATA *dflt)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA *doc = 0;
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      doc = Xdata_Co_Fs_Get(co,key,dflt);
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    if ( !doc )
      {
        if (dflt == YOYO_XDATA_RAISE_DOESNT_EXIST )
          __Raise(YOYO_ERROR_DOESNT_EXIST,"document '%s' doesn't exist");
        else
          doc = dflt;
      }
      
    return dflt;
  }
#endif
  ;
  
int Xdata_Co_Doc_Store(YOYO_XDATA_CO *co, YOYO_XDATA *doc, int strict_revision)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int revision = 0;
    
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      revision = Xdata_Co_Fs_Store(co,doc,strict_revision);
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    return revision;
  }
#endif
  ;

int Xdata_Co_Doc_Update(YOYO_XDATA_CO *co, YOYO_XDATA *doc)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return Xdata_Co_Doc_Store(co, doc, 1);
  }
#endif
  ;

#define Xdata_Co_Doc_Unique(Co,Doc) Xdata_Co_Doc_Override(Co,Doc,0)
int Xdata_Co_Doc_Override(YOYO_XDATA_CO *co, YOYO_XDATA *doc, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( key )
      Xnode_Value_Set_Str(&doc->root,"$key$",key);
    else if ( !Xnode_Value_Get_Str(&doc->root,"$key$",0) )
      {
        char *k = Xdata_Co_Build_Unique_Key_Npl();
        Xnode_Value_Put_Str(&doc->root,"$key$",k);
      }
    return Xdata_Co_Doc_Store(co, doc, 0);
  }
#endif
  ;

void YOYO_XDATA_STREAM_Destruct(YOYO_XDATA_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    free(strm->key);
    __Unrefe(strm->co);
  }
#endif
  ;

void YOYO_XDATA_FS_STREAM_Destruct(YOYO_XDATA_FS_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_STREAM_Destruct(&strm->strm);
    if ( strm->tmp_path )
      {
        if ( File_Exists(strm->tmp_path) )
          File_Unlink(strm->tmp_path,0);
        free(strm->tmp_path);
      }
    if ( strm->fd >= 0 ) close(strm->fd);
    __Destruct(strm);
  }
#endif
  ;
  
void Xdata_Co_Strm_Close(YOYO_XDATA_STREAM *strm) _YOYO_XDATACO_BUILTIN_CODE( 
  { strm->Close(strm); });
void Xdata_Co_Strm_Cancel(YOYO_XDATA_STREAM *strm) _YOYO_XDATACO_BUILTIN_CODE( 
  { strm->Close(strm); });
char *Xdata_Co_Strm_Commit(YOYO_XDATA_STREAM *strm,char *key,int override) _YOYO_XDATACO_BUILTIN_CODE( 
  { return strm->Commit(strm,key,override); });
int Xdata_Co_Strm_Read(YOYO_XDATA_STREAM *strm,void *data, int count,int mincount) _YOYO_XDATACO_BUILTIN_CODE(
  { return strm->Read(strm,data,count,mincount); });
int Xdata_Co_Strm_Write(YOYO_XDATA_STREAM *strm,void *data, int count,int mincount) _YOYO_XDATACO_BUILTIN_CODE(
  { return strm->Write(strm,data,count,mincount); });
int Xdata_Co_Strm_Rewind(YOYO_XDATA_STREAM *strm) _YOYO_XDATACO_BUILTIN_CODE(
  { return strm->Rewind(strm); });
int Xdata_Co_Strm_Skip(YOYO_XDATA_STREAM *strm, int count) _YOYO_XDATACO_BUILTIN_CODE(
  { return strm->Rewind(strm,count); });
int Xdata_Co_Strm_Available(YOYO_XDATA_STREAM *strm) _YOYO_XDATACO_BUILTIN_CODE(
  { return strm->Available(strm); });
int Xdata_Co_Strm_Eof(YOYO_XDATA_STREAM *strm) _YOYO_XDATACO_BUILTIN_CODE(
  { return !strm->Available(strm); });

#define Xdata_Co_Strm_Write_Full(Strm,Data,Count) Xdata_Co_Strm_Write(Strm,Data,Count,Count)
#define Xdata_Co_Strm_Read_Full(Strm,Data,Count) Xdata_Co_Strm_Read(Strm,Data,Count,Count)
#define Xdata_Co_Strm_Commit_Unique(Strm) Xdata_Co_Strm_Commit(Strm,0,0)
#define Xdata_Co_Strm_Commit_Override(Strm,Key) Xdata_Co_Strm_Commit(Strm,Key,1)
#define Xdata_Co_Strm_Commit_New(Strm,Key) Xdata_Co_Strm_Commit(Strm,Key,0)

void Xdata_Co_Strm_Fs_Close(YOYO_XDATA_FS_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( strm->fd >= 0 ) 
      {
        close(strm->fd);
        strm->fd = -1;
      }
  }
#endif
  ;

char *Xdata_Co_Strm_Fs_Commit(YOYO_XDATA_FS_STREAM *strm, char *key, int override)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    __Auto_Ptr(key)
      {
        if ( key && strlen(key) > YOYO_XDATA_CO_MAX_FS_KEYLEN )
          __Raise_Format(YOYO_ERROR_ILLFORMED,
              ("key to long, max key len is %d symbols",YOYO_XDATA_CO_MAX_FS_KEYLEN));
        
        if ( strm->strm.key )
          __Raise(YOYO_ERROR_IO,"stream already commited");
          
        if ( strm->fd >= 0 )
          {
            int keylen; 
            char *coid;
            YOYO_XDATA_CO_FS_STRM_HEADER hdr = {0};

            uint_t now = Get_Curr_Date();
            Unsigned_To_Hex8(now,hdr.created);
            Unsigned_To_Hex8(now,hdr.lastacs);
            hdr.compressed = '.';
            hdr.cr = '\r';
            hdr.nl = '\n';
            hdr.nulterm = '!';
            Unsigned_To_Four(strm->strm.mimetype,hdr.mimetype);

            if ( !key )
              {
                override = 0;
                strm->strm.key = Xdata_Co_Build_Unique_Key_Npl();
              }
            else
              strm->strm.key = Str_Copy_Npl(key,-1);
            
            keylen = strlen(strm->strm.key);
            Unsigned_To_Hex8(strm->strm.length,hdr.length);
            Unsigned_To_Hex2(keylen,hdr.keylen);
            memset(hdr.key,'#',sizeof(hdr.key));
            memcpy(hdr.key,strm->strm.key,keylen);

            Write_Out_Raise(strm->fd,&hdr,sizeof(hdr));

            close(strm->fd);
            strm->fd = -1;
            strm->strm.finished = 1;
            
            coid = Xdata_Co_Fs_File_Path_Sfx(strm->strm.co,strm->strm.key,".strm");
            if ( File_Exists(coid) )
              {
                if ( override ) 
                  File_Unlink(coid,0);
                else
                  __Raise(YOYO_ERROR_IO,"stream conflicts with one exist");
              }
            Create_Required_Dirs(coid);
            File_Rename(strm->tmp_path,coid);
          }
        else
          __Raise(YOYO_ERROR_IO,"stream is not ready");
      }
      
    return strm->strm.key;
  }
#endif
  ;

int Xdata_Co_Strm_Fs_Read(YOYO_XDATA_FS_STREAM *strm,void *data, int count,int mincount)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int i;
    
    if ( !strm->strm.finished )
      __Raise(YOYO_ERROR_ACCESS_DENAIED,"writeonly stream!");
    if ( strm->fd < 0 )
      __Raise(YOYO_ERROR_IO,"stream alrady closed");
    if ( count > strm->strm.length - strm->curpos )
      count = strm->strm.length - strm->curpos;
    
    for ( i=0; i<count; )
      {
        int j = read(strm->fd,(char*)data+i,count);
        if ( j < 0 )
          {
            int err = errno;
            __Raise(YOYO_ERROR_IO,__Format("failed to read stream: %s",strerror(err)));
          }
        else if ( j )
          i+=j;
        else
          break;
      }
    
    strm->curpos += i;
    return i;
  }
#endif
  ;

int Xdata_Co_Strm_Fs_Write(YOYO_XDATA_FS_STREAM *strm,void *data, int count,int mincount)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int i;
    
    if ( strm->strm.finished )
      __Raise(YOYO_ERROR_ACCESS_DENAIED,"readonly stream!");
    if ( strm->fd < 0 )
      __Raise(YOYO_ERROR_IO,"stream alrady closed");
    
    for ( i=0; i<count; )
      {
        int j = write(strm->fd,(char*)data+i,count);
        if ( j < 0 )
          {
            int err = errno;
            __Raise(YOYO_ERROR_IO,__Format("failed to write stream: %s",strerror(err)));
          }
        else
          i+=j;
      }
    
    strm->strm.length += i;
    
    return i;
  }
#endif
  ;

void Xdata_Co_Strm_Fs_Rewind(YOYO_XDATA_FS_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( !strm->strm.finished )
      __Raise(YOYO_ERROR_ACCESS_DENAIED,"writeonly stream!");
    if ( strm->fd < 0 )
      __Raise(YOYO_ERROR_IO,"stream alrady closed");
    Lseek_Raise(strm->fd,0);
    strm->curpos = 0;
  }
#endif
  ;

void Xdata_Co_Strm_Fs_Skip(YOYO_XDATA_FS_STREAM *strm, int count)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( !strm->strm.finished )
      __Raise(YOYO_ERROR_ACCESS_DENAIED,"writeonly stream!");
    if ( strm->fd < 0 )
      __Raise(YOYO_ERROR_IO,"stream alrady closed");
    if ( count > strm->strm.length - strm->curpos )
      __Raise(YOYO_ERROR_IO,"skip out of stream");
    if ( count )
      Lseek_Raise(strm->fd,strm->curpos+count);
    strm->curpos += count;
  }
#endif
  ;

int Xdata_Co_Strm_Fs_Available(YOYO_XDATA_FS_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( !strm->strm.finished )
      __Raise(YOYO_ERROR_ACCESS_DENAIED,"writeonly stream!");
    if ( strm->fd < 0 )
      __Raise(YOYO_ERROR_IO,"stream alrady closed");
    return strm->strm.length - strm->curpos;
  }
#endif
  ;

int Xdata_Co_Strm_Mimetype(YOYO_XDATA_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return strm->mimetype;
  }
#endif
  ;

int Xdata_Co_Strm_Length(YOYO_XDATA_STREAM *strm)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( !strm->finished )
      __Raise(YOYO_ERROR_ACCESS_DENAIED,"writeonly stream!");
    return strm->length;
  }
#endif
  ;

YOYO_XDATA_FS_STREAM *YOYO_XDATA_FS_STREAM_Init(YOYO_XDATA_CO *co, char *key, int mimetype, int mknew)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    YOYO_XDATA_FS_STREAM_Destruct},
        {Oj_Close_OjMID,       Xdata_Co_Strm_Close},
        {Oj_Read_OjMID,        Xdata_Co_Strm_Read},
        {Oj_Write_OjMID,       Xdata_Co_Strm_Write},
        {Oj_Available_OjMID,   Xdata_Co_Strm_Available},
        {Oj_Eof_OjMID,         Xdata_Co_Strm_Eof},
        {Oj_Length_OjMID,      Xdata_Co_Strm_Length},
        {0}
      };
    YOYO_XDATA_FS_STREAM *self = __Object(sizeof(YOYO_XDATA_FS_STREAM),funcs);
    self->fd = -1;
    self->strm.Close = (void*)Xdata_Co_Strm_Fs_Close;
    self->strm.Commit = (void*)Xdata_Co_Strm_Fs_Commit;
    self->strm.Read = (void*)Xdata_Co_Strm_Fs_Read;
    self->strm.Write = (void*)Xdata_Co_Strm_Fs_Write;
    self->strm.Rewind = (void*)Xdata_Co_Strm_Fs_Rewind;
    self->strm.Skip = (void*)Xdata_Co_Strm_Fs_Skip;
    self->strm.Available = (void*)Xdata_Co_Strm_Fs_Available;
    self->strm.co = __Refe(co);

    if ( mknew )
      {
        if ( key )
          __Raise(YOYO_ERROR_INVALID_PARAM,"key can't be specified on stream creation");
        self->strm.mimetype = mimetype;
        self->tmp_path = __Retain(Xdata_Co_Fs_Tmp_File_Path_Sfx(co,".strm"));
        if ( mknew != - 1)
          {
            self->fd = Open_File(self->tmp_path,O_CREAT|O_WRONLY);
            if ( self->fd < 0 )
              {
                int err = errno;
                __Raise_Format(YOYO_ERROR_IO,
                      ("failed to create temprary file '%s': %s",self->tmp_path,strerror(err)));
              }
          }
      }
    else
      {
        char *coid;
        coid = Xdata_Co_Fs_File_Path_Sfx(co,key,".strm");

        self->strm.key = Str_Copy_Npl(key,-1);
        self->strm.finished = 1;
        self->fd = Open_File(coid,O_RDONLY);
        if ( self->fd < 0 )
          {
            int err = errno;
            __Raise_Format(YOYO_ERROR_DOESNT_EXIST,
                  ("failed to open stream object '%s': %s",coid,strerror(err)));
          }
        __Gogo
          {
            int keylen;
            YOYO_XDATA_CO_FS_STRM_HEADER hdr = {0};
            Lseek_Raise(self->fd,-sizeof(hdr));
            Read_Into_Raise(self->fd,&hdr,sizeof(hdr));
            Lseek_Raise(self->fd,0);
            self->strm.mimetype = Four_To_Unsigned(hdr.mimetype);
            self->strm.length = Hex8_To_Unsigned(hdr.length);
            keylen = Hex2_To_Unsigned(hdr.keylen);
            if ( keylen < sizeof(hdr.key) )
              hdr.key[keylen] = 0;
            hdr.nulterm = 0;
            if ( 0 != strcmp(self->strm.key,hdr.key) )
              __Raise_Format(YOYO_ERROR_CORRUPTED,
                  ("failed to open stream '%s': specified key does not match",key));
          }
      }
    return self;
  }
#endif
  ;
  
#define Xdata_Co_Move_To_Unique_Strm(Co,Mime,Path) Xdata_Co_Move_To_Strm(Co,Mime,Path,0)
char *Xdata_Co_Move_To_Strm(YOYO_XDATA_CO *co,int mime, char *path, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    char *r_key = 0;
    
    __Auto_Ptr(r_key)
      if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
        {
          YOYO_XDATA_FS_STREAM *strm = YOYO_XDATA_FS_STREAM_Init(co,0,mime,-1);
          File_Move(path,strm->tmp_path);
          strm->strm.length = File_Length(strm->tmp_path);
          strm->fd = Open_File(strm->tmp_path,O_WRONLY);
          Lseek_Raise(strm->fd,strm->strm.length);
          if ( strm->fd < 0 )
            {
              int err = errno;
              __Raise_Format(YOYO_ERROR_IO,
                    ("failed to open temprary file '%s': %s",strm->tmp_path,strerror(err)));
            }
          r_key = Str_Copy(Xdata_Co_Strm_Fs_Commit(strm,key,key?1:0),-1);
        }
      else
        __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    return r_key;
  }
#endif
  ;
  
YOYO_XDATA_STREAM *Xdata_Co_Strm_Open(YOYO_XDATA_CO *co, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_STREAM *strm = 0;
    
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      strm = &YOYO_XDATA_FS_STREAM_Init(co,key,0,0)->strm;
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    return strm;
  }
#endif
  ;

YOYO_XDATA_STREAM *Xdata_Co_Strm_Create(YOYO_XDATA_CO *co, int mimetype)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_STREAM *strm = 0;
    
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      strm = &YOYO_XDATA_FS_STREAM_Init(co,0,mimetype,1)->strm;
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    return strm;
  }
#endif
  ;

void Xdata_Co_Fs_Seq_Close(YOYO_XDATA_FS_SEQ *seq)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( seq->jur_fd >= 0 ) close(seq->jur_fd);
    seq->jur_fd = -1;
  }
#endif
  ;

void Xdata_Co_Fs_Seq_Add(YOYO_XDATA_FS_SEQ *seq, YOYO_XDATA *doc)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_FS_SEQ_RECO reco = {0};
    
    if ( seq->jur_fd < 0 )
      __Raise(YOYO_ERROR_IO,"sequense is closed");

    __Gogo
      {
        char *key = Xnode_Value_Get_Str(&doc->root,"$key$",0);
        if ( !key )
          __Raise(YOYO_ERROR_ILLFORMED,"$key$ property doesn't present or has invalid value");
        Md5_Sign_Data(key,strlen(key),reco.md5);
      }

    __Pfd_Lock(&seq->jur_fd)
      {
        int pg_fd = -1;
        YOYO_XDATA_SEQ_JUR jur = {0};
        
        Lseek_Raise(seq->jur_fd,0);
        Read_Into_Raise(seq->jur_fd,&jur,sizeof(jur));
        
        __Pfd_Guard(&pg_fd)
          {
            int new_pg, recno;
            char pgno[32] = {0};
            Quad_To_Hex16(jur.last_page,pgno);
            
            if ( YOYO_XDATA_FS_SEQ_RECO_COUNT > jur.reco_next )
              {
                new_pg = 0;
                recno  = jur.reco_next++;
              }
            else
              {
                new_pg = 1;
                ++jur.last_page;
                jur.reco_next = 1;
                recno = 0;
              }
            
            jur.datetime = Get_Curr_Datetime();
            
            pg_fd = Open_File_Raise(Str_Join_2('/',seq->path,pgno),O_RDWR|(new_pg?O_CREAT:0));
            Lseek_Raise(pg_fd,sizeof(reco)*recno);
            Write_Out_Raise(pg_fd,&reco,sizeof(reco));
          }
        
        Lseek_Raise(seq->jur_fd,0);
        Write_Out_Raise(seq->jur_fd,&jur,sizeof(jur));
      }
  }
#endif
  ;

int Xdata_Co_Fs_Seq_Next_(YOYO_XDATA_FS_SEQ *seq, YOYO_XDATA **arr, int count)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int arr_i;
    
    if ( seq->jur_fd < 0 )
      __Raise(YOYO_ERROR_IO,"sequense is closed");
    
    __Pfd_Lock(&seq->jur_fd)
      {
        int pg_fd = -1;
        YOYO_XDATA_SEQ_JUR jur = {0};
        
        Lseek_Raise(seq->jur_fd,0);
        Read_Into_Raise(seq->jur_fd,&jur,sizeof(jur));

        for ( arr_i = 0; arr_i < count; ++arr_i )
          {
            
            if ( seq->recno >= YOYO_XDATA_FS_SEQ_RECO_COUNT )
              {
                ++seq->page;
                seq->recno = 0;
              }

            if ( seq->page < jur.first_page ) 
              {
                seq->page = jur.first_page;
                seq->recno = jur.first_recno;
              }
            else if ( seq->recno < jur.first_recno )
              {
                seq->recno = jur.first_recno;
              }
        
            if ( seq->page > jur.last_page || ( seq->page == jur.last_page && seq->recno >= jur.reco_next ) )
              break;
            else
              {
                YOYO_BUFFER *bf = 0;
                YOYO_XDATA *doc = 0;
                char *coid = 0;
                YOYO_XDATA_FS_SEQ_RECO reco = {0};
                char pgno[32] = {0};
                Quad_To_Hex16(seq->page,pgno);
           
                __Pfd_Guard(&pg_fd)
                  {
                    pg_fd = Open_File_Raise(Str_Join_2('/',seq->path,pgno),O_RDONLY);
                    Lseek_Raise(pg_fd,sizeof(reco)*seq->recno);
                    Read_Into_Raise(pg_fd,&reco,sizeof(reco));
                    ++seq->recno;
                  }
                
                __Auto_Ptr(doc)
                  {
                    coid = Xdata_Co_Fs_File_Path_Sfx_Md5(seq->seq.co, reco.md5, 0);
                    __Pfd_Lock(&seq->seq.co->jur_fd)
                      bf = Xdata_Co_Fs_Read_Id(seq->seq.co,coid,-1);
      
                    if ( bf )
                      doc = Xdata_Co_Decode(seq->seq.co,bf->at,bf->count);
                  }
                  
                if ( doc )
                  arr[arr_i++] = doc;
              }
          }
      }

    return  arr_i;
  }
#endif
  ;

YOYO_XDATA *Xdata_Co_Fs_Seq_Next(YOYO_XDATA_FS_SEQ *seq)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA *doc;
    if ( Xdata_Co_Fs_Seq_Next_(seq,&doc,1) )
      return doc;
    return 0;
  }
#endif
  ;

YOYO_ARRAY *Xdata_Co_Fs_Seq_Multi_Next(YOYO_XDATA_FS_SEQ *seq, int count)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_ARRAY *arr = 0;
    __Auto_Ptr(arr)
      {
        YOYO_XDATA **docs = __Malloc(count*sizeof(void*));
        count = Xdata_Co_Fs_Seq_Next_(seq,docs,count);
        arr = Array_Refs_Copy(docs,count);
      }
    return arr;
  }
#endif
  ;

void Xdata_Co_Fs_Seq_Erase(YOYO_XDATA_FS_SEQ *seq)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( seq->jur_fd < 0 )
      __Raise(YOYO_ERROR_IO,"sequense is closed");
    
    __Pfd_Lock(&seq->jur_fd)
      {
        YOYO_XDATA_SEQ_JUR jur = {0};
        quad_t last_first_pg = jur.first_page;
        
        Lseek_Raise(seq->jur_fd,0);
        Read_Into_Raise(seq->jur_fd,&jur,sizeof(jur));

        if ( jur.first_page < seq->page )
          jur.first_page = seq->page;
        if ( seq->page == jur.first_page )
          jur.first_recno = seq->recno;

        Lseek_Raise(seq->jur_fd,0);
        Write_Out_Raise(seq->jur_fd,&jur,sizeof(jur));
      
        __Auto_Release while ( last_first_pg < jur.first_page )
          {
            char *S;
            char pgno[32] = {0};
            Quad_To_Hex16(seq->page,pgno);
            S = Str_Join_2('/',seq->path,pgno);
            if ( File_Exists(S) ) File_Unlink(S,0);
            ++last_first_pg;
          }
      }
  }
#endif
  ;
  
void Xdata_Co_Seq_Close(YOYO_XDATA_SEQ *seq) _YOYO_XDATACO_BUILTIN_CODE( 
  { seq->Close(seq); });
void Xdata_Co_Seq_Add(YOYO_XDATA_SEQ *seq,YOYO_XDATA *doc) _YOYO_XDATACO_BUILTIN_CODE( 
  { seq->Add(seq,doc); });
YOYO_XDATA *Xdata_Co_Seq_Next(YOYO_XDATA_SEQ *seq) _YOYO_XDATACO_BUILTIN_CODE( 
  { return seq->Next(seq); });
YOYO_ARRAY *Xdata_Co_Seq_Multi_Next(YOYO_XDATA_SEQ *seq, int count) _YOYO_XDATACO_BUILTIN_CODE( 
  { return seq->Multi_Next(seq,count); });
void Xdata_Co_Seq_Erase(YOYO_XDATA_SEQ *seq) _YOYO_XDATACO_BUILTIN_CODE( 
  { seq->Erase(seq); });
  
void YOYO_XDATA_FS_SEQ_Destroy(YOYO_XDATA_FS_SEQ *seq)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    __Unrefe(seq->seq.co);
    if ( seq->jur_fd >=0 ) close(seq->jur_fd);
    free( seq->path );
    __Destruct(seq);
  }
#endif
  ;
  
YOYO_XDATA_FS_SEQ *YOYO_XDATA_FS_SEQ_Init(YOYO_XDATA_CO *co, char *key, int mknew)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_FS_SEQ *seq;
    char *coid;
    char *coid_jur;
    
    seq = __Object_Dtor(sizeof(YOYO_XDATA_FS_SEQ),YOYO_XDATA_FS_SEQ_Destroy);
    seq->seq.co = __Refe(co);
    seq->seq.Close = (void*)Xdata_Co_Fs_Seq_Close;
    seq->seq.Add = (void*)Xdata_Co_Fs_Seq_Add;
    seq->seq.Next = (void*)Xdata_Co_Fs_Seq_Next;
    seq->seq.Multi_Next = (void*)Xdata_Co_Fs_Seq_Multi_Next;
    seq->seq.Erase = (void*)Xdata_Co_Fs_Seq_Erase;
    
    coid = Xdata_Co_Fs_File_Path_Sfx(co,key,".seq");
    coid_jur = Str_Join_2('/',coid,".jur");
    
    if ( mknew )
      {
        int pg_fd = -1;
        YOYO_XDATA_SEQ_JUR jur = {0};
        __Pfd_Lock(&co->jur_fd)
          {
            if ( File_Exists(coid_jur) )
              __Raise_Format(YOYO_ERROR_ALREADY_EXISTS,("sequence '%s' does not exist",coid_jur));
            Create_Directory_In_Depth(coid);
            memcpy(jur.version,YOYO_XDATA_SEQ_JUR_VERSION,8);
            jur.datetime = Get_Curr_Datetime();
            __Pfd_Guard(&pg_fd)
              pg_fd = Open_File_Raise(Str_Join_2('/',coid,"0000000000000000"),O_RDWR|O_CREAT);
            seq->jur_fd = Open_File_Raise(coid_jur,O_RDWR|O_CREAT);
            Write_Out_Raise(seq->jur_fd,&jur,sizeof(jur));
          }
      }
    else
      {
        __Pfd_Lock(&co->jur_fd)
          {
            if ( !File_Exists(coid_jur) )
              __Raise_Format(YOYO_ERROR_DOESNT_EXIST,("sequence '%s' does not exist",coid_jur));
            seq->jur_fd = Open_File_Raise(coid_jur,O_RDWR);
          }
      }
    
    seq->path = __Retain(coid);
    return seq;
  }
#endif
  ;
  
YOYO_XDATA_SEQ *Xdata_Co_Seq_Create(YOYO_XDATA_CO *co, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_SEQ *seq = 0;
    
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      seq = &YOYO_XDATA_FS_SEQ_Init(co,key,1)->seq;
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    return seq;
  }
#endif
  ;
  
YOYO_XDATA_SEQ *Xdata_Co_Seq_Open(YOYO_XDATA_CO *co, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA_SEQ *seq = 0;
    
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      seq = &YOYO_XDATA_FS_SEQ_Init(co,key,0)->seq;
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
    
    return seq;
  }
#endif
  ;
  
void Xdata_Co_Seq_Delete(YOYO_XDATA_CO *co, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
  }
#endif
  ;


#endif /* C_once_019A9F9B_7D69_46F7_89D9_2C330BDFA526 */

