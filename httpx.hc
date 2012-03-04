
/*

Copyright © 2010-2012, Alexéy Sudáchen, alexey@sudachen.name, Chile

In USA, UK, Japan and other countries allowing software patents:

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    http://www.gnu.org/licenses/

Otherwise:

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

#ifndef C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC
#define C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC

#include "yoyo.hc"
#include "string.hc"
#include "buffer.hc"
#include "dicto.hc"
#include "file.hc"
#include "tcpip.hc"
#include "url.hc"
#include "asio.hc"

#ifdef _LIBYOYO
#define _YOYO_HTTPX_BUILTIN
#endif

/*
добавить отсылку на пост
добваить разбор хидеров ответа
добавить вызов колбек хендлера на финише
в колбек хендлер на терминирование и завершение добавить закрытие соеденения (тольео если не завершение с кипэлайвом)
*/

typedef int (*httpx_collback_t)(void *obj, struct _YOYO_HTTPX *httpx, int status);

typedef struct _YOYO_HTTPX
  {
    void *netchnl;
    YOYO_URL *url;
    YOYO_URL *proxy_url;
    
    int  method;
    int  maxcount;
    int  left;
    
    void *outstrm;
    void *poststrm;
    void *mon_obj;
    httpx_collback_t mon_callback;

    YOYO_BUFFER *bf;
    
    YOYO_DICTO  *hdrs;
    YOYO_BUFFER *content;
    int   streamed;
    int   status;
    char *status_text;
    
    int async:      1;
    int keepalive:  1;
    int legacy10:   1;
    int ssl:        1;
    int proxy:      1;
    int nline:      1;
        
  } YOYO_HTTPX;

enum 
  {
    HTTPX_ASYNC       = 1,
    HTTPX_KEEPALIVE   = 2,
    HTTPX_LEGACY_10   = 4,
    
    HTTPX_GET         = __FOUR_CHARS('G','E','T','_'),
    HTTPX_PUT         = __FOUR_CHARS('P','U','T','_'),
    HTTPX_POST        = __FOUR_CHARS('P','O','S','T'),
    HTTPX_HEAD        = __FOUR_CHARS('H','E','A','D'),
  
    HTTPX_BROKEN                  = 0x8e000000,
    HTTPX_FAILED                  = 0x8f000000,
    HTTPX_NOTIFY                  = 0x00001000,
    
    /* HTTPX_RESOLVED                = 0x00000f01, */
    HTTPX_PROXY_CONNECTED         = 0x00000f01,
    HTTPX_PROXY_AUTHORIZED        = 0x00000f02,
    HTTPX_SSL_CONNECTED           = 0x00000f03,
    HTTPX_CONNECTED               = 0x00000f10,
    HTTPX_REQUESTED               = 0x00000f20,
    HTTPX_GETTING_HEADERS         = 0x00000f30,
    HTTPX_RESPONDED               = 0x00000f41,
    HTTPX_GETTING_CONTENT         = 0x00000f42,
    HTTPX_FINISHED                = 0x00000f43,
    HTTPX_SEND                    = 0x00000e01,
    HTTPX_RECV                    = 0x00000e02,

    HTTPX_INVALID_RESPONSE        = 0x00000d01,
    HTTPX_INVALID_RESPONSE_CODE   = 0x00000d02,

    HTTPX_PENDING = ASIO_PENDING /* 0 */,
  };

#define HTTPX_SUCCEEDED(Status) (((Status)&0x8f000000) == 0)
#define HTTPX_STATUS(Status)    ((Status)&0x0fff)

int Httpx_Asio_Recv(YOYO_HTTPX *httpx, void *dta, int count, int mincount, asio_callback_t callback)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( !httpx->ssl )
      return Tcp_Asio_Recv(httpx->netchnl,dta,count,mincount,httpx,callback);
  }
#endif
  ;
  
int Httpx_Asio_Send(YOYO_HTTPX *httpx, void *dta, int count, asio_callback_t callback)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( !httpx->ssl )
      return Tcp_Asio_Send(httpx->netchnl,dta,count,httpx,callback);
  }
#endif
  ;
  
