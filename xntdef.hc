
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

#ifndef C_once_D26A79BF_9E35_48C1_8D5B_03D5A42C3203
#define C_once_D26A79BF_9E35_48C1_8D5B_03D5A42C3203
#ifdef __windoze

#ifdef _LIBYOYO
#define _YOYO_XNTDEF_BUILTIN
#endif

typedef long NTSTATUS;

#define STATUS_NO_SUCH_FILE           ((NTSTATUS)0xC000000FL)
#define STATUS_BUFFER_OVERFLOW        ((NTSTATUS)0x80000005L)
#define STATUS_NO_MORE_FILES          ((NTSTATUS)0x80000006L)
#define STATUS_CONFLICTING_ADDRESSES  ((NTSTATUS)0xC0000018L)
#define STATUS_IMAGE_NOT_AT_BASE      ((NTSTATUS)0x40000003L)
#define STATUS_OBJECT_NAME_NOT_FOUND  ((NTSTATUS)0xC0000034L)
#define STATUS_INVALID_PARAMETER      ((NTSTATUS)0xC000000DL)
#define STATUS_NO_MORE_ENTRIES        ((NTSTATUS)0x8000001AL)
#define STATUS_BUFFER_TOO_SMALL       ((NTSTATUS)0xC0000023L)

#define NT_SUCCESS(Status) ((NTSTATUS)(Status) >= 0)
#define NT_INFORMATION(Status) ((ULONG)(Status) >> 30 == 1)
#define NT_WARNING(Status) ((ULONG)(Status) >> 30 == 2)
#define NT_ERROR(Status) ((ULONG)(Status) >> 30 == 3)

#define InitializeObjectAttributes( p, n, a, r, s ) { \
    (p)->Length = sizeof( OBJECT_ATTRIBUTES );          \
    (p)->RootDirectory = r;                             \
    (p)->Attributes = a;                                \
    (p)->ObjectName = n;                                \
    (p)->SecurityDescriptor = s;                        \
    (p)->SecurityQualityOfService = NULL;               \
    }

#define OBJ_INHERIT             0x00000002L
#define OBJ_PERMANENT           0x00000010L
#define OBJ_EXCLUSIVE           0x00000020L
#define OBJ_CASE_INSENSITIVE    0x00000040L
#define OBJ_OPENIF              0x00000080L
#define OBJ_OPENLINK            0x00000100L
#define OBJ_VALID_ATTRIBUTES    0x000001F2L

typedef struct _STRING {
    USHORT Length;
    USHORT MaximumLength;
    PCHAR Buffer;
} STRING;
typedef STRING *PSTRING;

typedef STRING ANSI_STRING;
typedef PSTRING PANSI_STRING;
typedef PSTRING PCANSI_STRING;

typedef STRING OEM_STRING;
typedef PSTRING POEM_STRING;
typedef CONST STRING* PCOEM_STRING;

typedef struct _UNICODE_STRING {
    USHORT Length;
    USHORT MaximumLength;
    PWSTR  Buffer;
} UNICODE_STRING;
typedef UNICODE_STRING *PUNICODE_STRING;
typedef const UNICODE_STRING *PCUNICODE_STRING;

void __stdcall RtlInitUnicodeString (
	PUNICODE_STRING DestinationString,
	PCWSTR SourceString
  );

typedef struct _OBJECT_ATTRIBUTES {
    ULONG Length;
    HANDLE RootDirectory;
    PUNICODE_STRING ObjectName;
    ULONG Attributes;
    PVOID SecurityDescriptor;
    PVOID SecurityQualityOfService;
} OBJECT_ATTRIBUTES;
typedef OBJECT_ATTRIBUTES *POBJECT_ATTRIBUTES;

long __stdcall NtAllocateVirtualMemory(
  HANDLE process,
  VOID **baseaddr,
  ULONG zerobits,
  ULONG *size,
  ULONG alloc_type,
  ULONG page_attributes);

void __stdcall NtClose(HANDLE);

