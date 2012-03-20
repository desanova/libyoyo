
/*

Copyright © 2010-2012, Alexéy Sudachén, alexey@sudachen.name, Chile

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
#define _HTTPX_BUILTIN
#endif

typedef void (*httpx_collback_t)(void *obj, struct _YOYO_HTTPX *httpx, int status);

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

    int nline;
    YOYO_BUFFER *bf;
    
    YOYO_DICTO  *hdrs;
    YOYO_BUFFER *content;
    int   state;
    int   streamed;
    int   status;
    char *status_text;
    
    int async:      1;
    int keepalive:  1;
    int legacy10:   1;
    int ssl:        1;
    int proxy:      1;
    int interrupted:1;
    int chunked:    1;
        
  } YOYO_HTTPX;

void YOYO_HTTPX_Destruct(YOYO_HTTPX *httpx)
  {
    __Unrefe(httpx->netchnl);
    __Unrefe(httpx->url);
    __Unrefe(httpx->proxy_url);
    __Unrefe(httpx->outstrm);
    __Unrefe(httpx->poststrm);
    __Unrefe(httpx->mon_obj);
    __Unrefe(httpx->bf);
    __Unrefe(httpx->hdrs);
    __Unrefe(httpx->content);
    free(httpx->status_text);
    __Destruct(httpx);
  }

enum 
  {
    HTTPX_ASYNC       = 1,
    HTTPX_KEEPALIVE   = 2,
    HTTPX_LEGACY_10   = 4,
    
    HTTPX_GET         = __FOUR_CHARS('G','E','T','_'),
    HTTPX_PUT         = __FOUR_CHARS('P','U','T','_'),
    HTTPX_POST        = __FOUR_CHARS('P','O','S','T'),
    HTTPX_HEAD        = __FOUR_CHARS('H','E','A','D'),
  
    HTTPX_BROKEN                  = 0x80000000,
    HTTPX_TIMER                   = 0x00001000,
    
    HTTPX_INITILIZED              = 0x00000f00,
    HTTPX_PROXY_CONNECTED         = 0x00000f01,
    HTTPX_PROXY_AUTHORIZED        = 0x00000f02,
    HTTPX_SSL_CONNECTED           = 0x00000f03,
    HTTPX_CONNECTED               = 0x00000f10,
    HTTPX_SENDING_POSTDATA        = 0x00000f20,
    HTTPX_REQUESTED               = 0x00000f21,
    HTTPX_GETTING_HEADERS         = 0x00000f30,
    HTTPX_RESPONDED               = 0x00000f31,
    HTTPX_GETTING_CONTENT         = 0x00000f40,
    HTTPX_FINISHED                = 0x00000f41,
    HTTPX_SEND                    = 0x00000e01,
    HTTPX_RECV                    = 0x00000e02,

    HTTPX_INVALID_RESPONSE        = 0x00000d01,
    HTTPX_INVALID_RESPONSE_CODE   = 0x00000d02,

    HTTPX_CONTINUE                = -1,
  };

#define HTTPX_SUCCEEDED(Status) (((Status)&0x8f000000) == 0)
#define HTTPX_STATUS(Status)    ((Status)&0x0fff)

int Httpx_Asio_Recv(YOYO_HTTPX *httpx, void *dta, int count, int mincount, asio_recv_callback_t callback)
#ifdef _HTTPX_BUILTIN
  {
    if ( !httpx->ssl )
      return Tcp_Asio_Recv(httpx->netchnl,dta,count,mincount,httpx,callback);
    return 0;
  }
#endif
  ;
  
int Httpx_Asio_Send(YOYO_HTTPX *httpx, void *dta, int count, asio_send_callback_t callback)
#ifdef _HTTPX_BUILTIN
  {
    if ( !httpx->ssl )
      return Tcp_Asio_Send(httpx->netchnl,dta,count,httpx,callback);
    return 0;
  }
#endif
  ;
  
void Httpx_Append_Header_Line(YOYO_BUFFER *bf, char *name, char *value)
#ifdef _HTTPX_BUILTIN
  {
    Buffer_Append(bf,name,-1);
    Buffer_Append(bf,": ",2);
    Buffer_Append(bf,value,-1);
    Buffer_Append(bf,"\r\n",2);
  }
#endif
  ;

void Httpx_Append_Header_Line_Filtered(char *name, void *value, void *bf)
#ifdef _HTTPX_BUILTIN
  {
    if ( !strcmp_I(name,"Host")
       ||!strcmp_I(name,"User-Agent")
       ||!strcmp_I(name,"Accept-Charset")
       ||!strcmp_I(name,"Accept")
       ||!strcmp_I(name,"Content-Type")
       ||!strcmp_I(name,"Connection")
       ||!strcmp_I(name,"Content-Length") )
      return;
      
    Httpx_Append_Header_Line(bf,name,value); 
  }
#endif  
  ;
  
void Httpx_Append_Common_Header_Line(YOYO_BUFFER *bf, YOYO_DICTO *hdrs,char *name, char *dflt)
#ifdef _HTTPX_BUILTIN
  {
    char *val = hdrs?Dicto_Get(hdrs,name,dflt):dflt;
    Httpx_Append_Header_Line(bf,name,val); 
  }
#endif
  ;
    
void Httpx_Append_Request_Line(YOYO_BUFFER *bf, int method, char *uri, int http10)
#ifdef _HTTPX_BUILTIN
  {
    static char s_GET[3]  = "GET";
    static char s_PUT[3]  = "PUT";
    static char s_POST[4] = "POST";
    static char s_HEAD[4] = "HEAD";
    
    switch ( method )
      {
        case HTTPX_GET:  Buffer_Append(bf,s_GET,sizeof(s_GET)); break;
        case HTTPX_PUT:  Buffer_Append(bf,s_PUT,sizeof(s_PUT)); break;
        case HTTPX_POST: Buffer_Append(bf,s_POST,sizeof(s_POST)); break;
        case HTTPX_HEAD: Buffer_Append(bf,s_HEAD,sizeof(s_HEAD)); break;
        default:
          __Raise_Format(YOYO_ERROR_ILLFORMED,(__yoTa("invalid HTTPX request method: %d",0),method));
      }
      
    Buffer_Append(bf," ",1);
    Buffer_Append(bf,uri,-1);
    
    if ( http10 )
      Buffer_Append(bf," HTTP/1.0\r\n",11);
    else
      Buffer_Append(bf," HTTP/1.1\r\n",11);
  }
#endif
  ;
  
void Build_Http_Request(YOYO_HTTPX *httpx, int method, char *uri, YOYO_DICTO *hdrs)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_BUFFER *bf = httpx->bf;
    bf->count = 0;
    Httpx_Append_Request_Line(bf,method,uri,httpx->legacy10);
    Httpx_Append_Common_Header_Line(bf,hdrs,"Host",httpx->url->host);
    Httpx_Append_Common_Header_Line(bf,hdrs,"User-Agent","httpx");
    Httpx_Append_Common_Header_Line(bf,hdrs,"Accept","*/*");
    Httpx_Append_Common_Header_Line(bf,hdrs,"Accept-Charset","utf-8");
    if ( hdrs ) 
      Dicto_Apply(hdrs,Httpx_Append_Header_Line_Filtered,bf);
    if ( method == HTTPX_POST || method == HTTPX_PUT )
      {
        char len[13];
        quad_t qlen = httpx->poststrm?Oj_Available(httpx->poststrm):0;
        sprintf(len,"%u",(unsigned int)qlen);
        if ( method == HTTPX_POST )
          Httpx_Append_Common_Header_Line(bf,hdrs,"Content-Type","application/x-www-form-urlencoded");
        else
          Httpx_Append_Common_Header_Line(bf,hdrs,"Content-Type","application/octet-stream");
        Httpx_Append_Header_Line(bf,"Content-Length",len);
      }
    Buffer_Append(bf,"\r\n",2);      
  }
