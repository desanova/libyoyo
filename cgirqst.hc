
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

#ifndef C_once_F176ECB4_D4AF_42B5_B69F_E9A97AB9469A
#define C_once_F176ECB4_D4AF_42B5_B69F_E9A97AB9469A

#include "core.hc"
#include "buffer.hc"
#include "string.hc"
#include "logout.hc"

extern char **environ;

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

typedef struct _YOYO_CGIR_COOKIE
  {
    struct _YOYO_CGIR_COOKIE *next;
    char *value;
    time_t expire;
    int  secure;
    char name[1];
  } YOYO_CGIR_COOKIE;

/* YOYO_CGIR_COOKIE does not require specific destructor, use free */

typedef struct _YOYO_CGIR_UPLOAD
  {
    struct _YOYO_CGIR_UPLOAD *next;
    char *path;
    char *mimetype;
    int length;
    int status;
    char name[1];
  } YOYO_CGIR_UPLOAD;

/* YOYO_CGIR_COOKIE does not require specific destructor, use free */

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
    YOYO_CGIR_COOKIE *cookie_in;
    YOYO_CGIR_COOKIE *cookie_out;
    YOYO_CGIR_UPLOAD *upload;
    YOYO_BUFFER *out;
  } YOYO_CGIR;

void Cgir_Destruct(YOYO_CGIR *self)
#ifdef _YOYO_CGIR_BUILTIN
  {
    __Gogo
      {
        YOYO_CGIR_COOKIE *qoo;
        for ( qoo = self->cookie_in; qoo; ) { void *q = qoo->next; free(qoo); qoo = q; }
        for ( qoo = self->cookie_out; qoo; ) { void *q = qoo->next; free(qoo); qoo = q; }
      }
    __Gogo
      {
        YOYO_CGIR_UPLOAD *qoo, *qoo1;
        for ( qoo = self->upload; qoo; )
          {
            qoo1 = qoo->next;
            if ( qoo->path && File_Exists(qoo->path) ) 
              __Try_Except
                File_Unlink(qoo->path,0);
              __Except
                Logoutf(YOYO_LOG_ERROR,"when unlink uploaded file `%s`, occured: %s",
                                         qoo->path, __Format_Error());
            free(qoo);
            qoo = qoo1;
          }
      }
    free(self->server_software);
    free(self->server_name);
    free(self->request_uri);
    free(self->remote_addr);
    free(self->referer);
    free(self->query_string);
    free(self->path_info);
    free(self->content_boundary);
    __Unrefe(self->params);
    __Unrefe(self->out);
    memset(self,0xfe,sizeof(*self)); /* !!! */
    __Destruct(self);
  }
#endif
  ;
  
YOYO_CGIR_COOKIE **Cgir_Find_Cookie_(YOYO_CGIR_COOKIE **qoo,char *name, int name_len)
#ifdef _YOYO_CGIR_BUILTIN
  {
    while ( *qoo )
      {
        int i;
        char *Q = (*qoo)->name;
        char *N = name;
        for ( i = 0; i < name_len; ++i )
          if ( Q[i] != N[i] )
            break;
        if ( i == name_len && !Q[i] )
          break;
        qoo = &(*qoo)->next;
      }
    return qoo;
  }
#endif
  ;

#define Cgir_Set_Cookie(Cgir,Name,Value,Expire) Cgir_Set_Cookie_(&(Cgir)->cookie_out,(Name),-1,(Value),-1,0,(Expire));
#define Cgir_Set_Secure_Cookie(Cgir,Name,Value,Expire) Cgir_Set_Cookie_(&(Cgir)->cookie_out,(Name),-1,(Value),-1,1,(Expire));
void Cgir_Set_Cookie_(YOYO_CGIR_COOKIE **qoo, char *name, int name_len, char *value, int value_len, int secure, time_t expire)
#ifdef _YOYO_CGIR_BUILTIN
  {
    YOYO_CGIR_COOKIE **cookie;
    
    if ( name_len < 0 ) name_len = name?strlen(name):0;
    if ( value_len < 0 ) value_len = value?strlen(value):0;
    
    cookie = Cgir_Find_Cookie_(qoo,name,name_len);
    if ( *cookie )
      {
        free(*cookie);
        *cookie = 0;
      }
      
    *cookie = __Malloc_Npl(sizeof(YOYO_CGIR_COOKIE)+(name_len+value_len+1));
    (*cookie)->value = (*cookie)->name+name_len+1;
    memcpy((*cookie)->name,name,name_len);
    (*cookie)->name[name_len] = 0;
    memcpy((*cookie)->value,value,value_len);
    (*cookie)->value[value_len] = 0;
    (*cookie)->secure = secure;
    (*cookie)->expire = expire;
    (*cookie)->next = 0;
  }