YOYO_HTTPX *Httpx_Client(char *url,int flags,void *mon_obj,httpx_collback_t mon_callback)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = __Object(sizeof(YOYO_HTTPX),funcs);
    httpx->url = __Retain(Url_Parse(url));
    
    if ( flags & HTTPX_ASYNC )
      httpx->async = 1;
    if ( flags & HTTPX_KEEPALIVE )
      httpx->keepalive = 1;
    if ( flags & HTTPX_LEGACY_10 )
      httpx->legacy10 = 1;
    
    if ( httpx->url->proto && httpx->url->proto != URLX_HTTP  )  
      __Raise(YOYO_ERROR_ILLFORMED,__yoTa("unknown HTTPX protocol requested",0));

    if ( !httpx->url->port ) 
      if ( !httpx->url->proto || httpx->url->proto == URLX_HTTP ) 
        httpx->url->port = 80;
        
    return httpx;
  }
#endif
  ;
  
int Httpx_Do_Callback(YOYO_HTTPX *httpx, int status)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( httpx->mon_callback )
      return httpx->mon_callback(httpx->mon_obj,httpx,status);
    return status;
  }
#endif
  ;
  
int Httpx_Update_Until_EOH(YOYO_HTTPX *httpx, int count)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_BUFFER *bf = httpx->bf;
    int i;
    char *q = bf->at + bf->count;
    bf->count += count;

    for ( i = 0; i < count; ++i )
      {
        if ( q[i] == '\r' && q[i+1] == '\n' )
          { if ( httpx->nline ) return bf->count-(count-i+2); httpx->nline = 1; ++i; } 
        else if ( q[i] == '\n' )
          { if ( httpx->nline ) return bf->count-(count-i+1);  httpx->nline = 1; } 
        ++i;
      }
      
    return 0;
  }      
#endif
  ;
  
void Httpx_Analyze_Headers(YOYO_HTTPX *httpx)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    int i;
    char *q, *Q, *S = httpx->bf->at;
    while (*S!='\n') ++S; /* skip HTTP/1.x line */
    for (;;)
      {
        q = ++S;
        while ( *q != '\n' ) ++q;
        *q = 0;
        for ( i = 1; q-i > S && Isspace(q[-i]); ++i ) q[-i] = 0;
        while (Isspace(*S)) ++S;
        if ( !*S ) break; /* empty line => end of headers*/ 
        Q = S;
        while ( *Q && *Q != ':' ) ++Q;
        if ( *Q == ':' )
          {
            *Q = 0;
            for ( i = 1; Q-i > S && Isspace(Q[-i]); ++i ) Q[-i] = 0;
            ++Q;
            while ( Isspace(*Q) ) ++Q;
            Dicto_Put(httpx->hdrs,S,(Q=Str_Copy_Npl(q,-1)));
          }
      }
  }
#endif
  ;
  
int Cbk_Httpx_Getting_Content(void *netchnl, void *_httpx, int status, byte_t *bytes, int count, int left)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    int L;
    YOYO_HTTPX *httpx = _httpx;
    YOYO_BUFFER *bf = httpx->bf;
    
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN|HTTPX_GETTING_HEADERS);

    L = Yo_MIN(httpx->left,count);
    httpx->left -= L;
    httpx->streamed += L;
    Oj_Write(httpx->outstrm,bf->at,L,-1);

    if ( !httpx->left )
      return HTTPX_FINISHED;

    if ( status&ASIO_SYNCHRONOUSE )
      return HTTPX_CONTINUE;
    
    return Httpx_Asio_Recv(netchnl,bf->at,bf->capacity,Yo_MIN(httpx->left,bf->capacity)
                        ,httpx
                        ,Cbk_Httpx_Getting_Content);
  }
#endif
  ;
    