#endif
  ;

void Httpx_Interrupt(YOYO_HTTPX *httpx)
  {
    if ( !httpx->ssl )
      Tcp_Asio_Interrupt(httpx->netchnl);
    STRICT_REQUIRE( httpx->interrupted == 1 );
  }
  
void Httpx_Do_Callback(YOYO_HTTPX *httpx, int status)
#ifdef _HTTPX_BUILTIN
  {
    if ( httpx->mon_callback )
      httpx->mon_callback(httpx->mon_obj,httpx,httpx->state|status);

    if ( status & HTTPX_BROKEN ) /* Asio interrupt callback fall here */
      httpx->interrupted = 1;
         
    if ( ( httpx->interrupted )
      || ( httpx->state == HTTPX_FINISHED && !httpx->keepalive ) )
      {
        Oj_Close(httpx->netchnl); 
      }
  }
#endif
  ;
  
void Httpx_Timer_Callback(YOYO_HTTPX *httpx)
#ifdef _HTTPX_BUILTIN
  {
    if ( httpx->mon_callback )
      httpx->mon_callback(httpx->mon_obj,httpx,httpx->state|HTTPX_TIMER);    
  }
#endif
  ;

int Httpx_Update_Until_EOH(YOYO_HTTPX *httpx, int count)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_BUFFER *bf = httpx->bf;
    int i = bf->count;
    bf->count += count;

    for ( ; i < bf->count; ++i )
      {
        if ( bf->at[i] == '\r' && bf->at[i+1] == '\n' )
          { if ( httpx->nline ) return i+2; httpx->nline = 1; ++i; } 
        else if ( bf->at[i] == '\n' )
          { if ( httpx->nline ) return i+1;  httpx->nline = 1; } 
        else
          httpx->nline = 0; 
        ++i;
      }
      
    return 0;
  }      
