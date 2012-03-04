
#ifdef _LIBYOYO
#define _YOYO_URL_BUILTIN
#endif

enum 
  {
    URLX_UNKNOWN  = 0,
    URLX_HTTP     = 80,
    URLX_HTTPS    = 443,
    URLX_FILE     = -1,
  };

typedef struct _YOYO_URL 
  {
    char *host, *user, *passw, *query, *args, *anchor, *uri;
    int   port, proto;
  } YOYO_URL;

void YOYO_URL_Destruct(YOYO_URL *url)
#ifdef _YOYO_URL_BUILTIN
  {
    free(url->host);
    free(url->user);
    free(url->passw);
    free(url->query);
    free(url->args);
    free(url->anchor);
    free(url->uri);
    __Destruct(url);
  }
#endif
  ;
  
int Url_Proto(char *S)
#ifdef _YOYO_URL_BUILTIN
  {
    if ( !strcmp_I(S,"http")  )  return URLX_HTTP;
    if ( !strcmp_I(S,"https") )  return URLX_HTTPS;
    if ( !strcmp_I(S,"file")  )  return URLX_FILE;
    return YOYO_URL_UNKNOWN;
  }
#endif
  ;
  
YOYO_URL *Url_Parse(char *url)
#ifdef _YOYO_URL_BUILTIN
  {
    YOYO_URL *urlout = 0;
    __Auto_Ptr(urlout)
      {
        /* proto://user:passwd@host:port/query#anchor?args */
      
        char *p;
        char *pS = url;
        
        char *proto = 0;
        char *host  = 0;
        char *user  = 0;
        char *passw = 0;
        char *uri   = 0;
        char *args  = 0;
        char *query = 0;
        char *anchor= 0;
        int   port  = 0;
        
        p = pS;
        while ( *p && Isalpha(*p) ) ++p;
        
        if ( *p && *p == ':' && p[1] && p[1] == '/' && p[2] && p[2] == '/' )
          {
            proto = Str_Range(pS,p);
            pS = p+3;
          }
          
        p = pS;
        while ( *p && (Isalnum(*p) || *p == '.' || *p == '-' || *p == ':' ) ) ++p;
        
        if ( *p == '@' ) // user/password
          {
            char *q = pS;
            while ( *q != '@' && *q != ':' ) ++q;
            if ( *q == ':' ) 
              {
                user = Str_Range(pS,q);
                passw = Str_Range(q+1,p);
              }
            else
              user = Str_Range(pS,p);
            pS = p+1;
          }
          
        p = pS;
        while ( *p && (Isalnum(*p) || *p == '.' || *p == '-') ) ++p;
        
        if ( *p == ':' )
          {
            host = Str_Range(pS,p);
            pS = p+1; ++p;
            while ( *p && Isdigit(*p) ) ++p;
            if ( *p == '/' || !*p )
              { 
                port = strtol(pS,0,10); 
              }
            else
              __Raise(YOYO_ERROR_ILLFORMED,__yoTa("invalid port value",0));
            pS = p;
          }
        else if ( !*p || *p == '/' )
          {
            host = Str_Range(pS,p);
            pS = p;
          }
        
        uri = Str_Copy(pS,-1);  
        
        p = pS;
        while ( *p && *p != '?' && *p != '#' ) ++p;
        query = Str_Range(pS,p);

        if ( *p == '#' )
          {
            pS = ++p;
            while ( *p && *p != '?' ) ++p;
            anchor = Str_Range(pS,p);
          }
           
        if ( *p == '?' ) 
          {
            pS = ++p;
            while ( *p ) ++p;
            args = Str_Range(pS,p);
          }
                          
        urlout = __Object_Dtor(sizeof(YOYO_URL),YOYO_URL_Destruct);
        urlout->args  = __Retain(args);
        urlout->anchor= __Retain(anchor);
        urlout->query = __Retain(query);
        urlout->uri   = __Retain(uri);
        urlout->host  = __Retain(host);
        urlout->passw = __Retain(passw);
        urlout->user  = __Retain(user);
        urlout->port  = port;
        urlout->proto = Url_Proto(proto);
      }
      
    return urlout;
  }
#endif
  ;
