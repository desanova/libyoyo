
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

#ifndef C_once_8EC340EB_8D45_4EA4_A54E_50B89260408C
#define C_once_8EC340EB_8D45_4EA4_A54E_50B89260408C

#include "xntdef.inc"

enum
  {
    LPC_REQUEST                 = 1,
    LPC_REPLY                   = 2,
    LPC_DATAGRAM                = 3,
    LPC_LOST_REPLY              = 4,
    LPC_PORT_CLOSED             = 5,
    LPC_CLIENT_DIED             = 6,
    LPC_EXCEPTION               = 7,
    LPC_DEBUG_EVENT             = 8,
    LPC_ERROR_EVENT             = 9,
    LPC_CONNECTION_REQUEST      = 10,
    LPC_CONNECTION_REFUSED      = 11,
  };

typedef struct _LPC_MESSAGE_HEADER32
  {
    USHORT                  DataLength;
    USHORT                  TotalLength;
    USHORT                  MessageType;
    USHORT                  DataInfoOffset;
    ULONG                   ProcessId;
    ULONG                   ThreadId;
    ULONG                   MessageId;
    ULONG                   CallbackId;
  } LPC_MESSAGE_HEADER32, *PLPC_MESSAGE_HEADER32;

typedef struct _LPC_MESSAGE_HEADER64
  {
    USHORT                  DataLength;
    USHORT                  TotalLength;
    USHORT                  MessageType;
    USHORT                  DataInfoOffset;
    ULONGLONG               ProcessId;
    ULONGLONG               ThreadId;
    ULONGLONG               MessageId;
    ULONGLONG               CallbackId;
  } LPC_MESSAGE_HEADER64, *PLPC_MESSAGE_HEADER64;

typedef LPC_MESSAGE_HEADER32 LPC_MESSAGE_HEADER;
typedef LPC_MESSAGE_HEADER32 *PLPC_MESSAGE_HEADER;

typedef struct _LPC_TERMINATION_MESSAGE
  {
    LPC_MESSAGE_HEADER      Header;
    LARGE_INTEGER           CreationTime;
  } LPC_TERMINATION_MESSAGE, *PLPC_TERMINATION_MESSAGE;

typedef struct _LPC_SECTION_MEMORY
  {
    ULONG                   Length;
    ULONG                   ViewSize;
    PVOID                   ViewBase;
  } LPC_SECTION_MEMORY, *PLPC_SECTION_MEMORY;

typedef struct _LPC_SECTION_OWNER_MEMORY
  {
    ULONG                   Length;
    HANDLE                  SectionHandle;
    ULONG                   OffsetInSection;
    ULONG                   ViewSize;
    PVOID                   ViewBase;
    PVOID                   OtherSideViewBase;
  } LPC_SECTION_OWNER_MEMORY, *PLPC_SECTION_OWNER_MEMORY;

typedef enum _PORT_INFORMATION_CLASS
  {
    PortNoInformation
  } PORT_INFORMATION_CLASS, *PPORT_INFORMATION_CLASS;

long __stdcall NtCreatePort(
    HANDLE              *PortHandle,
    OBJECT_ATTRIBUTES   *ObjectAttributes,
    ULONG                MaxConnectInfoLength,
    ULONG                MaxDataLength,
    ULONG                MaxPoolUsage
    );

long __stdcall NtCreateWaitablePort(
    HANDLE              *PortHandle,
    OBJECT_ATTRIBUTES   *ObjectAttributes,
    ULONG                MaxConnectInfoLength,
    ULONG                MaxDataLength,
    ULONG                MaxPoolUsage
    );

long __stdcall NtListenPort(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *ConnectionRequest
    );

long __stdcall NtAcceptConnectPort(
    HANDLE                   *ServerPortHandle,
    VOID                     *PortContext,
    LPC_MESSAGE_HEADER       *ConnectionMsg,
    BOOLEAN                   AcceptConnection,
    LPC_SECTION_OWNER_MEMORY *ServerSharedMemory,
    LPC_SECTION_MEMORY       *ClientSharedMemory
    );

long __stdcall NtCompleteConnectPort(HANDLE PortHandle);

long __stdcall NtReplyWaitReceivePort(
    HANDLE               PortHandle,
    VOID               **PortContext,
    LPC_MESSAGE_HEADER  *Reply,
    LPC_MESSAGE_HEADER  *IncomingRequest
    );

long __stdcall NtReplyWaitReplyPort(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Reply
    );

long __stdcall NtRequestPort(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Request
    );

long __stdcall NtRequestWaitReplyPort(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Request,
    LPC_MESSAGE_HEADER  *IncomingReply
    );

long __stdcall NtWriteRequestData(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Request,
    ULONG                DataIndex,
    VOID                *Buffer,
    ULONG                Length,
    ULONG               *ResultLength
    );

long __stdcall NtReadRequestData(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Request,
    ULONG                DataIndex,
    VOID                *Buffer,
    ULONG                Length,
    ULONG               *ResultLength
    );

long __stdcall NtReplyPort(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Reply
    );

long __stdcall NtQueryInformationPort(
    HANDLE                 PortHandle,
    PORT_INFORMATION_CLASS PortInformationClass,
    VOID                  *PortInformation,
    ULONG                  Length,
    ULONG                 *ResultLength OPTIONAL
    );

long __stdcall NtImpersonateClientOfPort(
    HANDLE               PortHandle,
    LPC_MESSAGE_HEADER  *Request
    );

long __stdcall NtConnectPort(
    HANDLE                      *ClientPortHandle,
    UNICODE_STRING              *ServerPortName,
    SECURITY_QUALITY_OF_SERVICE *SecurityQos,
    LPC_SECTION_OWNER_MEMORY    *ClientSharedMemory,
    LPC_SECTION_MEMORY          *ServerSharedMemory,
    ULONG                       *MaximumMessageLength,
    VOID                        *ConnectionInfo,
    ULONG                       *ConnectionInfoLength
    );

#endif /* C_once_8EC340EB_8D45_4EA4_A54E_50B89260408C */