#endif
  ;
  
void Httpx_Analyze_Headers(YOYO_HTTPX *httpx)
#ifdef _HTTPX_BUILTIN
  {
    int i;
    char *q, *Q, *S = httpx->bf->at;
    while (*S!='\n') ++S; /* skip HTTP/1.x line */
    q = ++S;
    for (;;)
      {
        while ( *q != '\n' ) ++q;
        STRICT_REQUIRE(q >= httpx->bf->at && q < httpx->bf->at + httpx->bf->capacity);
        *q = 0;
        for ( i = 1; q-i > S && Isspace(q[-i]); ++i ) q[-i] = 0;
        while (Isspace(*S)) ++S;
        if ( !*S ) break; /* empty line => end of headers*/ 
        Q = S;
        puts(S);
        while ( *Q && *Q != ':' ) ++Q;
        STRICT_REQUIRE(Q >= httpx->bf->at && Q < httpx->bf->at + httpx->bf->capacity);
        if ( *Q == ':' )
          {
            *Q = 0;
            for ( i = 1; Q-i > S && Isspace(Q[-i]); ++i ) Q[-i] = 0;
            ++Q;
            while ( Isspace(*Q) ) ++Q;
            Dicto_Put(httpx->hdrs,S,(Q=Str_Copy_Npl(Q,-1)));
          }
        S = ++q;
      }
  }
#endif
  ;
  
int Cbk_Httpx_Getting_Content(void *_httpx, int status, int count)
#ifdef _HTTPX_BUILTIN
  {
    int L;
    YOYO_HTTPX *httpx = _httpx;
    YOYO_BUFFER *bf = httpx->bf;
    
    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;

    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;

    L = Yo_MIN(httpx->left,count);
    httpx->left -= L;
    httpx->streamed += L;
    Oj_Write(httpx->outstrm,bf->at,L,-1);

    if ( !httpx->left )
      return httpx->state = HTTPX_FINISHED,
             Httpx_Do_Callback(httpx,0),
             httpx->state;

    if ( status&ASIO_SYNCHRONOUS )
      return HTTPX_CONTINUE;
    
    return Httpx_Asio_Recv(httpx, bf->at, bf->capacity, Yo_MIN(httpx->left,bf->capacity)
                          ,Cbk_Httpx_Getting_Content);
  }
