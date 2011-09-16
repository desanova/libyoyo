
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

Thanks to Leoshkevich Ilya for his RSDN article http://www.rsdn.ru/article/baseserv/lpc.xml
It was very helpfull!

*/

#ifndef C_once_37ADA665_BE0A_456F_9491_3A81B3EB8980
#define C_once_37ADA665_BE0A_456F_9491_3A81B3EB8980

#include "yoyo.hc"
#ifdef __windoze

#ifdef _LIBYOYO
#define _YOYO_WINLPC_BUILTIN
#endif

#include "string.hc"
#include "winlpc.inc"

int Is_WOW64()
#ifdef _YOYO_WINLPC_BUILTIN
  {
    static int system_is = 0;
    if ( !system_is )
      {
        int (__stdcall *f_IsWow64Process)(HANDLE, int*) = 0;
        int is_wow64 = 0;
        f_IsWow64Process = (void *)GetProcAddress(GetModuleHandleA("kernel32.dll"),"IsWow64Process");
        if ( f_IsWow64Process && f_IsWow64Process( GetCurrentProcess(), &is_wow64 ) && is_wow64 ) 
          system_is = 64;
        else
          system_is = 32;
      }
    return system_is == 64;
  }
#endif
  ;
  
typedef struct _YOYO_LPCPORT
  {
    HANDLE handle;
    void  *tag;
    int    waitable;
  } YOYO_LPCPORT;

long Lpc_Create_Port(YOYO_LPCPORT *port, char *name, int waitable, int maxsize)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    OBJECT_ATTRIBUTES oa; 
    UNICODE_STRING us_name;
    wchar_t wname[256]; 
    
    memset(port,0,sizeof(*port));

    Str_Utf8_To_Unicode_Convert(name,wname,256);
    RtlInitUnicodeString(&us_name, wname);
    InitializeObjectAttributes(&oa, &us_name, 0, 0, 0);
    
    port->waitable = waitable;
    
    if ( waitable )
      ntst = NtCreateWaitablePort(&port->handle, &oa, 100, maxsize, 0);
    else
      ntst = NtCreatePort(&port->handle, &oa, 100, maxsize, 0);

    return ntst;
  }
#endif
  ;

long Lpc_Connect_Port(
  YOYO_LPCPORT *port, char *name, 
  LPC_SECTION_OWNER_MEMORY *clntmem, LPC_SECTION_MEMORY *servmem)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    UNICODE_STRING us_name;
    wchar_t wname[256];
    
    SECURITY_QUALITY_OF_SERVICE sqos = { 
        sizeof(SECURITY_QUALITY_OF_SERVICE), 
        SecurityImpersonation, 
        SECURITY_DYNAMIC_TRACKING, 
        TRUE };
    
    memset(port,0,sizeof(*port));
    
    Str_Utf8_To_Unicode_Convert(name,wname,256);
    RtlInitUnicodeString(&us_name, wname);
    
    ntst = NtConnectPort(&port->handle, &us_name, &sqos, clntmem, servmem, 0, 0, 0);
    return ntst;
  }
#endif
  ;
  
long Lpc_Accept_Port_(
  YOYO_LPCPORT *port, LPC_MESSAGE_HEADER *rpl, void *tag, int accept,
  LPC_SECTION_MEMORY *clntmem, LPC_SECTION_OWNER_MEMORY *servmem)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    memset(port,0,sizeof(*port));
    
    if ( Is_WOW64() )
      {
        struct { LPC_MESSAGE_HEADER64 Hdr; byte_t Data[256]; } rpl64  = {0};
        rpl64.Hdr.DataLength  = rpl->DataLength;
        rpl64.Hdr.TotalLength = sizeof(rpl64.Hdr) + rpl->DataLength;
        rpl64.Hdr.ProcessId   = rpl->ProcessId;
        rpl64.Hdr.ThreadId    = rpl->ThreadId;
        rpl64.Hdr.MessageId   = rpl->MessageId;
        rpl64.Hdr.CallbackId  = rpl->CallbackId;
        memcpy(rpl64.Data,rpl+1,rpl->DataLength);
        ntst = NtAcceptConnectPort(&port->handle, tag, (void*)&rpl64, accept, servmem, clntmem);
      }
    else
      ntst = NtAcceptConnectPort(&port->handle, tag, rpl, accept, servmem, clntmem);
    if ( !NT_SUCCESS(ntst) ) 
      return ntst;
    
    ntst = NtCompleteConnectPort(port->handle);
    return ntst;
  }
#endif
  ;
  
long Lpc_Accept_Port(
  YOYO_LPCPORT *port, LPC_MESSAGE_HEADER *msg, void *tag,
  LPC_SECTION_MEMORY *clntmem, LPC_SECTION_OWNER_MEMORY *servmem)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    ntst = Lpc_Accept_Port_(port,msg,tag,1,clntmem,servmem);
    port->tag = tag;
    return ntst;
  }
#endif
  ;
  
long Lpc_Refuse_Port(LPC_MESSAGE_HEADER *msg)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    YOYO_LPCPORT port;
    ntst = Lpc_Accept_Port_(&port,msg,0,0,0,0);
    if ( port.handle ) NtClose(port.handle);
    return ntst;
  }