long __stdcall NtCreateSection(
  HANDLE *handle,
  ULONG access,
  OBJECT_ATTRIBUTES *oa,
  LARGE_INTEGER *maxsize,
  ULONG page_attributes,
  ULONG sect_attributes,
  HANDLE FileHandle);

long __stdcall NtUnmapViewOfSection( 
  HANDLE ProcessHandle,
  PVOID BaseAddress);

typedef enum _SECTION_INHERIT { ViewShare=1, ViewUnmap=2 } SECTION_INHERIT, *PSECTION_INHERIT;

long __stdcall NtMapViewOfSection(
  HANDLE SectionHandle,
  HANDLE ProcessHandle,
  PVOID *BaseAddress,
  ULONG_PTR ZeroBits,
  SIZE_T CommitSize,
  PLARGE_INTEGER SectionOffset,
  PSIZE_T ViewSize,
  SECTION_INHERIT InheritDisposition,
  ULONG AllocationType,
  ULONG Win32Protect);

long __stdcall NtCreateKey(
  HANDLE *KeyHandle,
  ACCESS_MASK DesiredAccess,
  OBJECT_ATTRIBUTES *ObjectAttributes,
  ULONG TitleIndex,
  UNICODE_STRING *Class,
  ULONG CreateOptions,
  ULONG *Disposition);

long __stdcall NtOpenKey(
  HANDLE *KeyHandle,
  ACCESS_MASK DesiredAccess,
  OBJECT_ATTRIBUTES *ObjectAttributes);
  
long __stdcall NtDeleteKey(
  HANDLE *KeyHandle);
  
typedef struct _PEB_LDR_DATA 
  {
    ULONG                   Length;
    BOOLEAN                 Initialized;
    PVOID                   SsHandle;
    LIST_ENTRY              InLoadOrderModuleList;
    LIST_ENTRY              InMemoryOrderModuleList;
    LIST_ENTRY              InInitializationOrderModuleList;
  } PEB_LDR_DATA, *PPEB_LDR_DATA;

typedef struct _LDR_MODULE
  {
    LIST_ENTRY              InLoadOrderModuleList;
    LIST_ENTRY              InMemoryOrderModuleList;
    LIST_ENTRY              InInitializationOrderModuleList;
    PVOID                   BaseAddress;
    PVOID                   EntryPoint;
    ULONG                   SizeOfImage;
    UNICODE_STRING          FullDllName;
    UNICODE_STRING          BaseDllName;
    ULONG                   Flags;
    SHORT                   LoadCount; 
    SHORT                   TlsIndex;
    LIST_ENTRY              HashTableEntry;
    ULONG                   TimeDateStamp;
  } LDR_MODULE, *PLDR_MODULE;

typedef struct _PEB_FREE_BLOCK 
  {
    struct _PEB_FREE_BLOCK *Next;
    ULONG                   Size;
  } PEB_FREE_BLOCK, *PPEB_FREE_BLOCK;

typedef struct _RTL_DRIVE_LETTER_CURDIR 
  {
    USHORT                  Flags;
    USHORT                  Length;
    ULONG                   TimeStamp;
    UNICODE_STRING          DosPath;
  } RTL_DRIVE_LETTER_CURDIR, *PRTL_DRIVE_LETTER_CURDIR;

