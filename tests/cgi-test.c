
#include <libyoyo.hc>

#define Stdout_Put(S) fputs(S,stdout)

enum
  {
    YOYO_CGIR_OUT_TEXTHTML = 0,
    YOYO_CGIR_OUT_REDIRECT,
    YOYO_CGIR_OUT_DATASTREAM,
  };

void Cgir_Write_Out(YOYO_CGIR *cgir, int out_status)
  {
    if ( out_status == YOYO_CGIR_OUT_TEXTHTML )
      {
        Stdout_Put("Content-Type: text/html; charset=utf-8\r\n");
        printf("Content-Length: %d\r\n\r\n",Cgir_Get_Len(cgir));
        Stdout_Put(cgir->out->at);
      }
    else if ( out_status == YOYO_CGIR_OUT_REDIRECT )
      {
        Stdout_Put("Location: ");
        Stdout_Put(cgir->out->at);
        Stdout_Put("\r\n\r\n");
      }
    else if ( out_status == YOYO_CGIR_OUT_DATASTREAM )
      {
        char bf[YOYO_FILE_COPY_BUFFER_SIZE];
        int count = 0;
        void *src = cgir->dstrm;
        int (*xread)(void*,void*,int,int) = Yo_Find_Method_Of(&src,Oj_Read_OjMID,YO_RAISE_ERROR);
        int len = Oj_Available(cgir->dstrm);
        Stdout_Put("Content-Type: ");
        Stdout_Put(cgir->dstrm_mimetype);
        Stdout_Put("\r\n");
        printf("Content-Length: %d\r\n\r\n",len);
        for ( ;; )
          {
            int i = xread(src,bf,YOYO_FILE_COPY_BUFFER_SIZE,0);
            if ( !i ) break;
            fwrite(bf,1,i,stdout);
            count += i;
          }
      }
    else /* empty page */
      {
        Stdout_Put("Content-Type: text/html; charset=utf-8\n");
        Stdout_Put("Content-Length: 0\n\n");
      }
    fflush(stdout);
  }

int func(YOYO_CGIR *cgir)
  {
    if ( !strncmp(cgir->request_uri,"/static/",8) )
      {
        char **p = environ, *key = cgir->request_uri+8;
        YOYO_XDATA_CO *co;
        YOYO_XDATA_STREAM *strm;
        __Try
          co = Xdata_Co_Open("tstdb");
        __Catch(YOYO_ERROR_DOESNT_EXIST)
          co = Xdata_Co_Create("tstdb",YOYO_XDATA_CO_DEVELOPER_CF);
        __Try_Except
          {
            strm = Xdata_Co_Strm_Open(co,key);
            cgir->dstrm = __Refe(strm);
            cgir->dstrm_mimetype = Mime_String_Of_Npl(Xdata_Co_Strm_Mimetype(strm));
          }
        __Except
          {
            Cgir_Puts(cgir,__Format_Error());
            Cgir_Puts(cgir,"<pre>");
            Cgir_Format_Bf(cgir,Cgir_Get_Outbuf(cgir));
            for ( ; *p; ++p )
              Cgir_Puts(cgir,*p);
            Cgir_Puts(cgir,"</pre>");
            return YOYO_CGIR_OUT_TEXTHTML;
          }
        return YOYO_CGIR_OUT_DATASTREAM;
      }
    else
      {
        char **p = environ;
        Cgir_Puts(cgir,"<form method=GET><input type=text name=\"USER@Robin.ADDR.Street\" value=\"Avda. Libertad\" /><input type=submit value=\"Go\" /></form>");
        Cgir_Puts(cgir,"<form method=POST><input type=text name=\"value-post\" value=\"post-method\" /><input type=submit value=\"Go\" /></form>");
        Cgir_Puts(cgir,"<form method=POST enctype=\"multipart/form-data\"><input type=file name=\"file\" /><input type=text name=\"value-post\" value=\"post-method\" /><input type=submit value=\"Go\" /></form>");
        Cgir_Puts(cgir,"<pre>");
        Cgir_Format_Bf(cgir,Cgir_Get_Outbuf(cgir));
        for ( ; *p; ++p )
          Cgir_Puts(cgir,*p);
        Cgir_Puts(cgir,"</pre>");
        Cgir_Set_Secure_Cookie(cgir,"test-qookie","abra-kadabra",0);
        Cgir_Set_Cookie(cgir,"time-mark","TIMED",time(0)+3);
        Cgir_Set_Cookie(cgir,"qookie","ugu",0);
    
        char *up_mimetype = Cgir_Mime_Of_Upload(cgir,"file");
        if (up_mimetype)
          {
            YOYO_XDATA_CO *co;
            YOYO_XDATA_STREAM *strm;
            YOYO_XDATA *doc;
            void *upfile;
            char *strm_key;
        
            __Try
              co = Xdata_Co_Open("tstdb");
            __Catch(YOYO_ERROR_DOESNT_EXIST)
              co = Xdata_Co_Create("tstdb",YOYO_XDATA_CO_DEVELOPER_CF);
        
            /*
            strm = Xdata_Co_Strm_Create(co,Mime_Code_Of(up_mimetype));
            upfile = Cgir_Open_Upload(cgir,"file");
            Oj_Copy_File(upfile,strm);
            strm_key = Xdata_Co_Strm_Commit_Unique(strm);
            Oj_Close(upfile);
            */
        
            strm_key = Xdata_Co_Move_To_Unique_Strm(co,Mime_Code_Of(up_mimetype),Cgir_Get_Upload_Path(cgir,"file"));
        
            doc = Xdata_Init();
            Xnode_Value_Set_Str(&doc->root,"strm",strm_key);
            Xnode_Value_Set_Str(&doc->root,"status","uploaded");
            Xdata_Co_Doc_Override(co,doc,strm_key);
        
            Def_Format_Into(Cgir_Get_Outbuf(cgir),&doc->root,0);
          }
        return YOYO_CGIR_OUT_TEXTHTML;
      }
  }

int main()
  {
    //char *S;
    YOYO_CGIR *cgir = Cgir_Init();
    YOYO_BUFFER *extra = Buffer_Init(0);
    int status;
    
    __Try_Except
      {
        Cgir_Query_Params(cgir,"/tmp/cgi-upload",100*KILOBYTE);
        __Auto_Release status = func(cgir);
        Cgir_Write_Out(cgir,status);
      }
    __Except
      puts(__Format_Error());
    fflush(stdout);
/*    
    Stdout_Put(S=Cgir_Format_Cookies_Out(cgir));
    Cgir_Puts(cgir,"<hr><pre>");
    Cgir_Puts(cgir,S);
    Cgir_Puts(cgir,"<hr><pre>");
    
    printf("Content-Type: text/html; charset=utf-8\n");
    printf("Content-Length: %d\n\n",Cgir_Get_Len(cgir)+extra->count);
    Stdout_Put(Cgir_Get_Cstr(cgir));
    
    Buffer_Stdf_Write_Whole(extra,stdout);
*/  
    __Release(cgir);
    __Release(extra);
    
    return 0;
  }

