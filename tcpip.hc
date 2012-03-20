
/*

Copyright © 2010-2011, Alexéy Sudachén, alexey@sudachen.name, Chile

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
#include "asio.hc"

#ifdef _LIBYOYO
#define _YOYO_TCPIP_BUILTIN
#endif

enum  
  {
    TCPSOK_ASYNC = 1,
  };

typedef uquad_t ipaddr_t; 

typedef struct _YOYO_TCPSOK
  {
    ipaddr_t  ip;
    int       skt;
    int       port;
    int       async: 1;
  } YOYO_TCPSOK;

#ifdef __windoze

void _WSA_Term(void)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    WSACleanup();
  }
#endif
  ;
  
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
          {
            wsa_status = 0;
            atexit(_WSA_Term);
          }
      }
  }
#endif
  ;

#else
#define _WSA_Init()
#endif


#define Ipv4_Format(Ip) __Pool(Ipv4_Format_Npl(Ip))
char *Ipv4_Format_Npl(ipaddr_t ip)
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
  
ipaddr_t Dns_Resolve(char *host)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    ipaddr_t ip = 0;
    struct hostent *hstn = 0;
    
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
  
void Tcp_Close(YOYO_TCPSOK *sok)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    if ( sok->skt != INVALID_SOCKET ) 
      {
#ifdef __windoze
        closesocket(sok->skt);
#else      
        close(sok->skt);
#endif
        sok->skt = -1;
      }
  }
#endif
  ;
  
void YOYO_TCPSOK_Destruct(YOYO_TCPSOK *sok)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    Tcp_Close(sok);
    __Destruct(sok);
  }
#endif
  ;
  
int Tcp_Read(YOYO_TCPSOK *sok, void *out, int count, int mincount)
#ifdef _YOYO_TCPIP_BUILTIN  
  {
    byte_t *b = out;
    int cc = count;
    while ( cc )
      {
        int q = recv(sok->skt,b,cc,0);
        if ( q < 0 )
          __Raise_Format(YOYO_ERROR_IO,("tcp recv failed with error %s",strerror(errno)));
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( count-cc >= mincount )
          break;
      }
    return count-cc;
  }
#endif
  ;

int Tcp_Asio_Recv(YOYO_TCPSOK *sok,void *out, int count, int mincount, void *obj, asio_recv_callback_t callback)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    if ( sok->async )
      return Asio_Recv(sok->skt,out,count,mincount,obj,callback);
    else
      {
        int cc = Tcp_Read(sok,out,count,mincount);
        if ( callback )
          return callback(obj,ASIO_COMPLETED|ASIO_SYNCHRONOUS,cc);
      }
    return 0;
  }
#endif
  ;

int Tcp_Write(YOYO_TCPSOK *sok, void *out, int count, int mincount)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    byte_t *b = out;
    int cc = count;
    while ( cc )
      {
        int q = send(sok->skt,b,cc,0);
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
  
int Tcp_Asio_Send(YOYO_TCPSOK *sok,void *out, int count, void *obj, asio_send_callback_t callback)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    if ( sok->async )
      return Asio_Send(sok->skt,out,count,obj,callback);
    else
      {
        int cc = Tcp_Write(sok,out,count,count);
        if ( callback )
          return callback(obj,ASIO_COMPLETED|ASIO_SYNCHRONOUS);
      }
    return 0;
  }
#endif
  ;
  
YOYO_TCPSOK *Tcp_Socket(int flags)
#ifdef _YOYO_TCPIP_BUILTIN  
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    YOYO_TCPSOK_Destruct},
        {Oj_Close_OjMID,       Tcp_Close},
        {Oj_Read_OjMID,        Tcp_Read},
        {Oj_Write_OjMID,       Tcp_Write},
        //{Oj_Available_OjMID,   Tcp_Available},
        //{Oj_Eof_OjMID,         Tcp_Eof},
        {0}
      };

    YOYO_TCPSOK *sok = __Object(sizeof(YOYO_TCPSOK),funcs);
    sok->skt = INVALID_SOCKET;
    if ( flags & TCPSOK_ASYNC ) sok->async = 1;
    return sok;
  }
#endif
  ;
  
void Tcp_Set_Async(socket_t skt)
  {
  #ifdef __windoze
    ulong_t nonblock = 1;
    ioctlsocket(skt, FIONBIO, &nonblock);
  #else       
    int arg = fcntl(skt,F_GETFL,0);
    arg |= O_NONBLOCK; 
    fcntl(skt,F_SETFL,arg); 
  #endif
  }
  
#define Tcp_IPv4_Connect(Sok,Ip,Port) Tcp_Asio_IPv4_Connet(Sok,Ip,Port,0,0)
int Tcp_Asio_IPv4_Connect(YOYO_TCPSOK *sok, ipaddr_t ip, int port, void *obj, asio_notify_callback_t callback)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    struct sockaddr_in addr = {0}; 
    socket_t skt;
    int conerr;
    
    _WSA_Init();
    
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(port);
    addr.sin_addr.s_addr = (ulong_t)ip;
    
    sok->port = port;
    sok->ip = ip;
    
    skt = socket(PF_INET,SOCK_STREAM,IPPROTO_TCP);
    sok->skt = skt;

    if ( skt != INVALID_SOCKET && sok->async )
      Tcp_Set_Async(skt);
          
    conerr = (skt != INVALID_SOCKET ) ? connect(skt,(struct sockaddr*)&addr,sizeof(addr)) : -1;
    
    if ( conerr < 0 )
      {
        if ( skt != INVALID_SOCKET && sok->async && Asio_Status_Repeat_Or_Die() == ASIO_PENGING && callback )
          {
            return Asio_Notify(skt,obj,callback);
          }
        else
          __Raise_Format(YOYO_ERROR_IO,
                          (__yoTa("tcp connection failed: sok %d, point %s:%d, error %d",0)
                          ,skt
                          ,Ipv4_Format(ip)
                          ,port
                          ,conerr));
      }
      
    if ( callback ) 
      return callback(obj,ASIO_COMPLETED|(sok->async?ASIO_SYNCHRONOUS:0));
    return 0;
  }
#endif
  ;

#define Tcp_Connect(Sok,Host,Port) Tcp_Asio_Connect(Sok,Host,Port,0,0)
int Tcp_Asio_Connect(YOYO_TCPSOK *sok,char *host,int port,void *obj,asio_notify_callback_t callback)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    ipaddr_t ip = Dns_Resolve(host);
    return Tcp_Asio_IPv4_Connect(sok,ip,port,obj,callback);    
  }
#endif
  ;

YOYO_TCPSOK *Tcp_Open(char *host, int port)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    YOYO_TCPSOK *sok = Tcp_Socket(0);
    Tcp_Connect(sok,host,port);
    return sok;
  }
#endif
  ;

void Tcp_Asio_Interrupt(YOYO_TCPSOK *sok)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    Asio_Interrupt(sok->skt);
  }
#endif
  ;

YOYO_TCPSOK *Tcp_Listen(int flags, char *host,int port,int listlen)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    YOYO_TCPSOK *sok;
    struct sockaddr_in addr = {0}; 
    ipaddr_t ip;
    
    _WSA_Init();
    
    ip = host?Dns_Resolve(host):0;

    addr.sin_family = AF_INET;
    addr.sin_port   = htons(port);
    addr.sin_addr.s_addr = (ulong_t)ip;
    
    sok = __Refe(Tcp_Socket(0));
    sok->port = port;
    sok->ip = ip;
    
    if ( INVALID_SOCKET == (sok->skt = socket(PF_INET,SOCK_STREAM,IPPROTO_TCP)) )  goto sok_error;
    if ( -1 == bind(sok->skt,(struct sockaddr*)&addr,sizeof(addr)) ) goto sok_error;
    if ( -1 == listen(sok->skt,(listlen?listlen:SOMAXCONN)) ) goto sok_error;

    if ( sok->skt == INVALID_SOCKET )
      {       
    sok_error: 
        __Raise_Format(YOYO_ERROR_IO,
                        (__yoTa("tcp bind/listen failed: sok %d, point %s:%d, error %s",0)
                        ,sok->skt
                        ,Ipv4_Format(ip)
                        ,port
                        ,Format_Network_Error()));
      }
    else if ( flags & TCPSOK_ASYNC )
      Tcp_Set_Async(sok->skt);
      
    return sok;
  }
#endif
  ;

typedef int (*tcp_accept_callback_t)(void *obj,int status,YOYO_TCPSOK *sok);

#ifdef _YOYO_TCPIP_BUILTIN
typedef struct _YOYO_TCPSOK_ACCEPT
  {
    void *obj;
    tcp_accept_callback_t callback;
  } YOYO_TCPSOK_ACCEPT;

void YOYO_TCPSOK_ACCEPT_Destruct(YOYO_TCPSOK_ACCEPT *acbk)
  {
    __Unrefe(acbk->obj);
    __Destruct(acbk);
  }

YOYO_TCPSOK_ACCEPT *Tcp_Accept_Callback(void *obj,tcp_accept_callback_t callback)
  {
    YOYO_TCPSOK_ACCEPT *acbk = __Object_Dtor(sizeof(YOYO_TCPSOK_ACCEPT),YOYO_TCPSOK_ACCEPT_Destruct);
    acbk->callback = callback;
    acbk->obj = __Refe(obj);
    return acbk;
  }

int Cbk_Tcp_Asio_Accept(void *obj, int status, socket_t skt, struct sockaddr *_addr)
  {
    struct sockaddr_in *addr = ((struct sockaddr_in*)_addr);
    YOYO_TCPSOK *sok = Tcp_Socket( (status&ASIO_SYNCHRONOUS)?0:TCPSOK_ASYNC );
    sok->ip = addr->sin_addr.s_addr;
    sok->port = addr->sin_port;
    sok->skt = skt;
    if ( sok->async )
      Tcp_Set_Async(sok->skt);
    return ((YOYO_TCPSOK_ACCEPT*)obj)->callback(((YOYO_TCPSOK_ACCEPT*)obj)->obj,status,sok);
  }
#endif

int Tcp_Asio_Accept(YOYO_TCPSOK *sok, void *obj, tcp_accept_callback_t callback)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    return Asio_Accept(sok->skt,Tcp_Accept_Callback(obj,callback),Cbk_Tcp_Asio_Accept);
  }
#endif
  ;

void Tcp_Asio_Shutdown(YOYO_TCPSOK *sok)
#ifdef _YOYO_TCPIP_BUILTIN
  {
    if ( sok->async )
      {
        socket_t skt = sok->skt;
        if ( skt != INVALID_SOCKET )
          {
            sok->skt = -1;
            /*fixme*/ //Asio_Shutdown(skt);
          }
      }
    else
      {
        shutdown(sok->skt,SB_BOTH);
        Tcp_Close(sok);
      }
  }
#endif
  ;

#endif /* C_once_F8F16072_F92E_49E7_A983_54F60965F4C9 */

