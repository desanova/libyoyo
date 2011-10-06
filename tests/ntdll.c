#include <windows.h>
#include "../winlpc.inc"

long __stdcall NtCreatePort(
									 OUT PHANDLE              PortHandle,
									 IN  POBJECT_ATTRIBUTES   ObjectAttributes,
									 IN  ULONG                MaxConnectInfoLength,
									 IN  ULONG                MaxDataLength,
									 IN  ULONG                MaxPoolUsage
									 )
{
	return 0;
}

long __stdcall NtCreateWaitablePort(
									OUT PHANDLE              PortHandle,
									IN  POBJECT_ATTRIBUTES   ObjectAttributes,
									IN  ULONG                MaxConnectInfoLength,
									IN  ULONG                MaxDataLength,
									IN  ULONG                MaxPoolUsage
									)
{
	return 0;
}

long __stdcall NtListenPort(
									 IN  HANDLE               PortHandle,
									 OUT PLPC_MESSAGE_HEADER  ConnectionRequest
									 )
{
	return 0;
};

long __stdcall NtAcceptConnectPort(
	OUT    PHANDLE                   ServerPortHandle,
	IN     HANDLE                    AlternativeReceivePortHandle OPTIONAL,
	IN     PLPC_MESSAGE_HEADER       ConnectionReply,
	IN     BOOLEAN                   AcceptConnection,
	IN OUT PLPC_SECTION_OWNER_MEMORY ServerSharedMemory           OPTIONAL,
	OUT    PLPC_SECTION_MEMORY       ClientSharedMemory           OPTIONAL
	)
{
	return 0;
};

long __stdcall NtCompleteConnectPort(
	IN HANDLE               PortHandle
	)
{
	return 0;
};

long __stdcall NtReplyWaitReceivePort(
	IN  HANDLE               PortHandle,
	OUT PVOID*               PortContext       OPTIONAL,
	IN  PLPC_MESSAGE_HEADER  Reply             OPTIONAL,
	OUT PLPC_MESSAGE_HEADER  IncomingRequest
	)
{
	return 0;
};

long __stdcall NtReplyWaitReplyPort(
	IN     HANDLE               PortHandle,
	IN OUT PLPC_MESSAGE_HEADER  Reply
	)
{
	return 0;
};

long __stdcall NtRequestPort(
									  IN HANDLE               PortHandle,
									  IN PLPC_MESSAGE_HEADER  Request
									  )
{
	return 0;
};

long __stdcall NtRequestWaitReplyPort(
	IN  HANDLE               PortHandle,
	IN  PLPC_MESSAGE_HEADER  Request,
	OUT PLPC_MESSAGE_HEADER  IncomingReply
	)
{
	return 0;
};

long __stdcall NtWriteRequestData(
	IN  HANDLE               PortHandle,
	IN  PLPC_MESSAGE_HEADER  Request,
	IN  ULONG                DataIndex,
	IN  PVOID                Buffer,
	IN  ULONG                Length,
	OUT PULONG               ResultLength OPTIONAL
	)
{
	return 0;
};

long __stdcall NtReadRequestData(
	IN  HANDLE               PortHandle,
	IN  PLPC_MESSAGE_HEADER  Request,
	IN  ULONG                DataIndex,
	OUT PVOID                Buffer,
	IN  ULONG                Length,
	OUT PULONG               ResultLength OPTIONAL
	)
{
	return 0;
};

long __stdcall NtReplyPort(
									IN HANDLE               PortHandle,
									IN PLPC_MESSAGE_HEADER  Reply
									)
{
	return 0;
};

long __stdcall NtQueryInformationPort(
	IN  HANDLE                 PortHandle,
	IN  PORT_INFORMATION_CLASS PortInformationClass,
	OUT PVOID                  PortInformation,
	IN  ULONG                  Length,
	OUT PULONG                 ResultLength OPTIONAL
	)
{
	return 0;
};

long __stdcall NtImpersonateClientOfPort(
	IN HANDLE               PortHandle,
	IN PLPC_MESSAGE_HEADER  Request
	)
{
	return 0;
};

long __stdcall NtConnectPort(
									  OUT    PHANDLE                      ClientPortHandle,
									  IN     PUNICODE_STRING              ServerPortName,
									  IN     PSECURITY_QUALITY_OF_SERVICE SecurityQos,
									  IN OUT PLPC_SECTION_OWNER_MEMORY    ClientSharedMemory   OPTIONAL,
									  OUT    PLPC_SECTION_MEMORY          ServerSharedMemory   OPTIONAL,
									  OUT    PULONG                       MaximumMessageLength OPTIONAL,
									  IN OUT PVOID                        ConnectionInfo       OPTIONAL,
									  IN OUT PULONG                       ConnectionInfoLength OPTIONAL
									  )
{
	return 0;
};

void __stdcall RtlInitUnicodeString (
	PUNICODE_STRING DestinationString,
	PCWSTR SourceString
	)
{
	return;
};

void __stdcall NtClose(HANDLE Handle)
  {
    return;
  }
  