#endif
  ;
  
char *Cgir_Get_Cookie(YOYO_CGIR *cgir,char *name)
#ifdef _YOYO_CGIR_BUILTIN
  {
    if ( name )
      {
        YOYO_CGIR_COOKIE **q = Cgir_Find_Cookie_(&cgir->cookie_in,name,strlen(name));
        if ( *q )
          return (*q)->value;
      }
    return 0;
  }
#endif
  ;

YOYO_CGIR_UPLOAD *Cgir_Attach_Upload(YOYO_CGIR_UPLOAD **upload, char *path, char *mimetype, char *name, int len)
#ifdef _YOYO_CGIR_BUILTIN
  {
    int path_len = path?strlen(path):0;
    int mime_len = mimetype?strlen(mimetype):0;
    int name_len = name?strlen(name):0;
    int mem_len = path_len+1+mime_len+1+name_len+sizeof(YOYO_CGIR_UPLOAD);
    YOYO_CGIR_UPLOAD *u = __Malloc_Npl(mem_len);
    memset(u,0,mem_len);
    u->path = u->name+name_len+1;
    u->mimetype = u->path+path_len+1;
    
    if ( name_len ) memcpy(u->name,name,name_len);
    if ( path_len ) memcpy(u->path,path,path_len);
    if ( mime_len ) memcpy(u->mimetype,mimetype,mime_len);
    u->length = len;
    
    while ( *upload ) upload = &(*upload)->next;
    *upload = u;
    return u;
  }
#endif
  ;

int Cgir_Recognize_Request_Method(char *method)
#ifdef _YOYO_CGIR_BUILTIN
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
#endif
  ;
  
int Cgir_Recognize_Content_Type(char *cont_type)
#ifdef _YOYO_CGIR_BUILTIN
  {
    if ( cont_type )
      {
        while ( isspace(*cont_type) ) ++cont_type;
        if ( !strncmp_I(cont_type,"multipart/form-data;",20) )
          return YOYO_CGIR_MULTIPART;
        if ( !strcmp_I(cont_type,"application/x-www-form-urlencoded") )
          return YOYO_CGIR_URLENCODED;
        if ( !strcmp_I(cont_type,"application/octet-stream") )
          return YOYO_CGIR_OCTETSTREAM;
      }
    return 0;
  }
#endif
  ;
  
int Cgir_Recognize_Gateway_Ifs(char *gwifs)
#ifdef _YOYO_CGIR_BUILTIN
  {
    if ( gwifs )
      {
        while ( isspace(*gwifs) ) ++gwifs;
        if ( !strncmp_I(gwifs,"cgi/1.1",9) )
          return YOYO_CGIR_CGI_1_1;
        if ( !strncmp_I(gwifs,"cgi/1.0",9) )
          return YOYO_CGIR_CGI_1_0;
      }
    return YOYO_CGIR_CGI_X_X;
  }
#endif
  ;
  
int Cgir_Recognize_Protocol(char *proto)
#ifdef _YOYO_CGIR_BUILTIN
  {
    if ( proto )
      {
        while ( isspace(*proto) ) ++proto;
        if ( !strncmp_I(proto,"http/1.1",10) )
          return YOYO_CGIR_HTTP_1_1;
        if ( !strncmp_I(proto,"http/1.0",10) )
          return YOYO_CGIR_HTTP_1_0;
      }
    return 0;
  }
#endif
  ;
  
YOYO_CGIR *Cgir_Init()
#ifdef _YOYO_CGIR_BUILTIN
  {
    YOYO_CGIR *self = __Object_Dtor(sizeof(YOYO_CGIR),Cgir_Destruct);

    setlocale(LC_NUMERIC,"C");
    setlocale(LC_TIME,"C");

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
     
     __Gogo
      {
        char *S = getenv("HTTP_COOKIE");
        if ( S ) while (*S)
          {
            int nam_len,val_len;
            char *nam;
            char *val;
            while ( isspace(*S) ) ++S;
            nam = S;
            while ( *S && *S != '=' && *S != ';' ) ++S;
            if ( *S == '=' )
              {
                nam_len = S - nam;
                ++S;
                val = S;
                while ( *S && *S != ';' ) ++S;
              }
            else
              {
                val = nam;
                nam_len = 0;
              }
            val_len = S-val;
            if ( *S == ';' ) ++S;
            Cgir_Set_Cookie_(&self->cookie_in,nam,nam_len,val,val_len,0,0);
          }
      }
    
    self->out = Buffer_Init(0);
    return self;
  }
#endif
  ;
  