#endif
  ;

int Cbk_Http_Getting_Chunked(void *_httpx, int status, int count)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    YOYO_BUFFER *bf = httpx->bf;
    int iterate = 0;
    
    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;

    httpx->state = HTTPX_GETTING_CONTENT;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;
  
    bf->count += count;
  
    if ( status & ASIO_SYNCHRONOUS )
      return HTTPX_CONTINUE;
  
    if ( httpx->outstrm ) for (;;)
      {
        if ( httpx->left )
          {
            int L = Yo_Minu(httpx->left,bf->count-httpx->nline);
            Oj_Write(httpx->outstrm,bf->at+httpx->nline,L,L);
            httpx->left -= L;
            if ( httpx->left )
              {
                bf->count = 0;
                httpx->nline = 0;
                if ( (status = Httpx_Asio_Recv(httpx,bf->at,bf->capacity,Yo_Minu(httpx->left,bf->capacity)
                                            ,Cbk_Http_Getting_Chunked)) 
                             != HTTPX_CONTINUE )
                    return status;
              }
            else
              {
                httpx->nline += L;
              }
          }
        else
          {
            int i = httpx->nline;
            byte_t *q = bf->at;
            while ( i < bf->count && q[i] != '\n' ) ++i;
            if ( q[i] == '\n' )
              {
                char *e = 0;
                ++i;
                if ( Isspace(*(q+httpx->nline)) ) 
                  {
                    httpx->nline = i;
                  }
                else
                  {
                    httpx->left = strtol(q+httpx->nline,&e,16);
                    if ( !httpx->left && *(q+httpx->nline) == '0' )
                      {
                        /* fixme */
                        if ( q[i] != '\n' && !(q[i] == '\r' && q[i+1] == '\n' ) )
                          {
                            Buffer_Grow_Reserve(bf,bf->count+2);
                            if ( (status = Httpx_Asio_Recv(httpx,bf->at+bf->count,2,1
                                                         ,Cbk_Http_Getting_Chunked)) 
                                         != HTTPX_CONTINUE )
                            continue;
                          }
                        break; // finish
                      }
                    httpx->nline = i;
                  }
              }
            else  
              {
                Buffer_Grow_Reserve(bf,bf->count+128);
                if ( (status = Httpx_Asio_Recv(httpx,bf->at+bf->count,128,1
                                               ,Cbk_Http_Getting_Chunked)) 
                               != HTTPX_CONTINUE )
                  return status;
              } 
          }
      }

    return httpx->state = HTTPX_FINISHED,
           Httpx_Do_Callback(httpx,0),
           httpx->state;
  }
#endif
  ;
    