int Cbk_Httpx_Getting_Headers(void *netchnl, void *_httpx, int status, byte_t *bytes, int count, int left)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    YOYO_BUFFER *bf = httpx->bf;
    int iterate = 0;
    
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN|HTTPX_GETTING_HEADERS);
    
    if ( httpx->bf->count == 0 )
      {
        if ( !strcmp_I(bf->at,"HTTP/1.") )
          {
            char *q = bf->at + 8, *Q;
            bf->at[count] = 0;
            while ( *q && !Isspace(*q) ) ++q;
            while ( Isspace(*q) ) ++q;
            httpx->status = strtol(q,&q,10);
            if ( httpx->status < 100 || httpx->status >= 510 )
              return Httpx_Do_Callback(httpx,HTTPX_FAILED|HTTPX_INVALID_RESPONSE_CODE);    
            while ( *q != '\n' && *q != '\r' && Isspace(*q) ) ++q;
            Q = q;
            while ( *q && *q != '\n' && *q != '\r' && !Isspace(*q) ) ++q;
            httpx->status_text = Str_Range_Npl(Q,q);
            bf->count = (q - bf->at);         
            count -= bf->count; 
            httpx->nline = 0;
          }
        else
          return Httpx_Do_Callback(httpx,HTTPX_FAILED|HTTPX_INVALID_RESPONSE);
      }
    else
      iterate = status&ASIO_SYNCHRONOUSE;
      
    for(;;) 
      {
        int eoh = Httpx_Update_Until_EOH(httpx,count);

        if ( eoh )
          {
            char *foo;
            Httpx_Analyze_Headers(httpx);
            httpx->left = 0;
            
            if ( foo = Dicto_Get(httpx->hdrs,"Content-Length",0) )
              httpx->left = Yo_Minu(Str_To_Int(foo),httpx->maxcount);
              
            if ( httpx->outstrm && httpx->left != 0 )
              {
                int L = bf->count-eoh;
                L = Yo_MIN(httpx->left,L);
                httpx->left -= L;
                Oj_Write(httpx->outstrm,bf->at+eoh,L,-1);
                httpx->streamed += L;
                bf->count = 0;
                while ( httpx->left )
                  {
                    status = Httpx_Asio_Recv(netchnl,bf->at,bf->capacity,Yo_MIN(httpx->left,bf->capacity)
                                          ,httpx
                                          ,Cbk_Httpx_Getting_Content);
                    if ( status != HTTPX_CONTINUE )
                      return status;
                  }
              }
              
            return HTTPX_FINISHED;
          }
        
        if ( iterate )
           return HTTPX_CONTINUE;
           
        Buffer_Grow_Reserve(bf,bf->count + 512);
        status = Httpx_Asio_Recv(netchnl,bf->at,512,1,
                          ,httpx
                          ,Cbk_Httpx_Getting_Headers);    

        if ( status != HTTPX_CONTINUE )
          return status;
      }
  }
#endif
  ;
  
int Cbk_Httpx_Requested(void *netchnl, void *_httpx, int status)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN|HTTPX_REQUESTED);
    httpx->state = HTTPX_REQUESTED;
    Httpx_Do_Callback(httpx,HTTPX_REQUESTED);
    Buffer_Grow_Reserve(httpx->bf,1023);
    return Httpx_Asio_Recv(netchnl, httpx->bf->at, 1023, 12 /* lengthof HTTP/1.1 200 */
                        ,httpx
                        ,Cbk_Httpx_Getting_Headers);    
  }
#endif
  ;
  
int Cbk_Httpx_Connected(void *netchnl,void *_httpx,int status)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN|HTTPX_CONNECTED);
    httpx->state = HTTPX_CONNECTED;
    Httpx_Do_Callback(httpx,HTTPX_CONNECTED);
    /* httpx->bf contains prepared request */
    return Httpx_Asio_Send(netchnl,httpx->bf->at,httpx->bf->count,httpx,Cbk_Httpx_Requested);    
  }
#endif
  ;
  
int Cbk_Httpx_Proxy_Connected(void *netchnl,void *_httpx,int status)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN|HTTPX_PROXY_CONNECTED);
    httpx->state = HTTPX_PROXY_CONNECTED;
    Httpx_Do_Callback(httpx,HTTPX_PROXY_CONNECTED);
    
    /// auth / ssl connect
    return Cbk_Httpx_Connected(netchnl,_httpx,status);
  }
#endif
  ;
  
