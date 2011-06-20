
#include <libyoyo.hc>
#include <stdio.h>

extern char **environ;

typedef struct _YOYO_CGIR
  {
    YOYO_XDATA *params;
    char *server_software;
    char *server_name;
    char *request_uri;
    char *remote_addr;
    char *referer;
    char *query_string;
    char *path_info;
    char *content_boundary; /* can be null */
    int gateway_interface;
    int server_protocol;
    int server_port;
    int request_method;
    int content_length;
    int content_type;
  } YOYO_CGIR;

enum 
  {
    YOYO_CGIR_BAD_METHOD = 0,
    YOYO_CGIR_GET   = 1,
    YOYO_CGIR_POST  = 2,
  };

enum
  {
    YOYO_CGIR_HTTP_X_X     = 300000,
    YOYO_CGIR_HTTP_1_0     = 300100,
    YOYO_CGIR_HTTP_1_1     = 300101,
  };

enum
  {
    YOYO_CGIR_CGI_GW       = 100000,
    YOYO_CGIR_CGI_X_X      = 100000,
    YOYO_CGIR_CGI_1_0      = 100100,
    YOYO_CGIR_CGI_1_1      = 100101,
    YOYO_CGIR_FAST_CGI_GW  = 200000,
    YOYO_CGIR_FAST_CGI_X_X = 200000,
    YOYO_CGIR_FAST_CGI_1_0 = 200100,
    YOYO_CGIR_FAST_CGI_1_1 = 200101,
  };

enum
  {
    YOYO_CGIR_NO_CONTENT  = 0,
    YOYO_CGIR_URLENCODED  = 1,
    YOYO_CGIR_OCTETSTREAM = 2,
    YOYO_CGIR_MULTIPART   = 3,
  };

int Cgir_Recognize_Request_Method(char *method)
  {
    if ( method )
      {
        if ( !strcmp_I(method,"get") )
          return YOYO_CGIR_GET;
        if ( !strcmp_I(method,"post") )
          return YOYO_CGIR_POST;
      }
    return 0;
  } 
   
int Cgir_Recognize_Content_Type(char *cont_type)
  {
    if ( cont_type )
      {
        if ( !strncmp_I(cont_type,"multipart/form-data;",20) )
          return YOYO_CGIR_MULTIPART;
        if ( !strcmp_I(cont_type,"application/x-www-form-urlencoded") )
          return YOYO_CGIR_URLENCODED;
        if ( !strcmp_I(cont_type,"application/octet-stream") )
          return YOYO_CGIR_OCTETSTREAM;
      }
    return 0;
  }
  
int Cgir_Recognize_Gateway_Ifs(char *gwifs)
  {
    if ( gwifs )
      {
        if ( !strncmp_I(gwifs,"cgi/1.1",9) )
          return YOYO_CGIR_CGI_1_1;
        if ( !strncmp_I(gwifs,"cgi/1.0",9) )
          return YOYO_CGIR_CGI_1_0;
      }
    return YOYO_CGIR_CGI_X_X;
  }
  
int Cgir_Recognize_Protocol(char *proto)
  {
    if ( proto )
      {
        if ( !strncmp_I(proto,"http/1.1",10) )
          return YOYO_CGIR_HTTP_1_1;
        if ( !strncmp_I(proto,"http/1.0",10) )
          return YOYO_CGIR_HTTP_1_0;
      }
    return 0;
  }

void Cgir_Destruct(YOYO_CGIR *self)
  {
    free(self->server_software);
    free(self->server_name);
    free(self->request_uri);
    free(self->remote_addr);
    free(self->referer);
    free(self->query_string);
    free(self->path_info);
    free(self->content_boundary);
    __Unrefe(self->params);
    __Destruct(self);
  }

YOYO_CGIR *Cgir_Init()
  {
    YOYO_CGIR *self = __Object_Dtor(sizeof(YOYO_CGIR),Cgir_Destruct);

    self->server_software = Str_Copy_Npl(getenv("SERVER_SOFTWARE"),-1);
    self->gateway_interface = Cgir_Recognize_Gateway_Ifs(getenv("GATEWAY_INTERFACE"));
    self->server_protocol = Cgir_Recognize_Protocol(getenv("SERVER_PROTOCOL"));

    self->server_name = Str_Copy_Npl(getenv("SERVER_NAME"),-1);
    self->server_port = Str_To_Int_Dflt(getenv("SERVER_PORT"),80);

    self->request_uri = Str_Copy_Npl(getenv("REQUEST_URI"),-1);
    self->remote_addr = Str_Copy_Npl(getenv("REMOTE_ADDR"),-1);
    self->referer = Str_Copy_Npl(getenv("HTTP_REFERER"),-1);

    self->request_method = Cgir_Recognize_Request_Method(getenv("REQUEST_METHOD"));
    self->query_string = Str_Copy_Npl(getenv("QUERY_STRING"),-1);
    self->path_info = Str_Copy_Npl(getenv("PATH_INFO"),-1);    
    self->content_length = Str_To_Int_Dflt(getenv("CONTENT_LENGTH"),0);
    __Gogo
      {
        char *S = getenv("CONTENT_TYPE");
        self->content_type = Cgir_Recognize_Content_Type(S);
        if ( self->content_type == YOYO_CGIR_MULTIPART )
          {
            char *bndr = strrchr(S,';');
            if ( bndr )
              {
                while ( isspace(*bndr) ) ++bndr;
                if ( strcmp_I(bndr,"boundary=") == 0 )
                  self->content_boundary = Str_Copy_Npl(bndr+9,-1);
              }
          }
      }
      
    return self;
  }

