
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

#ifndef C_once_36F09FA7_8AEC_4584_91B3_D25C37490B80
#define C_once_36F09FA7_8AEC_4584_91B3_D25C37490B80

#include "yoyo.hc"
#include "string.hc"

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
    char *host, *user, *passw, *query, *args, *anchor, *uri, *endpoint;
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
    free(url->endpoint);
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
    return URLX_UNKNOWN;
  }
#endif
  ;
  
#define Url_Parse(Url) Url_Parse_(Url,0)
#define Url_Parse_Uri(Url) Url_Parse_(Url,1)
YOYO_URL *Url_Parse_(char *url,int uri_only)
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
        char *endpoint = 0;
        int   port  = 0;
        
        while ( *pS && Isspace(*pS) ) ++pS;
        
        if ( !uri_only )
          {
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

        if ( proto )        
          {
            Str_Cat(&endpoint,proto,-1);
            Str_Cat(&endpoint,"://",3);
          }
        
        if ( host )
          {
            Str_Cat(&endpoint,host,-1);
            if ( port )
              {
                char S[13];
                sprintf(S,":%u",port);
                Str_Cat(&endpoint,S,-1);
              }
          }
          
        urlout->endpoint = __Retain(endpoint);
      }
      
    return urlout;
  }
#endif
  ;

typedef struct _YOYO_URL_COMPOSER
  {
    char *S;
    int  capacity;
  } YOYO_URL_COMPOSER;

void Url_Compose_Dicto_Fitler(char *name, void *val, void *o)
  {
    char **inout  = &((YOYO_URL_COMPOSER*)o)->S;
    int *capacity = &((YOYO_URL_COMPOSER*)o)->capacity;
    int count     = *inout?strlen(*inout):0;
    count += __Elm_Append(inout,count,"&",1,1,capacity);
    count += __Elm_Append(inout,count,name,strlen(name),1,capacity);
    if ( val )
      {
        int i, iE = strlen(val);
        char C[4];
        count += __Elm_Append(inout,count,"=",1,1,capacity);
        for ( i = 0; i < iE; ++i )
          {
            byte_t b = ((char*)val)[i];
            if ( Isalnum(b) || b == '-' || b == '.' || b == '_' || b == '%' )
              count += __Elm_Append(inout,count,&b,1,1,capacity);
            else
              {
                Str_Hex_Byte(b,'%',C);
                count += __Elm_Append(inout,count,C,3,1,capacity);
              }
          }
      }
  }

char *Url_Compose(char *url, YOYO_DICTO *params)
#ifdef _YOYO_URL_BUILTIN
  {
    YOYO_URL_COMPOSER cmps = { 0, 0 };
    int i, q = __Elm_Append(&cmps.S,0,url,strlen(url),1,&cmps.capacity);
    
    for ( i = 0; i < q ; ++i )
      if ( cmps.S[i] == '?' ) break;
    if ( i == q ) i = -1;
    
    if ( params )
      {
        Dicto_Apply(params,Url_Compose_Dicto_Fitler,&cmps);
        
        if ( !i && cmps.S[q] ) 
          {
            STRICT_REQUIRE(cmps.S[q] == '&');
            cmps.S[q] = '?';
          }
      }
        
    return cmps.S;
  }
#endif
  ;
  
char *Url_Xform_Encode(YOYO_DICTO *params)
#ifdef _YOYO_URL_BUILTIN
  {
    if ( params )
      {
        YOYO_URL_COMPOSER cmps = { 0, 0 };
        Dicto_Apply(params,Url_Compose_Dicto_Fitler,&cmps);
        
        if ( cmps.S && cmps.S[0] ) 
          {
            STRICT_REQUIRE(cmps.S[0] == '&');
            cmps.S[0] = '?';
          }
          
        return cmps.S;
      }
    return 0;
  }
#endif
  ;

#endif /*C_once_36F09FA7_8AEC_4584_91B3_D25C37490B80*/