#endif
  ;
  
long Lpc_Replay_Port(YOYO_LPCPORT *port, LPC_MESSAGE_HEADER *rpl)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    REQUIRE( port->handle != 0 );
    if ( Is_WOW64() )
      {
        struct { LPC_MESSAGE_HEADER64 Hdr; byte_t Data[256]; } rpl64  = {0};
        rpl64.Hdr.DataLength  = rpl->DataLength;
        rpl64.Hdr.TotalLength = sizeof(rpl64.Hdr) + rpl->DataLength;
        rpl64.Hdr.ProcessId   = rpl->ProcessId;
        rpl64.Hdr.ThreadId    = rpl->ThreadId;
        rpl64.Hdr.MessageId   = rpl->MessageId;
        rpl64.Hdr.CallbackId  = rpl->CallbackId;
        memcpy(rpl64.Data,rpl+1,rpl->DataLength);
        ntst = NtReplyPort(port->handle,(void*)&rpl64);
      }
    else
      ntst = NtReplyPort(port->handle,rpl);
    return ntst;
  }
#endif
  ;
  
long Lpc_Request_Port(YOYO_LPCPORT *port, LPC_MESSAGE_HEADER *rqst)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    REQUIRE( port->handle != 0 );
    if ( Is_WOW64() )
      {
        struct { LPC_MESSAGE_HEADER64 Hdr; byte_t Data[256]; } rqst64 = {0};
        rqst64.Hdr.DataLength  = rqst->DataLength;
        rqst64.Hdr.TotalLength = sizeof(rqst64.Hdr) + rqst->DataLength;
        memcpy(rqst64.Data,rqst+1,rqst->DataLength);
        ntst = NtRequestPort(port->handle,(void*)&rqst64);
      }
    else
      ntst = NtRequestPort(port->handle,rqst);
    return ntst;
  }
#endif
  ;

long Lpc_Reply_Wait_Receive_Port(YOYO_LPCPORT *port, LPC_MESSAGE_HEADER *rqst, void *ctx)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    if ( Is_WOW64() )
      {
        struct { LPC_MESSAGE_HEADER64 Hdr; byte_t Data[256]; } rqst64 = {0};
        ntst = NtReplyWaitReceivePort(port->handle, ctx, 0, (void*)&rqst64);
        rqst->DataLength     = rqst64.Hdr.DataLength;
        rqst->TotalLength    = sizeof(*rqst) + rqst->DataLength;
        rqst->MessageType    = rqst64.Hdr.MessageType;
        rqst->DataInfoOffset = 0;
        rqst->ProcessId      = rqst64.Hdr.ProcessId;
        rqst->ThreadId       = rqst64.Hdr.ThreadId;
        rqst->MessageId      = rqst64.Hdr.MessageId;
        rqst->CallbackId     = rqst64.Hdr.CallbackId;
        memcpy(rqst+1,rqst64.Data,rqst64.Hdr.DataLength);
      }
    else
      ntst = NtReplyWaitReceivePort(port->handle, ctx, 0, rqst);
    return ntst;
  }
#endif
  ;
  
long Lpc_Wait_Port(YOYO_LPCPORT *port, unsigned ms)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    if ( port->waitable )
      {
        long st;
        st = WaitForSingleObject(port->handle, ms);
        return st;
      }
    else
      return 0;
  }
#endif
  ;
  
long Lpc_Request_Wait_Reply_Port(YOYO_LPCPORT *port, LPC_MESSAGE_HEADER *rqst, LPC_MESSAGE_HEADER *rpl)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    long ntst;
    if ( Is_WOW64() )
      {
        struct { LPC_MESSAGE_HEADER64 Hdr; byte_t Data[256]; } rqst64 = {0};
        struct { LPC_MESSAGE_HEADER64 Hdr; byte_t Data[256]; } rpl64  = {0};
        rqst64.Hdr.DataLength  = rqst->DataLength;
        rqst64.Hdr.TotalLength = sizeof(rqst64.Hdr) + rqst->DataLength;
        memcpy(rqst64.Data,rqst+1,rqst->DataLength);
        ntst = NtRequestWaitReplyPort(port->handle, (void*)&rqst64, (void*)&rpl64);
        rpl->DataLength     = rpl64.Hdr.DataLength;
        rpl->TotalLength    = sizeof(*rpl) + rpl->DataLength;
        memcpy(rpl+1,rpl64.Data,rpl64.Hdr.DataLength);
      }
    else
      ntst = NtRequestWaitReplyPort(port->handle, rqst, rpl);
    return ntst;
  }
#endif
  ;

void Lpc_Close_Port(YOYO_LPCPORT *port)
#ifdef _YOYO_WINLPC_BUILTIN
  {
    if ( port && port->handle )
      {
        NtClose(port->handle);
        port->handle = 0;
      }
  }
#endif
  ;

#endif /* __windoze */
#endif /* C_once_37ADA665_BE0A_456F_9491_3A81B3EB8980 */