int Httpx_Asio_Connect(YOYO_HTTPX *httpx)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    __Unrefe(httpx->netchnl);
    httpx->netchnl = Tcp_Socket(httpx->async?TCPSOK_ASYNC:0);
    
    if ( httpx->proxy_url )
      return Tcp_Asio_Connect(httpx->netchnl,httpx->proxy_url->host,httpx->proxy_url->port,httpx,Cbk_Httpx_Proxy_Connected);
      
    return Tcp_Asio_Connect(httpx->netchnl,httpx->url->host,httpx->url->port,httpx,Cbk_Httpx_Connected);
  }
#endif
  ;

void Build_Http_Request(YOYO_HTTPX *httpx, int method, char *uri, YOYO_DICTO *hdrs)
#ifdef _YOYO_HTTPX_BUILTIN
  {
  }
#endif
  ;
  
int Httpx_Query(YOYO_HTTPX *httpx, int method, char *uri, YOYO_DICTO *hdrs, void *poststrm, void *contstrm, int maxcount)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( httpx->status_text ) { free(httpx->status_text); httpx->status_text = 0; }
    httpx->status = 0;
    httpx->method = method;
    httpx->maxcount = maxcount;
    httpx->streamed = 0;
    Build_Http_Request(httpx,method,uri,hdrs);
    return Httpx_Asio_Connect(httpx->netchnl,httpx,Cbk_Httpx_Connected);
  }
#endif
  ;
  
int Httpx_Head(YOYO_HTTPX *httpx, char *uri)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    return Httpx_Query(httpx,HTTPX_GET,uri,0,0,0,0);
  }
#endif
  ;
  
int Httpx_Get(YOYO_HTTPX *httpx, char *uri, YOYO_DICTO *params, void *contstrm, int maxcount)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    uri = Url_Compose(uri,params,0);
    return Httpx_Query(httpx,HTTPX_GET,uri,0,0,contstrm,maxcount);
  }
#endif
  ;
  
int Httpx_Post(YOYO_HTTPX *httpx, char *uri, YOYO_DICTO *params, void *contstrm, int maxcount)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    void *poststrm = 0;
    if ( params ) 
      {
        YOYO_BUFFER *bf = Buffer_Init(0);
        Url_Xform_Encode(params,Buffer_Init(0));
        poststrm = Buffer_As_File(bf);
      } 
    return Httpx_Query(httpx,HTTPX_GET,uri,0,poststrm,contstrm,maxcount);
  }
#endif
  ;
  




enum
  {
    YOYO_HTTPX_DOING_NOTHING      = 0,
    YOYO_HTTPX_PREPARING       = 1,
    YOYO_HTTPX_RESOLVING       = 2,
    YOYO_HTTPX_CONNECTING      = 3,
    YOYO_HTTPX_QUERYING        = 4,
    YOYO_HTTPX_GETTING_STATUS  = 5,
    YOYO_HTTPX_GETTING_HEADERS = 6,
    YOYO_HTTPX_GETTING_CONTENT = 7,
    YOYO_HTTPX_FINISHED        = 8,
    YOYO_HTTPX_FAILED          = 9,
    YOYO_HTTPX_RESOLVING_ERROR    = 0x1001,
    YOYO_HTTPX_URLPARSING_ERROR   = 0x1002,
    YOYO_HTTPX_GETTING_ERROR      = 0x1003,
    
    YOYO_HTTPX_GET                = __FOUR_CHARS('G','E','T','_'),
    YOYO_HTTPX_PUT                = __FOUR_CHARS('P','U','T','_'),
    YOYO_HTTPX_POST               = __FOUR_CHARS('P','O','S','T'),
    YOYO_HTTPX_HEAD               = __FOUR_CHARS('H','E','A','D'),
  };

enum 
  {
    YOYO_URL_UNKNOWN  = 0,
    YOYO_URL_HTTP     = 80,
    YOYO_URL_HTTPS    = 443,
    YOYO_URL_FILE     = -1,
  };

typedef struct _YOYO_HTTPX_NTFY
  {
    void (*progress)(struct _YOYO_HTTPX_NTFY *, int st, int count, int total);
    void (*error)(struct _YOYO_HTTPX_NTFY *, int st, char *msg);
  } YOYO_HTTPX_NTFY;


typedef struct _YOYO_HTTPX
  {
    void *strm;
    YOYO_BIO *bio_in;
    YOYO_BIO *bio_out;
    
    YOYO_DICTO *hdrs;
    int  code;
    char *text;
    int  content_length;
    char *content_type; /* handles by hdrs */
    
    int http10: 1;
    int heepalive: 1;
  } YOYO_HTTPX;