void Cgir_Format_Bf(YOYO_CGIR *self, YOYO_BUFFER *bf)
#ifdef _YOYO_CGIR_BUILTIN
  {
    YOYO_CGIR_COOKIE *q;
    
    Buffer_Printf(bf,"YOYO_CGIR(%08x){\n",self);
    Buffer_Printf(bf,"  server_software = '%s'\n",self->server_software);
    Buffer_Printf(bf,"  server_name = '%s'\n",self->server_name);
    Buffer_Printf(bf,"  request_uri = '%s'\n",self->request_uri);
    Buffer_Printf(bf,"  remote_addr = '%s'\n",self->remote_addr);
    Buffer_Printf(bf,"  referer = '%s'\n",self->referer);
    Buffer_Printf(bf,"  query_string = '%s'\n",self->query_string);
    Buffer_Printf(bf,"  path_info = '%s'\n",self->path_info);
    Buffer_Printf(bf,"  content_boundary = '%s'\n",self->content_boundary?self->content_boundary:"");
    Buffer_Printf(bf,"  gateway_interface = %d\n",self->gateway_interface);
    Buffer_Printf(bf,"  server_protocol = %d\n",self->server_protocol);
    Buffer_Printf(bf,"  server_port = %d\n",self->server_port);
    Buffer_Printf(bf,"  request_method = %d\n",self->request_method);
    Buffer_Printf(bf,"  content_length = %d\n",self->content_length);
    Buffer_Printf(bf,"  content_type = %d\n",self->content_type);
    Buffer_Append(bf,"  params:\n",-1);
    Def_Format_Into(bf,&self->params->root,2);
    Buffer_Append(bf,"  cookie-in:\n",-1);
    for ( q = self->cookie_in; q; q = q->next ) 
      Buffer_Printf(bf,"    %s => %s\n",q->name,q->value);
    Buffer_Append(bf,"  cookie-out:\n",-1);
    for ( q = self->cookie_out; q; q = q->next ) 
      Buffer_Printf(bf,"    %s => %s  ((%sexpire:%ld))\n",q->name,q->value,q->secure?"SECURED ":"",q->expire);
    Buffer_Printf(bf,"}\n");
  }
#endif
  ;
  
char *Cgir_Format_Cookies_Out(YOYO_CGIR *self)
#ifdef _YOYO_CGIR_BUILTIN
  {
    YOYO_CGIR_COOKIE *q;
    YOYO_BUFFER bf = {0};
    for ( q = self->cookie_out; q; q = q->next ) 
      {
        Buffer_Append(&bf,"Set-Cookie: ",-1);
        Buffer_Append(&bf,q->name,-1);
        Buffer_Fill_Append(&bf,'=',1);
        Buffer_Append(&bf,q->value,-1);
        if ( q->expire )
          {
            time_t gmt_time;
            static char *wday [] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
            static char *mon  [] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
            struct tm *tm = gmtime(&q->expire);
            Buffer_Printf(&bf,"; expires=%s, %02d-%s-%04d %02d:%02d:%02d GMT",
              wday[tm->tm_wday%7],
              tm->tm_mday,
              mon[tm->tm_mon%12],
              tm->tm_year+1900,
              tm->tm_hour,tm->tm_min,tm->tm_sec);
          }
        if ( q->secure )
          Buffer_Append(&bf,"; secure",-1);

        Buffer_Append(&bf,"; HttpOnly",-1);
        if ( q->next )
          Buffer_Fill_Append(&bf,'\n',1);
      }
    return Buffer_Take_Data(&bf);
  }
#endif
  ;
  
YOYO_XDATA *Cgir_Query_Params(YOYO_CGIR *cgir, char *upload_dir, int uload_maxsize)
#ifdef _YOYO_CGIR_BUILTIN
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
#endif
  ;
  
#define Cgir_Get_Outbuf(Cgir) ((Cgir)->out)
#define Cgir_Get_Len(Cgir) ((Cgir)->out->count)
#define Cgir_Get_Cstr(Cgir) ((Cgir)->out->at)
#define Cgir_Puts(Cgir,S) Buffer_Puts(Cgir->out,S)
#define Cgir_Fill(Cgir,C,N) Buffer_Fill_Append(Cgir->out,C,N)

void Cgir_Printf(YOYO_CGIR *cgir, char *fmt, ...)
#ifdef _YOYO_CGIR_BUILTIN
  {
    va_list va;
    va_start(va,fmt);
    Buffer_Printf_Va(cgir->out,fmt,va);
    va_end(va);
  }
#endif
  ;
  
#endif /* C_once_F176ECB4_D4AF_42B5_B69F_E9A97AB9469A */
