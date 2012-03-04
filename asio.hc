
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

#ifndef C_once_5F140392_CCAA_4FE1_88CB_DC84EE3B25A0
#define C_once_5F140392_CCAA_4FE1_88CB_DC84EE3B25A0

#ifdef _LIBYOYO
#define _YOYO_ASIO_BUILTIN
#endif

#include "yoyo.hc"

#ifdef __windoze
  #include <winsock.h>
  typedef SOCKET socket_t;
#else
  #include <errno.h>
  #include <sys/types.h>
  #include <sys/socket.h>
  #include <netdb.h>
  #include <netinet/in.h>
  #include <arpa/inet.h>
  typedef int socket_t;
#endif

enum  
  {
    ASIO_COMPLETED    = 0x00000001,
    ASIO_CLOSED       = 0x00000002,
    ASIO_SYNCHRONOUSE = 0x00200000,
    ASIO_TIMER        = 0x00100000,
    ASIO_FAILED       = 0x8e000000,
    ASIO_INTERRAPTED  = 0x8f000000,
    ASIO_PENGING      = 0,
    ASIO_CONTINUE     = 0,
  
    ASIO_ST_SEND      = 1,
    ASIO_ST_RECV      = 2,
    ASIO_ST_NOTIFY    = 3,
    ASIO_ST_ACCEPT    = 4,
    
    ASIO_MAP_BASE     = 101,
  };
  
#define ASIO_SUCCEEDED(State) (!((State)&0xff000000))

int (asio_recv_callback_t)(void *obj,int status,int count);
int (asio_send_callback_t)(void *obj,int status,int count);
int (asio_accept_callback_t)(void *obj,int status,socket_t fd,struct sockaddr *addr);
int (asio_notify_callback_t)(void *obj,int status);
int (asio_any_callback_t)(void *obj,int status,...);

typedef struct _YOYO_ASIO_STATE
  {
    socket_t fd;
    longptr_t accum;
    int fdsno,count,mincount;
    struct sockaddr addr;
    void *obj, *dta;
    asio_any_callback_t cbk;
    int (*perform)(struct _YOYO_ASIO_STATE *st);
    YOYO_ASIO_STATE *next;
  } YOYO_ASIO_STATE;

#ifdef _YOYO_ASIO_BUILTIN
static int Asio_St_Count = 0;
static YOYO_ASIO_STATE *Asio_St_Map[ASIO_MAP_BASE] = {0};
static YOYO_ASIO_STATE *Asio_St_Pool = 0;
static int Asio_Is_Init = 0;
#endif
  ;
  
YOYO_ASIO_STATE **Asio_Map_Fd(socket_t fd)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE **st = Asio_St_Map[fd/ASIO_MAP_BASE];
    while ( *st && (*st)->fd != fd ) st = &(*st)->next;
    return st;
  }
#endif
  ;
  
YOYO_ASIO_STATE *Asio_Pool_Get_State()
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st = Asio_St_Pool;
    if ( !Asio_St_Pool )
      {
        Asio_St_Pool = __Malloc_Npl(sizeof(YOYO_ASIO_STATE));
        st = Asio_St_Pool;
      }
    Asio_St_Pool = Asio_St_Pool->next;
    memset(st,0,sizeof(YOYO_ASIO_STATE));
    return st;
  }
#endif
  ;
  
void Asio_Release_State(YOYO_ASIO_STATE **pst)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st = *pst;
    *pst = st->next;
    st->next = Asio_St_Pool;
    Asio_St_Pool = st;
    --Asio_St_Count;
  }
#endif
  ;
  
int Asio_Status_Repeat_Or_Die()
#ifdef _YOYO_ASIO_BUILTIN
  {
  #ifdef __windoze
    int e = WSAGetLastError();
    if ( WSAEWOULDBLOCK == e || WSAEINPROGRESS == e )
  #else
    if ( EWOULDBLOCK == errno || EINPROGRESS == errno )
  #endif
      return ASIO_PENGING;
    return ASIO_FAILED;
  }