int Cbk_Httpx_Getting_Headers(void *_httpx, int status, int count)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    YOYO_BUFFER *bf = httpx->bf;
    int iterate = 0;
    
    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;

    httpx->state = HTTPX_GETTING_HEADERS;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;
    
    if ( httpx->bf->count == 0 )
      {
        if ( !strncmp_I(bf->at,"HTTP/1.",7) )
          {
            char *q = bf->at + 8, *Q;
            bf->at[count] = 0;
            while ( *q && !Isspace(*q) ) ++q;
            while ( Isspace(*q) ) ++q;
            httpx->status = strtol(q,&q,10);
            
            if ( httpx->status < 100 || httpx->status >= 510 )
              return  httpx->state = HTTPX_INVALID_RESPONSE_CODE,
                      Httpx_Do_Callback(httpx,HTTPX_BROKEN),
                      httpx->state;
                          
            while ( *q != '\n' && *q != '\r' && Isspace(*q) ) ++q;
            Q = q;
            while ( *q && *q != '\n' && *q != '\r' && !Isspace(*q) ) ++q;
            httpx->status_text = Str_Range_Npl(Q,q);
            bf->count = (q - bf->at);         
            count -= bf->count; 
            httpx->nline = 0;
            __Unrefe(httpx->hdrs);
            httpx->hdrs = __Refe(Dicto_Ptrs());
          }
        else
          return  httpx->state = HTTPX_INVALID_RESPONSE,
                  Httpx_Do_Callback(httpx,HTTPX_BROKEN),
                  httpx->state;
      }
    else
      iterate = status&ASIO_SYNCHRONOUS;
      
    for(;;) 
      {
        int eoh = Httpx_Update_Until_EOH(httpx,count);

        if ( eoh )
          {
            char *foo;
            Httpx_Analyze_Headers(httpx);
            httpx->left = 0;
            
            if ( foo = Dicto_Get(httpx->hdrs,"Content-Length",0) )
              {
                httpx->left = Yo_Minu(Str_To_Int(foo),httpx->maxcount);
              }
            else if ( strcmp_I(Dicto_Get(httpx->hdrs,"Transfer-Encoding",""),"chunked") == 0 )
              {
                httpx->chunked = 1;  
                httpx->nline = 0;
              }
              
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
                    status = Httpx_Asio_Recv(httpx,bf->at,bf->capacity,Yo_MIN(httpx->left,bf->capacity)
                                            ,Cbk_Httpx_Getting_Content);
                    if ( status != HTTPX_CONTINUE )
                      return status;
                  }
              }
            else if ( httpx->chunked )
              {
                httpx->nline = eoh;
                httpx->left = 0;
                return Cbk_Http_Getting_Chunked(httpx,0,0);
              }
            
            return httpx->state = HTTPX_FINISHED,
                   Httpx_Do_Callback(httpx,0),
                   httpx->state;
          }
        
        if ( iterate )
           return HTTPX_CONTINUE;
           
        Buffer_Grow_Reserve(bf,bf->count + 512);
        
        status = Httpx_Asio_Recv(httpx, bf->at+bf->count, 512, 1
                                ,Cbk_Httpx_Getting_Headers);    

        if ( status != HTTPX_CONTINUE )
          return status;
      }
  }
#endif
  ;
  
int Cbk_Httpx_Requested(void *_httpx, int status)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;

    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;

    httpx->state = HTTPX_REQUESTED;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;

    Httpx_Do_Callback(httpx,HTTPX_REQUESTED);
    Buffer_Grow_Reserve(httpx->bf,1023);
    httpx->bf->count = 0;
    
    return Httpx_Asio_Recv(httpx, httpx->bf->at, 1023, 12 /* lengthof HTTP/1.1 200 */
                          ,Cbk_Httpx_Getting_Headers);    
  }
#endif
  ;
  
int Cbk_Httpx_Post(void *_httpx, int status)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;
    YOYO_BUFFER *bf = httpx->bf;
    int i;

    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;

    if ( httpx->state == HTTPX_SENDING_POSTDATA && (status & ASIO_SYNCHRONOUS) )
      return HTTPX_CONTINUE;

    if ( httpx->state != HTTPX_SENDING_POSTDATA )
      {
        bf->count = 0;
        httpx->left = httpx->poststrm?Oj_Available(httpx->poststrm):0;
      }

    httpx->state = HTTPX_SENDING_POSTDATA;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;
    
    for ( ;; )
      {
        bf->count = 0;
        i = !httpx->left ? 0 : Oj_Read(httpx->poststrm,bf->at,Yo_MIN(httpx->left,bf->capacity),-1);
        httpx->left -= i;
        if ( !Httpx_Asio_Send(httpx, bf->at, i,
                              httpx->left ? Cbk_Httpx_Post : Cbk_Httpx_Requested) )
        return 0;
      }
  }
#endif
  ;
    
int Cbk_Httpx_Connected(void *_httpx,int status)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;

    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;

    httpx->state = HTTPX_CONNECTED;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;

    Httpx_Do_Callback(httpx,HTTPX_CONNECTED);
    
    /* httpx->bf contains prepared request */
    return Httpx_Asio_Send(httpx, httpx->bf->at, httpx->bf->count,
                           (httpx->method == HTTPX_POST || httpx->method == HTTPX_PUT ) 
                                ?Cbk_Httpx_Post
                                :Cbk_Httpx_Requested);    
  }