char *Cgir_Format(YOYO_CGIR *self)
  {
    YOYO_BUFFER bf = {0};
    Buffer_Printf(&bf,"YOYO_CGIR(%08x){\n",self);
    Buffer_Printf(&bf,"  server_software = '%s'\n",self->server_software);
    Buffer_Printf(&bf,"  server_name = '%s'\n",self->server_name);
    Buffer_Printf(&bf,"  request_uri = '%s'\n",self->request_uri);
    Buffer_Printf(&bf,"  remote_addr = '%s'\n",self->remote_addr);
    Buffer_Printf(&bf,"  referer = '%s'\n",self->referer);
    Buffer_Printf(&bf,"  query_string = '%s'\n",self->query_string);
    Buffer_Printf(&bf,"  path_info = '%s'\n",self->path_info);
    Buffer_Printf(&bf,"  content_boundary = '%s'\n",self->content_boundary?self->content_boundary:"");
    Buffer_Printf(&bf,"  gateway_interface = %d\n",self->gateway_interface);
    Buffer_Printf(&bf,"  server_protocol = %d\n",self->server_protocol);
    Buffer_Printf(&bf,"  server_port = %d\n",self->server_port);
    Buffer_Printf(&bf,"  request_method = %d\n",self->request_method);
    Buffer_Printf(&bf,"  content_length = %d\n",self->content_length);
    Buffer_Printf(&bf,"  content_type = %d\n",self->content_type);
    Buffer_Append(&bf,"  params:\n",-1);
    Def_Format_Into(&bf,&self->params->root,2);
    Buffer_Printf(&bf,"}\n");
    return Buffer_Take_Data(&bf);
  }

YOYO_XDATA *Cgir_Query_Params(YOYO_CGIR *cgir)
  {
    if ( !cgir->params ) __Auto_Release
      {
        char lbuf[1024], c;
        char *q, *key, *value, *qE = lbuf+(sizeof(lbuf)-1);
        char *S = 0;
        cgir->params = __Refe(Xdata_Init());
        if ( cgir->request_method == YOYO_CGIR_GET )
          {
            S = cgir->query_string;
          }
        else if ( cgir->request_method == YOYO_CGIR_POST )
          {
            int count = cgir->content_length;
            int l = 0;
            S = __Malloc(count);
            while ( l < count )
              {
                int q = fread(S+l,1,count-l,stdin);
                if ( q < 0 )
                  __Raise(YOYO_ERROR_IO,
                    __Format("failed to read request content: %s",strerror(ferror(stdin))));
                l += q;
              }
          }
        if ( S && (cgir->request_method == YOYO_CGIR_GET || cgir->content_type == YOYO_CGIR_URLENCODED) )
          {
            while ( *S )
              {
                value = 0;
                key = q = lbuf;
                while ( *S && *S == '&' ) ++S;
                while ( *S && *S != '=' && *S != '&' )
                  {
                    c = ( *S != '%' && *S != '+' ) ? *S++ : Str_Urldecode_Char(&S);
                    if ( q >= lbuf && q < qE ) *q++ = c;
                  }
                if ( q >= lbuf && q < qE ) *q++ = 0;
                value = q; *q = 0; /* if (q == qE) there is one more char for final zero */
                if ( *S == '=' ) 
                  {
                    ++S;
                    while ( *S && *S != '&' )
                      {
                        c = ( *S != '%' && *S != '+' ) ? *S++ : Str_Urldecode_Char(&S);
                        if ( q >= lbuf && q < qE ) *q++ = c;
                      }
                  }
                *q = 0; /* if (q == qE) there is one more char for final zero */
                Xvalue_Set_Str(Xnode_Deep_Value(&cgir->params->root,key),value,q-value);
              }
          }
      }
    return cgir->params;
  }

int main()
  {

    char **p = environ;
    YOYO_CGIR *cgir = Cgir_Init();
    Cgir_Query_Params(cgir);
    
    printf("Content-Type: text/html; charset=utf-8\n\n");
    puts("<form method=GET><input type=text name=\"USER@Robin.ADDR.Street\" value=\"Avda. Libertad\" /><input type=submit value=\"Go\" /></form>");
    puts("<form method=POST><input type=text name=\"value-post\" value=\"post-method\" /><input type=submit value=\"Go\" /></form>");
    puts("<form method=POST enctype=\"multipart/form-data\"><input type=file name=\"file\" /><input type=text name=\"value-post\" value=\"post-method\" /><input type=submit value=\"Go\" /></form>");
    
    puts("<pre>");
    puts(Cgir_Format(cgir));
    
    for ( ; *p; ++p )
      {
        puts(*p);
      }
    puts("</pre>");

    return 0;
  }