#endif
  ;
  
int Asio_Do_Accept(YOYO_ASIO_STATE *st)
#ifdef _YOYO_ASIO_BUILTIN
  {
    int len = sizeof(st->addr);
    int e = accept(st->fd,&st->addr,&len);
    if ( e < 0 ) 
      return Asio_Status_Repeat_Or_Die()
    st->accum = e;
    return ASIO_COMPLETED;
  }
#endif  
  ;
  
int Asio_Do_Recv(YOYO_ASIO_STATE *st)
#ifdef _YOYO_ASIO_BUILTIN
  {
    int e = recv(st->fd,(char*)st->dta+st->accum,st->count-st->accum,0);
    if ( e < 0 || (!e && st->accum < st->mincount) )
      return Asio_Status_Repeat_Or_Die()
    if ( !e && st->count )
      return ASIO_CLOSED;
    st->accum += e;
    return st->accum >= st->mincount ? ASIO_COMPLETED : ASIO_PENGING;  
  }
#endif
  ;
  
int Asio_Do_Send(YOYO_ASIO_STATE *st)
#ifdef _YOYO_ASIO_BUILTIN
  {
    int e = send(st->fd,(char*)st->dta+st->accum,st->count-st->accum,0);
    if ( e <= 0 ) 
      return Asio_Status_Repeat_Or_Die()
    st->accum += e;
    return st->accum >= st->mincount ? ASIO_COMPLETED : ASIO_PENGING;  
  }
#endif
  ;
  
void Asio_Perform_Interrupt()
#ifdef _YOYO_ASIO_BUILTIN
  {
    int i;
    for ( i = 0; i < ASIO_MAP_BASE; ++i )
      {
        YOYO_ASIO_STATE *pst = &Asio_St_Map[i];
        while ( *pst )
          {
            __Auto_Release
              {
                YOYO_ASIO_STATE st = **pst;
                void *obj = __Pool_Ptr(st.obj,Yo_Unrefe);
                Asio_Release_State(pst);
                
                if ( st.cbk ) 
                  st.cbk(obj,status,st.accum,&st.addr);
              }
          }
      }
  }
#endif
  ;
  
void Asio_At_Exit()
#ifdef _YOYO_ASIO_BUILTIN
  {
    Asio_Perform_Interrupt();
    while ( Asio_St_Pool ) 
      {
        YOYO_ASIO_STATE * st = Asio_St_Pool;
        Asio_St_Pool = st->next;
        free(st);
      }
  }
#endif
  ;
  
YOYO_ASIO_STATE *Asio_Alloc_State(socket_t fd, int tag)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st;
    YOYO_ASIO_STATE **pst = Asio_Map_Fd(fd);
    
    if ( !Asio_Is_Init )
      {
        atexit(Asio_At_Exit);
      }
    
    if ( *pst ) 
      __Raise_Format(YOYO_ERROR_ALREADY_EXISTS,(__yoTa("ASIO duplicate descriptor: %d",0),fd));
    *pst = st = Asio_Pool_Get_State();

    switch ( tag )
      {
        case ASIO_ST_RECV:
          st->perform = Asio_Do_Recv; 
          break;
        case ASIO_ST_ACCEPT:
          st->perform = Asio_Do_Accept; 
          break;
        case ASIO_ST_SEND:    
          st->fdsno = 1; 
          st->perform = Asio_Do_Send; 
          break;
        case ASIO_ST_NOTIFY:  
          break;
      }
      
    ++Asio_St_Count;
    return st;
  }
#endif
  ;
  