YOYO_HTTPX_Destruct(YOYO_HTTPX *httpx)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    Oj_Close(httpx->strm);
    __Unrefe(httpx->bio_in);
    __Unrefe(httpx->bio_out);
    __Unrefe(httpx->strm);
    __Unrefe(httpx->hdrs);
    free(http->text);
    __Destruct(httpx);
  }
#endif
  ;
  
YOYO_HTTPX *Httpx_Connect(int proto, char *host, int port)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = 0;
    __Auto_Ptr(cnt) 
      {
        YOYO_TCPSOK *sok;
        
        sok = Tcp_Open(host,port);
        
        httpx = __Object_Dtor(sizeof(YOYO_HTTPX),YOYO_HTTPX_Destruct);
        httpx->strm    = __Refe(sok);
        httpx->bio_in  = __Refe(Bio_Input(httpx->strm));
        httpx->bio_out = __Refe(Bio_Output(httpx->strm));
      }
    return cnt;
  }
#endif

void Httpx_Send_Header_Line(YOYO_BIO *bio, char *name, char *value)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    Bio_Write(bio,name,-1);
    Bio_Write(bio,": ",2);
    Bio_Write(bio,value,-1);
    Bio_Write(bio,"\r\n",2);
  }
#endif
  ;
  
void Httpx_Send_Header_Line_Filtered(YOYO_BIO *bio, char *name, char *value)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( !strcmp_I(name,"Host")
       ||!strcmp_I(name,"User-Agent")
       ||!strcmp_I(name,"Accept-Charset")
       ||!strcmp_I(name,"Accept")
       ||!strcmp_I(name,"Content-Type")
       ||!strcmp_I(name,"Connection")
       ||!strcmp_I(name,"Content-Length") )
      return;
      
    Httpx_Send_Header_Line(bio,name,value); 
  }
#endif  
  ;
    
void Httpx_Send_Common_Header_Line(YOYO_DICTO *hdrs,char *name, char *dflt,YOYO_BIO *bio)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    char *val = hdrs?Dicto_Get(hdrs,name,dlft):dflt;
    Httpx_Send_Header_Line(bio,name,val); 
  }
#endif
  ;
    
void Httpx_Send_Request_Line(YOYO_BIO *bio, int method, char *uri, int http10)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    static char s_GET[3]  = "GET";
    static char s_PUT[3]  = "PUT";
    static char s_POST[4] = "POST";
    static char s_HEAD[4] = "HEAD";
    
    switch ( method )
      {
        case YOYO_HTTPX_GET:  Bio_Write(bio,s_GET,sizeof(s_GET)); break;
        case YOYO_HTTPX_PUT:  Bio_Write(bio,s_PUT,sizeof(s_PUT)); break;
        case YOYO_HTTPX_POST: Bio_Write(bio,s_POST,sizeof(s_POST)); break;
        case YOYO_HTTPX_HEAD: Bio_Write(bio,s_HEAD,sizeof(s_HEAD)); break;
        default:
          __Raise_Format(YOYO_ERROR_ILLFORMED,(__yoTa("invalid HTTPX request method: %d",0),method);
      }
      
    Bio_Write(bio," ",1);
    Bio_Write(bio,uri,-1);
    
    if ( http10 )
      Bio_Write(bio,"HTTP/1.0\r\n",10);
    else
      Bio_Write(bio,"HTTP/1.1\r\n",10);
  }
#endif
  ;
  
