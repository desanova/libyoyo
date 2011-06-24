
#include <libyoyo.hc>
#include <stdio.h>

int func(YOYO_CGIR *cgir)
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
  }

int main()
  {
    char *S;
    YOYO_CGIR *cgir = Cgir_Init();
    
    Cgir_Query_Params(cgir,"/tmp/cgi-uload",100*KILOBYTE);
    
    Cgir_Set_Secure_Cookie(cgir,"test-qookie","abra-kadabra",0);
    Cgir_Set_Cookie(cgir,"time-mark","TIMED",time(0)+3);
    Cgir_Set_Cookie(cgir,"qookie","ugu",0);
    
    func(cgir);
    
    puts(S=Cgir_Format_Cookies_Out(cgir));
    Cgir_Puts(cgir,"<hr><pre>");
    Cgir_Puts(cgir,S);
    
    printf("Content-Type: text/html; charset=utf-8\n");
    printf("Content-Length: %d\n\n",Cgir_Get_Len(cgir));
    puts(Cgir_Get_Cstr(cgir));
    
    return 0;
  }