void Asio_Complete(socket_t fd, int failed)
#ifdef _YOYO_ASIO_BUILTIN
  {
    __Auto_Release
      {
        YOYO_ASIO_STATE **pst = Asio_Map_Fd(fd);
        if ( *pst )
          {
            int status = failed ? ASIO_FAILED 
                         : (*pst)->perform ? (*pst)->perform(*pst) 
                         : ASIO_COMPLETED;
            
            if ( status != ASIO_PENGING )
              {
                YOYO_ASIO_STATE st = **pst;
                void *obj     = __Pool_Ptr(st.obj,Yo_Unrefe);
                Asio_Release_State(pst);
                if ( st.cbk ) st.cbk(obj,status,st.accum);
              }
          }
      } 
  }
#endif
  ;
  
int Asio_Recv(socket_t fd, void *dta, int count, int mincount, void *obj, asio_recv_callback_t callback)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st = Asio_Alloc_State(fd,ASIO_ST_RECV);
    st->obj      = __Refe(obj);
    st->cbk      = (asio_any_callback_t)callback;
    st->count    = count;
    st->mincount = mincount;
    st->dta      = dta;
  }
#endif
  ;
    
int Asio_Send(socket_t fd, void *dta, int count, void *obj, asio_send_callback_t callback)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st = Asio_Alloc_State(fd,ASIO_ST_SEND);
    st->obj      = __Refe(obj);
    st->cbk      = (asio_any_callback_t)callback;
    st->count    = count;
    st->mincount = count;
    st->dta      = dta;
  }
#endif
  ;
    
int Asio_Notify(socket_t fd, void *obj, asio_notify_callback_t callback)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st = Asio_Alloc_State(fd,ASIO_ST_NOTIFY);
    st->obj      = __Refe(obj);
    st->cbk      = (asio_any_callback_t)callback;
  }
#endif
  ;
  
int Asio_Accept(socket_t fd, char *host, int port, void *obj, asio_accept_callback_t callback)
#ifdef _YOYO_ASIO_BUILTIN
  {
    YOYO_ASIO_STATE *st = Asio_Alloc_State(fd,ASIO_ST_ACCEPT);
    st->obj      = __Refe(obj);
    st->cbk      = (asio_any_callback_t)callback;
  }
#endif
  ;
  
int Asio_Perform_IO(int ms, int maxms)
#ifdef _YOYO_ASIO_BUILTIN
  {
    int i,j;
    timeval timeout = { ms/1000, ms*1000 };
    quad_t start    = maxms?System_Millis():0;

  #ifdef __windoze

    fd_set fds[3] = { {0, {-1}}, {0, {-1}}, {0, {-1}} };
    for ( i = 0; i < ASIO_MAP_BASE; ++i )
      {
        YOYO_ASIO_STATE *st = Asio_St_Map[i];
        while ( st )
          {
            fd_set *q = fds[st->fdsno];
            if ( fds[2].fd_count < FD_SETSIZE )
              {
                q->fd_array[q->fd_count] = st->fd;
                ++q->fd_count; 
                fds[2].fd_array[fds[2].fd_count] = st->fd;
                ++fds[2].fd_count; 
              }
            else break;
            st = st->next;
          }
      }
    
    i = select(Yo_MIN(FD_SETSIZE,Asio_St_Count),&fds[0],&fds[1],&fds[2],&timeout);

    if ( i < 0 )
      __Raise_Format(YOYO_ERROR_IO,(__yoTa("ASIO select failed: %d",0),i));

    for ( i = 2; i >= 0; --i )
      for ( j = 0; j < fds[i].fd_count; ++j )
        {
          Asio_Complete(fds[i].fd_array[j],i==2);
          if ( maxms && ( maxms < (System_Millis() - start) ) )
            goto l;
        }

  #else
  #error "not implemented!"
  #endif

  l:      
    return Asio_St_Count;
  }
#endif
  ;
  
int Asio_Perform_Timer(int interval)
#ifdef _YOYO_ASIO_BUILTIN
  {
  }
#endif
  ;
  
#endif /* C_once_5F140392_CCAA_4FE1_88CB_DC84EE3B25A0 */