typedef struct _RTL_USER_PROCESS_PARAMETERS 
  {
    ULONG                   MaximumLength;
    ULONG                   Length;
    ULONG                   Flags;
    ULONG                   DebugFlags;
    PVOID                   ConsoleHandle;
    ULONG                   ConsoleFlags;
    HANDLE                  StdInputHandle;
    HANDLE                  StdOutputHandle;
    HANDLE                  StdErrorHandle;
    UNICODE_STRING          CurrentDirectoryPath;
    HANDLE                  CurrentDirectoryHandle;
    UNICODE_STRING          DllPath;
    UNICODE_STRING          ImagePathName;
    UNICODE_STRING          CommandLine;
    PVOID                   Environment;
    ULONG                   StartingPositionLeft;
    ULONG                   StartingPositionTop;
    ULONG                   Width;
    ULONG                   Height;
    ULONG                   CharWidth;
    ULONG                   CharHeight;
    ULONG                   ConsoleTextAttributes;
    ULONG                   WindowFlags;
    ULONG                   ShowWindowFlags;
    UNICODE_STRING          WindowTitle;
    UNICODE_STRING          DesktopInfo;
    UNICODE_STRING          ShellInfo;
    UNICODE_STRING          RuntimeData;
    RTL_DRIVE_LETTER_CURDIR DLCurrentDirectory[0x20];
  } RTL_USER_PROCESS_PARAMETERS, *PRTL_USER_PROCESS_PARAMETERS;

typedef struct _BASE_STATIC_SERVER_DATA BASE_STATIC_SERVER_DATA;

typedef struct _XPEB 
  {
    BOOLEAN                 InheritedAddressSpace;
    BOOLEAN                 ReadImageFileExecOptions;
    BOOLEAN                 BeingDebugged;
    BOOLEAN                 Spare;
    HANDLE                  Mutant;
    PVOID                   ImageBaseAddress;
    PPEB_LDR_DATA           LoaderData;
    PRTL_USER_PROCESS_PARAMETERS ProcessParameters;
    PVOID                   SubSystemData;
    PVOID                   ProcessHeap;
    PVOID                   FastPebLock;
    /*PPEBLOCKROUTINE*/ void *FastPebLockRoutine;
    /*PPEBLOCKROUTINE*/ void *FastPebUnlockRoutine;
    ULONG                   EnvironmentUpdateCount;
    PVOID                   *KernelCallbackTable;
    PVOID                   EventLogSection;
    PVOID                   EventLog;
    PPEB_FREE_BLOCK         FreeList;
    ULONG                   TlsExpansionCounter;
    PVOID                   TlsBitmap;
    ULONG                   TlsBitmapBits[0x2];
    PVOID                   ReadOnlySharedMemoryBase;
    PVOID                   ReadOnlySharedMemoryHeap;
    BASE_STATIC_SERVER_DATA **ReadOnlyStaticServerData;
    PVOID                   AnsiCodePageData;
    PVOID                   OemCodePageData;
    PVOID                   UnicodeCaseTableData;
    ULONG                   NumberOfProcessors;
    ULONG                   NtGlobalFlag;
    BYTE                    Spare2[0x4];
    LARGE_INTEGER           CriticalSectionTimeout;
    ULONG                   HeapSegmentReserve;
    ULONG                   HeapSegmentCommit;
    ULONG                   HeapDeCommitTotalFreeThreshold;
    ULONG                   HeapDeCommitFreeBlockThreshold;
    ULONG                   NumberOfHeaps;
    ULONG                   MaximumNumberOfHeaps;
    PVOID                   **ProcessHeaps;
    PVOID                   GdiSharedHandleTable;
    PVOID                   ProcessStarterHelper;
    PVOID                   GdiDCAttributeList;
    PVOID                   LoaderLock;
    ULONG                   OSMajorVersion;
    ULONG                   OSMinorVersion;
    ULONG                   OSBuildNumber;
    ULONG                   OSPlatformId;
    ULONG                   ImageSubSystem;
    ULONG                   ImageSubSystemMajorVersion;
    ULONG                   ImageSubSystemMinorVersion;
    ULONG                   GdiHandleBuffer[0x22];
    ULONG                   PostProcessInitRoutine;
    ULONG                   TlsExpansionBitmap;
    BYTE                    TlsExpansionBitmapBits[0x80];
    ULONG                   SessionId;
  } XPEB, *PXPEB;

typedef struct _CLIENT_ID { PVOID UniqueProcess; PVOID UniqueThread; } CLIENT_ID , *PCLIENT_ID;