void Httpx_Send_Request(YOYO_HTTPX *httpx, YOYO_URL *url, int method, YOYO_DICTO *hdrs, void *strm)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    YOYO_BIO *bio = httpx->bio_out;
    Bio_Reset(&httpx->bio_out);    
    Httpx_Send_Request_Line(bio,method,url->uri,httpx->http10);
    Httpx_Send_Common_Header_Line(hdrs,"Host",url->host,bio);
    Httpx_Send_Common_Header_Line(hdrs,"User-Agent","httpx",bio);
    Httpx_Send_Common_Header_Line(hdrs,"Accept","*/*",bio);
    Httpx_Send_Common_Header_Line(hdrs,"Accept-Charset","utf-8",bio);
    if ( hdrs ) 
      Dicto_Apply(hdrs,Httpx_Send_Header_Line_Filtered,bio);
    if ( strm && ( method == YOYO_HTTPX_POST || method == YOYO_HTTPX_PUT ) ) 
      {
        quad_t length = Oj_Available(strm);
        char len[13];
        snprintf(len,"%d",sizeof(len),(int)length);
        if ( method == YOYO_HTTPX_POST )
          Httpx_Send_Common_Header_Line(hdrs,"Content-Type","application/x-www-form-urlencoded",bio);
        else  
          Httpx_Send_Common_Header_Line(hdrs,"Content-Type","application/octet-stream",bio);
        Httpx_Send_Header_Line("Content-Length",len);
        Bio_Write(bio,"\r\n",2);
        Bio_Copy_Into(bio,strm);
      }
    else
      Bio_Write(bio,"\r\n",2);
    Bio_Flush(bio);
  }
#endif
  ;
  
void Httpx_Recv_Response(YOYO_HTTPX *httpx)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    char *S = 0;
    YOYO_BUFFER *bf = Buffer_Init(0);
    YOYO_BIO *bio = httpx->bio_in;
    Bio_Reset(bio);
    S = Bio_Read_Line(bio,bf);
    httpx->content_length = 0;
    httpx->content_type = 0;
    
    if ( strcmp_I(S,"http/1.") )
      {
        while ( *S && !Isspace(*S) ) ++S;
        while ( Isspace(*S) ) ++S;
        httpx->code = strtol(S,&S,10);
        while ( Isspace(*S) ) ++S;
        httpx->text = Str_Copy(S,-1);
      }
    else
      __Raise_Format(YOYO_ERROR_ILLFORMED,(__yoTa("illformed http response: %.10s",0),S));
        
    for (;;)
      {
        char *q, *Q;
        S = Bio_Read_Line(bio,bf);
        while (Isspace(*S)) ++S;
        if ( !*S ) break; 
        q = S;
        while ( *q && *q != ':' ) ++q;
        if ( *q == ':' )
          {
            *q = 0;
            ++q;
            while ( Isspace(*q) ) ++q;
            Dicto_Put(httpx->hdrs,S,(Q=Str_Copy_Npl(q,-1)));
            if ( !strcmp_I(S,"Content-Length") )
              httpx->content_length = Str_To_Int(q);
            else if ( !strcmp_I(S,"Content-Type") )
              httpx->content_type = Q;
          }
      }
  }
#endif
  ;
  
int Httpx_Request(YOYO_HTTPX *httpx, char *uri, int method, YOYO_DICTO *hdrs, void *strm)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    __Auto_Release
      {
        Httpx_Send_Request(httpx,uri,method,hdrs,strm);
        Httpx_Recv_Response(httpx);
      }
      
    return httpx->code;
  }
#endif
  ;
  
#define Httpx_Clear_Cookies(Hdrs) Httpx_Set_Cookie(Hdrs,0,0,0)   
void Httpx_Set_Cookie(YOYO_DICTO *hdrs, char *name, char *value, quad_t lifetime)
#ifdef _YOYO_HTTPX_BUILTIN
  {
  }
#endif
  ;
    
char *Httpx_Get_Cookie(YOYO_DICTO *hdrs, char *name, quad_t *lifetime)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    return 0;
  }
#endif
  ;
  
#define Httpx_Read_All(Httpx,Out) Httpx_Read(Httpx,Out,-1)
YOYO_BUFFER *Httpx_Read(YOYO_HTTPX *httpx, YOYO_BUFFER *out, int count)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( !out )
      out = Buffer_Init(0);

    __Auto_Release
      {
        void *f = Buffer_As_File(out);
        Bio_Copy_From(httpx->bio_in,f,count);
      }
      
    return out;
  }
#endif
  ;
  
void Httpx_Close(YOYO_HTTPX *httpx)
#ifdef _YOYO_HTTPX_BUILTIN
  {
    Oj_Close(httpx->strm);
  }
#endif
  ;

#endif /* C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC */

