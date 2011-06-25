
#include <libyoyo.hc>

char *Cgir_Generate_Boundary()
  {
    return "--------1234567890";
  }

int Cgir_Get_Attachment_Len(YOYO_CGIR *cgir)
  {
    return 100;
  }
  
char *Cgir_Get_Attachment_Mimetype(YOYO_CGIR *cgir)
  {
    return "text/plain";
  }

char *Cgir_Atachment_Filename(YOYO_CGIR *cgir)
  {
    return "filename.attachment.txt";
  }

#define Stdout_Put(S) fputs(S,stdout)

void Cgir_Write_Attachment_Out(YOYO_CGIR *cgir)
  {
    int i = 0;
    for ( i = 0; i < 100; ++i )
      if ( i && !(i % 80) )
        Stdout_Put("\n");
      else
        Stdout_Put(".");
  }

enum
  {
    YOYO_CGIR_OUT_TEXTHTML = 0,
    YOYO_CGIR_OUT_TEXTHTML_MULTIPART,
    YOYO_CGIR_OUT_REDIRECT,
    YOYO_CGIR_OUT_REDIRECT_PERMANENT,
    YOYO_CGIR_OUT_BINARYSTREAM,
  };

void Cgir_Write_Out(YOYO_CGIR *cgir, int out_status)
  {
    if ( out_status == YOYO_CGIR_OUT_TEXTHTML )
      {
        Stdout_Put("Content-Type: text/html; charset=utf-8\r\n");
        printf("Content-Length: %d\r\n\r\n",Cgir_Get_Len(cgir));
        Stdout_Put(Cgir_Get_Cstr(cgir));
      }
    else if ( out_status == YOYO_CGIR_OUT_TEXTHTML_MULTIPART )
      {
        char *boundary = Cgir_Generate_Boundary();
        int b_len = strlen(boundary);
        //printf("Content-Type: multipart; charset=utf-8; boundary=%s\r\n",boundary+2);
        printf("Content-Type: multipart/mixed; boundary=%s\r\n",boundary+2);
        printf("Content-Length: %d\r\n\r\n",Cgir_Get_Len(cgir)+Cgir_Get_Attachment_Len(cgir)+b_len*3+2*3+100);
        Stdout_Put(boundary);
        //Stdout_Put("\r\nContent-Disposition: inline");
        Stdout_Put("\r\nContent-Type: text/html\r\n\r\n");
        Stdout_Put(Cgir_Get_Cstr(cgir));
        Stdout_Put("\r\n\r\n");
        Stdout_Put(boundary);
        Stdout_Put("\nContent-Disposition: attachment; filename=\"");
        Stdout_Put(Cgir_Atachment_Filename(cgir));
        Stdout_Put("\"\r\nContent-Type: ");
        Stdout_Put(Cgir_Get_Attachment_Mimetype(cgir));
        Stdout_Put("\r\n\r\n");
        fflush(stdout);
        Cgir_Write_Attachment_Out(cgir);
        Stdout_Put("\r\n");
        Stdout_Put(boundary);
        Stdout_Put("--");
      }
    else if ( out_status == YOYO_CGIR_OUT_REDIRECT )
      {
        Stdout_Put("Location: ");
        Stdout_Put(Cgir_Get_Cstr(cgir));
        Stdout_Put("\r\n\r\n");
      }
    else if ( out_status == YOYO_CGIR_OUT_REDIRECT_PERMANENT )
      {
        Stdout_Put("Location: ");
        Stdout_Put(Cgir_Get_Cstr(cgir));
        Stdout_Put("\r\n\r\n");
      }
    else if ( out_status == YOYO_CGIR_OUT_BINARYSTREAM )
      {
      }
    else /* empty page */
      {
        Stdout_Put("Content-Type: text/html; charset=utf-8\n");
        Stdout_Put("Content-Length: 0\n\n");
      }
    fflush(stdout);
  }

void func(YOYO_CGIR *cgir)
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
  }

int main()
  {
    //char *S;
    YOYO_CGIR *cgir = Cgir_Init();
    YOYO_BUFFER *extra = Buffer_Init(0);
    
    Cgir_Query_Params(cgir,"/tmp/cgi-uload",100*KILOBYTE);
    func(cgir);
    Cgir_Write_Out(cgir,YOYO_CGIR_OUT_TEXTHTML_MULTIPART);
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

