
/*

Copyright © 2010-2011, Alexéy Sudáchen, alexey@sudachen.name, Chile

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

#ifndef C_once_F8F16072_F92E_49E7_A983_54F60965F4C9
#define C_once_F8F16072_F92E_49E7_A983_54F60965F4C9

#include "yoyo.hc"
#include "string.hc"
#include "file.hc"

#ifdef _LIBYOYO
#define _YOYO_TCPIP_BUILTIN
#endif

typedef struct _YOYO_SOCKET
  {
    int       skt;
    char     *host;
    int       port;
    in_addr_t ip;
  } YOYO_SOCKET

#ifdef __windoze
void _WSA_Init()
#ifdef _YOYO_TCPIP_BUILTIN
  {
    static int wsa_status = -1;
    static WSADATA wsa_data = {0};
    if ( wsa_status != 0 )
      {
        if ( 0 != WSAStartup(MAKEWORD(2, 2), &wsa_data) )
          __Raise(YOYO_ERROR_SUBSYSTEM_INIT,"failed to initialize WSA subsystem");
        else
          wsa_status = 0;
      }
    return true;
  }
#endif
  ;
#else
#define _WSA_Init()
#endif


#define Ipv4_Format(Ip) __Pool(Ipv4_Format_Npl(Ip))
char *Ipv4_Format_Npl(in_addr_t ip)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    return __Format_Npl("%d.%d.%d.%d"
              ,(ip&0x0ff)
              ,((ip>>8)&0x0ff)
              ,((ip>>16)&0x0ff)
              ,((ip>>24)&0x0ff));
  }
#endif
  ;
  
in_addr_t Dns_Resolve(char *host)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    in_addr_t ip;
    hostent *hstn = 0;
    
    _WSA_Init();
    if ( !strcmp_I(host,"localhost") ) return 0x0100007f;
    ip = inet_addr(host);
    if ( ip != 0x0ffffffff ) return ip;
  l:
    if ( hstn = gethostbyname(host) )
      {
        memcpy(&ip,hstn->h_addr,Yo_MAX(sizeof(ip),hstn->h_length));
        return ip;
      }
    else
      {
        if ( h_errno == TRY_AGAIN )
          goto l;
        else if ( h_errno == NO_RECOVERY )
          __Raise(YOYO_ERROR_DNS,"unrecoverable DNS error");
        else //( h_errno == HOST_NOT_FOUND ) 
          __Raise_Format(YOYO_ERROR_DNS,("DNS couldn't resolve ip for name %s",host));
      }
    return 0;
  }        
#endif
  ;
  
void Socket_Close(YOYO_SOCKET *sok)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    if ( sok->skt >= 0 ) 
      {
        close(sok->skt);
        sok->skt = -1;
      }
  }
#endif
  ;
  
void YOYO_SOCKET_Destruct(YOYO_SOCKET *sok)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    Socket_Close(sok);
    free(sok->host);
    __Detruct(sok);
  }
#endif
  ;
  
int Socket_Read(YOYO_SOCKET *sok, void *out, int count, int mincount)
#ifdef _YOYO_TCPIP_BUILTIN  
  {
    byte_t *b = out;
    int cc = count;
    while ( cc )
      {
        int q = recv(skt,b,cc,0);
        if ( q < 0 )
          __Raise_Format(YOYO_ERROR_IO,("tcp recv failed with error %s",strerror(errno)));
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( q == 0 && count-cc >= mincount )
          break;
      }
    return count-cc;
  }
#endif
  ;
  
int Socket_Write(YOYO_SOCKET *sok, void *out, int count, int mincount)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    byte_t *b = out;
    int cc = count;
    while ( cc )
      {
        int q = send(skt,b,cc,0);
        if ( q < 0 )
          __Raise_Format(YOYO_ERROR_IO,("tcp send failed with error %s",strerror(errno)));
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( q == 0 && count-cc >= mincount )
          break;
      }
    return count-cc;
  }
#endif
  ;
  
YOYO_SOCKET *Socket_Init(in_addr_t ip, int port, int skt, char *hostname)
#ifdef _YOYO_TCPIP_BUILTIN  
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    YOYO_SOCKET_Destruct},
        {Oj_Close_OjMID,       Socket_Close},
        {Oj_Read_OjMID,        Socket_Read},
        {Oj_Write_OjMID,       Socket_Write},
        //{Oj_Available_OjMID,   Socket_Available},
        //{Oj_Eof_OjMID,         Socket_Eof},
        {0}
      };

    YOYO_SOCKET *sok = __Object(sizeof(YOYO_SOCKET),funcs);
    sok->skt = skt;
    sok->port = port;
    sok->ip = ip;
    sok->host = hostname ? Str_Copy_Npl(hostname,-1) : Ipv4_Format_Npl(ip);
  }
#endif
  ;
  
YOYO_TCPSOKET *Socket_Open_Inaddr(in_addr_t ip, int port, char *hostname)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    YOYO_TCPSOKET *sok;
    
    sockaddr_in addr = {0}; 
    int skt, conerr;
    
    _WSA_Init();
    
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(port);
    addr.sin_addr.s_addr = ip;
    
    skt = socket(PF_INET,SOCK_STREAM,IPPROTO_TCP);
    conerr = 0;
    
    if ( skt < 0 || ( conerr = connect(skt,(sockaddr*)&addr,sizeof(addr)) ) < 0 )
        __Raise_Format(YOYO_ERROR_IO,("tcp connection failed: sok %d, point (%s -> %s):%d, error %d"
                          ,skt
                          ,hostname?hostname:Ipv4_Fomat(ip)
                          ,Ipv4_Fomat(ip)
                          ,port
                          ,conerr));

    sok = Socket_Init(skt,ip,port,hostname);
    return sok;
  }
#endif
  ;
  
YOYO_TCPSOKET *Socket_Open(char *host, int port)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    in_addr_t ip = Dns_Resolve(host);
    YOYO_TCPSOKET *sok = Soket_Open_Inaddr(ip,port,hotname);
    return sok;
  }
#endif
  ;
  
#endif /* C_once_F8F16072_F92E_49E7_A983_54F60965F4C9 */

