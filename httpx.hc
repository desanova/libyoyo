
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
#include "bio.hc"
//#include "ssl.hc"

#ifdef _LIBYOYO
#define _YOYO_HTTPX_BUILTIN
#endif

enum
  {
    YOYO_HTTPX_DOING_NOTHING      = 0,
    YOYO_HTTPX_IS_PREPARING       = 1,
    YOYO_HTTPX_IS_RESOLVING       = 2,
    YOYO_HTTPX_IS_CONNECTING      = 3,
    YOYO_HTTPX_IS_QUERYING        = 4,
    YOYO_HTTPX_IS_GETTING_STATUS  = 5,
    YOYO_HTTPX_IS_GETTING_HEADERS = 6,
    YOYO_HTTPX_IS_GETTING_CONTENT = 7,
    YOYO_HTTPX_IS_FINISHED        = 8,
    YOYO_HTTPX_IS_FAILED          = 9,
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

typedef struct _YOYO_URL 
  {
    char *host, *user, *passw, *query, *args, *anchor, *uri;
    int   port, proto;
  } YOYO_URL;

void YOYO_URL_Destruct(YOYO_URL *url)
#ifdef _YOYO_HTTPX_BUILTIN
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
#ifdef _YOYO_HTTPX_BUILTIN
  {
    if ( !strcmp_I(S,"http")  )  return YOYO_URL_HTTP;
    if ( !strcmp_I(S,"https") )  return YOYO_URL_HTTPS;
    if ( !strcmp_I(S,"file")  )  return YOYO_URL_FILE;
    return YOYO_URL_UNKNOWN;
  }
#endif
  ;
  
YOYO_URL *Parse_Url(char *url)
#ifdef _YOYO_HTTPX_BUILTIN
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