#endif
  ;
  
int Cbk_Httpx_Proxy_Connected(void *_httpx,int status)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = _httpx;

    if ( status == ASIO_TIMER )
      return Httpx_Timer_Callback(httpx),0;
      
    httpx->state = HTTPX_PROXY_CONNECTED;
    if ( !ASIO_SUCCEEDED(status) )
      return Httpx_Do_Callback(httpx,HTTPX_BROKEN),
             httpx->state;

    Httpx_Do_Callback(httpx,HTTPX_PROXY_CONNECTED);
    
    /// auth / ssl connect
    return Cbk_Httpx_Connected(_httpx,status);
  }
#endif
  ;
  
int Httpx_Asio_Connect(YOYO_HTTPX *httpx)
#ifdef _HTTPX_BUILTIN
  {
    __Unrefe(httpx->netchnl);
    httpx->netchnl = __Refe(Tcp_Socket(httpx->async?TCPSOK_ASYNC:0));
    
    if ( httpx->proxy_url )
      return Tcp_Asio_Connect(httpx->netchnl,httpx->proxy_url->host,httpx->proxy_url->port,httpx,Cbk_Httpx_Proxy_Connected);
      
    return Tcp_Asio_Connect(httpx->netchnl,httpx->url->host,httpx->url->port,httpx,Cbk_Httpx_Connected);
  }
#endif
  ;
  
int Httpx_Query(YOYO_HTTPX *httpx, int method, char *uri, YOYO_DICTO *hdrs, void *poststrm, void *contstrm, int maxcount)
#ifdef _HTTPX_BUILTIN
  {
    if ( httpx->status_text ) { free(httpx->status_text); httpx->status_text = 0; }
    httpx->status = 0;
    httpx->method = method;
    httpx->maxcount = maxcount;
    httpx->streamed = 0;
    httpx->state = HTTPX_INITILIZED;
    httpx->outstrm = __Refe(contstrm);
    httpx->poststrm = __Refe(poststrm);
    if ( httpx->bf ) httpx->bf->count = 0;
    else httpx->bf = __Refe(Buffer_Init(0));
    Buffer_Reserve(httpx->bf,4*1024-1);
    Build_Http_Request(httpx,method,uri,hdrs);
    if ( 0 == Httpx_Asio_Connect(httpx) )
      return 1;
    else
      return httpx->state == HTTPX_FINISHED; 
  }
#endif
  ;
  
int Httpx_Head(YOYO_HTTPX *httpx, char *uri)
#ifdef _HTTPX_BUILTIN
  {
    return Httpx_Query(httpx,HTTPX_GET,uri,0,0,0,0);
  }
#endif
  ;
  
int Httpx_Get(YOYO_HTTPX *httpx, char *uri, YOYO_DICTO *params, void *contstrm, int maxcount)
#ifdef _HTTPX_BUILTIN
  {
    uri = Url_Compose(uri,params);
    return Httpx_Query(httpx,HTTPX_GET,uri,0,0,contstrm,maxcount);
  }
#endif
  ;
  
int Httpx_Post(YOYO_HTTPX *httpx, char *uri, YOYO_DICTO *params, void *contstrm, int maxcount)
#ifdef _HTTPX_BUILTIN
  {
    void *poststrm = 0;
    if ( params ) 
      {
        char *encoded = Url_Xform_Encode(params);
        if ( encoded )
          poststrm = Memory_As_File(encoded,strlen(encoded));
      }
    return Httpx_Query(httpx,HTTPX_GET,uri,0,poststrm,contstrm,maxcount);
  }
#endif
  ;

YOYO_HTTPX *Httpx_Client(char *url,int flags)
#ifdef _HTTPX_BUILTIN
  {
    YOYO_HTTPX *httpx = __Object_Dtor(sizeof(YOYO_HTTPX),YOYO_HTTPX_Destruct);
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
  
#endif /* C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC */

