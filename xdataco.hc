
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

enum
  {
    YOYO_XDATA_CO_DOC_TEXT   = 'A',
    YOYO_XDATA_CO_DOC_BINARY = 'B',
    YOYO_XDATA_CO_DOC_ZIPPED = 'Z',
    YOYO_XDATA_CO_MEDIA_FS   = 'FS',
    YOYO_XDATA_CO_MEDIA_TbDB = 'TbDB',
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
  
void YOYO_XDATA_CO_Destruct(YOYO_XDATA_CO *co)
  {
    free(co->basepath);
    if (co->jur_fd >= 0) close(co->jur_fd);
    __Unrefe(co->cf);
    __Destruct(co);
  }
  
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
    Xnode_Value_Get_Int((YOYO_XNODE*)doc,"$rev$",0);
  }
#endif
  ;
  
int Xdata_Set_Revision(YOYO_XDATA *doc, int rev)
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
  {
    if ( S )
      {
        if ( !strcmp(S,"fs") ) return YOYO_XDATA_CO_MEDIA_FS;
        if ( !strcmp(S,"tbdb") ) return YOYO_XDATA_CO_MEDIA_TbDB;
      }
    __Raise(YOYO_ERROR_ILLFORMED,"invalid media type, should be 'fs' or 'tbdb'");
    return 0; /* fake */
  }

int Xdata_Co_Parse_Format(char *S)
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

char YOYO_XDATA_CO_DEFAULT_CF[] 
#ifdef _YOYO_XDATACO_BUILTIN 
= "depth = 2\n"
  "media = fs\n" /*tbdb is not implemented yet*/
  "format = zipped\n"
#endif
  ;

char YOYO_XDATA_CO_DEVELOPER_CF[]
#ifdef _YOYO_XDATACO_BUILTIN 
= "depth = 0\n"
  "media = fs\n"
  "format = text\n"
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

char *Xdata_Co_Fs_File_Path(YOYO_XDATA_CO *co, byte_t *md5)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    int i;
    char md5_hex[33] = {0};
    char *S = 0;
    char hash[4*3] = "\0\0/\0\0/\0\0/\0\0";

    for ( i = 0; i < 16; ++i )
      Str_Hex_Byte(md5[i],0,md5_hex+i*2);

    if ( !co->fs_depth )
      S = Str_Join_2('/',co->basepath,md5_hex);
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
        byte_t md5[16];
        char *coid;
        YOYO_BUFFER *bf;
        
        Md5_Sign_Data(key,strlen(key),md5);
        coid = Xdata_Co_Fs_File_Path(co,md5);
        
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
        byte_t md5[16];
        char *key;
        char *coid;
        
        key = Xnode_Value_Get_Str(&doc->root,"$key$",0);
        if ( !key )
          __Raise(YOYO_ERROR_ILLFORMED,"$key$ property doesn't present or has invalid value");
        
        Md5_Sign_Data(key,strlen(key),md5);
        coid = Xdata_Co_Fs_File_Path(co,md5);
        
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

YOYO_XDATA *Xdata_Co_Get(YOYO_XDATA_CO *co, char *key, YOYO_XDATA *dflt)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    YOYO_XDATA *doc = 0;
    if ( co->media_type == YOYO_XDATA_CO_MEDIA_FS )
      doc = Xdata_Co_Fs_Get(co,key,dflt);
    else
      __Raise(YOYO_ERROR_INCONSISTENT,"unsupported media type");
  
    if ( !doc )
      if (dflt == YOYO_XDATA_RAISE_DOESNT_EXIST )
        __Raise(YOYO_ERROR_DOESNT_EXIST,"document '%s' doesn't exist");
      else
        doc = dflt;
    
    return dflt;
  }
#endif
  ;
  
int Xdata_Co_Store(YOYO_XDATA_CO *co, YOYO_XDATA *doc, int strict_revision)
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

int Xdata_Co_Update(YOYO_XDATA_CO *co, YOYO_XDATA *doc)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    return Xdata_Co_Store(co, doc, 1);
  }
#endif
  ;

enum 
  {
    YOYO_XDATA_CO_UUID_LENGTH = 9,
  };

char *Xdata_Co_Build_Unique_Key_Npl()
  {
    int pid = getpid();
    uint_t tmx = (uint_t)time(0);
    
    byte_t uuid[YOYO_XDATA_CO_UUID_LENGTH] = {0,0,0,0,0,0,0,0}; /* 8 bytes garanty */
    char   out[(YOYO_XDATA_CO_UUID_LENGTH*8+5)/6 + 3 ] = {'#','@',0};
    
    Unsigned_To_Two(pid,uuid);
    Unsigned_To_Four(tmx,uuid+2);
    System_Random(uuid+6,sizeof(uuid)-6);
    Str_Xbit_Encode(uuid,sizeof(uuid)*8,6,Str_6bit_Encoding_Table,out+2);
    
    STRICT_REQUIRE( out[sizeof(out)-1] == 0 );
    
    return __Memcopy_Npl(out,sizeof(out));
  }

int Xdata_Co_Override(YOYO_XDATA_CO *co, YOYO_XDATA *doc, char *key)
#ifdef _YOYO_XDATACO_BUILTIN 
  {
    if ( key )
      Xnode_Value_Set_Str(&doc->root,"$key$",key);
    else if ( !Xnode_Value_Get_Str(&doc->root,"$key$",0) )
      {
        char *k = Xdata_Co_Build_Unique_Key_Npl();
        Xnode_Value_Put_Str(&doc->root,"$key$",k);
      }
    return Xdata_Co_Store(co, doc, 0);
  }
#endif
  ;

#endif /* C_once_019A9F9B_7D69_46F7_89D9_2C330BDFA526 */