typedef struct _XTEB 
  {
    NT_TIB                  Tib;
    PVOID                   EnvironmentPointer;
    CLIENT_ID               ClientId;
    PVOID                   ActiveRpcInfo;
    PVOID                   ThreadLocalStoragePointer;
    PXPEB                   Peb;
    ULONG                   LastErrorValue;
    ULONG                   CountOfOwnedCriticalSections;
    PVOID                   CsrClientThread;
    PVOID                   Win32ThreadInfo;
    ULONG                   Win32ClientInfo[0x1F];
    PVOID                   WOW32Reserved;
    ULONG                   CurrentLocale;
    ULONG                   FpSoftwareStatusRegister;
    PVOID                   SystemReserved1[0x36];
    PVOID                   Spare1;
    ULONG                   ExceptionCode;
    ULONG                   SpareBytes1[0x28];
    PVOID                   SystemReserved2[0xA];
    ULONG                   GdiRgn;
    ULONG                   GdiPen;
    ULONG                   GdiBrush;
    CLIENT_ID               RealClientId;
    PVOID                   GdiCachedProcessHandle;
    ULONG                   GdiClientPID;
    ULONG                   GdiClientTID;
    PVOID                   GdiThreadLocaleInfo;
    PVOID                   UserReserved[5];
    PVOID                   GlDispatchTable[0x118];
    ULONG                   GlReserved1[0x1A];
    PVOID                   GlReserved2;
    PVOID                   GlSectionInfo;
    PVOID                   GlSection;
    PVOID                   GlTable;
    PVOID                   GlCurrentRC;
    PVOID                   GlContext;
    NTSTATUS                LastStatusValue;
    UNICODE_STRING          StaticUnicodeString;
    WCHAR                   StaticUnicodeBuffer[0x105];
    PVOID                   DeallocationStack;
    PVOID                   TlsSlots[0x40];
    LIST_ENTRY              TlsLinks;
    PVOID                   Vdm;
    PVOID                   ReservedForNtRpc;
    PVOID                   DbgSsReserved[0x2];
    ULONG                   HardErrorDisabled;
    PVOID                   Instrumentation[0x10];
    PVOID                   WinSockData;
    ULONG                   GdiBatchCount;
    ULONG                   Spare2;
    ULONG                   Spare3;
    ULONG                   Spare4;
    PVOID                   ReservedForOle;
    ULONG                   WaitingOnLoaderLock;
    PVOID                   StackCommit;
    PVOID                   StackCommitMax;
    PVOID                   StackReserved;
  } XTEB, *PXTEB;

typedef struct _INITIAL_TEB 
  {
    struct {
        PVOID OldStackBase;
        PVOID OldStackLimit;
    } OldInitialTeb;
    PVOID StackBase;
    PVOID StackLimit;
    PVOID StackAllocationBase;
    //PVOID                StackBase;
    //PVOID                StackLimit;
    //PVOID                StackCommit;
    //PVOID                StackCommitMax;
    //PVOID                StackReserved;
  } INITIAL_TEB, *PINITIAL_TEB;

XTEB *Query_TEB()
#ifdef _YOYO_XNTDEF_BUILTIN
  {
  #ifdef __GNUC__
  #else
    XTEB *teb;
    __asm mov eax, fs:[0x18] 
    __asm mov teb, eax
    return teb;
  #endif
  }
#endif
  ;
  
XPEB *Query_PEB()
#ifdef _YOYO_XNTDEF_BUILTIN
  {
    return Query_TEB()->Peb;  
  }
#endif
  ;

#define GET_NT_HEADERS(p) ((IMAGE_NT_HEADERS *)((byte_t*)p + ((IMAGE_DOS_HEADER*)p)->e_lfanew))

IMAGE_NT_HEADERS *Get_Nt_Headers(void *p)
#ifdef _YOYO_XNTDEF_BUILTIN
  {
    return GET_NT_HEADERS(p);
  }
#endif
  ;
  
#endif /* __windoze */  
#endif /* C_once_D26A79BF_9E35_48C1_8D5B_03D5A42C3203 */
