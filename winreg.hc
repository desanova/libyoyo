
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

#ifndef C_once_C5685DBF_3A67_41C0_895B_A26B0D757AE7
#define C_once_C5685DBF_3A67_41C0_895B_A26B0D757AE7

#ifdef _LIBYOYO
#define _YOYO_WINREG_BUILTIN
#endif

#include "yoyo.hc"

#ifdef __windoze
#include "string.hc"
#include "buffer.hc"
#include "file.hc"

typedef struct _YOYO_WINREG
  {
    HKEY hkey;
    char *name;
  } YOYO_WINREG;

void WinReg_Close(YOYO_WINREG *o)
#ifdef _YOYO_WINREG_BUILTIN
  {
    if ( o->hkey )
      RegCloseKey(o->hkey);
    o->hkey = 0;
  }
#endif
  ;

void WinReg_Destruct(YOYO_WINREG *o)
#ifdef _YOYO_WINREG_BUILTIN
  {
    WinReg_Close(o);
    free(o->name);
    Yo_Object_Destruct(o);
  }
#endif
  ;

char *WinReg_Query_String(YOYO_WINREG *o,char *opt)
#ifdef _YOYO_WINREG_BUILTIN
  {
    char *ret = 0;
    __Auto_Ptr(ret)
      {
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        wchar_t *buf = 0;
        DWORD ltype = REG_SZ;
        long err = 0;
        DWORD L = 0;

        if ( ERROR_SUCCESS != (err=RegQueryValueExW(o->hkey,name,0,&ltype,0,&L)) )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to query value '%s' of '%s': error %08x", (opt?opt:""),o->name,err));

        if ( ltype != REG_SZ )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to query value '%s' of '%s': is not string value",(opt?opt:""),o->name));

        //buf = Yo_Malloc((L+1)*sizeof(wchar_t));
        buf = Yo_Malloc(L+2);
        buf[L/sizeof(wchar_t)] = 0;
        
        if ( ERROR_SUCCESS == (err=RegQueryValueExW(o->hkey,name,0,&ltype,(LPBYTE)buf,&L)) )
          ret = Str_Unicode_To_Utf8(buf);
        else
          if ( err != ERROR_FILE_NOT_FOUND )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to query value '%s' of '%s': error %08x", (opt?opt:""),o->name,err));
      }
    return ret;
  }
#endif
  ;

void WinReg_Set_String(YOYO_WINREG *o,char *opt,char *val)
#ifdef _YOYO_WINREG_BUILTIN
  {
    __Auto_Release
      {
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        wchar_t *str  = val?Str_Utf8_To_Unicode(val):L"";
        DWORD ltype = REG_SZ;
        long err = 0;
        if ( ERROR_SUCCESS != (err=RegSetValueExW(o->hkey,name,0,ltype,(LPBYTE)str,(Str_Length(val)+1)*sizeof(wchar_t))) )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to set value '%s' of '%s': error %08x",(opt?opt:""),o->name,err));
      }
  }
#endif
  ;

ulong_t WinReg_Query_Dword(YOYO_WINREG *o,char *opt)
#ifdef _YOYO_WINREG_BUILTIN
  {
    ulong_t ret = 0;
    __Auto_Release
      {
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        DWORD buf = 0;
        DWORD ltype = REG_DWORD;
        long err = 0;
        DWORD L = 4;
        if ( ERROR_SUCCESS == (err=RegQueryValueExW(o->hkey,name,0,&ltype,(LPBYTE)&buf,&L)) )
          ret = buf;
        else
          if ( err != ERROR_FILE_NOT_FOUND )
            __Raise(YOYO_ERROR_IO,
              __Format("failed to query value '%s' of '%s': error %08x", (opt?opt:""),o->name,err));
      }
    return ret;
  }
#endif
  ;

void WinReg_Set_Dword(YOYO_WINREG *o,char *opt,ulong_t val)
#ifdef _YOYO_WINREG_BUILTIN
  {
    __Auto_Release
      {
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        DWORD ltype = REG_DWORD;
        DWORD buf = val;
        long err = 0;
        if ( ERROR_SUCCESS != (err=RegSetValueExW(o->hkey,name,0,ltype,(LPBYTE)&buf,4)) )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to set value '%s' of '%s': error %08x",(opt?opt:""),o->name,err));
      }
  }
#endif
  ;

YOYO_BUFFER *WinReg_Query_Binary(YOYO_WINREG *o,char *opt)
#ifdef _YOYO_WINREG_BUILTIN
  {
    void *ret = 0;
    __Auto_Ptr(ret)
      {
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        YOYO_BUFFER *bf;
        DWORD ltype = REG_SZ;
        long err = 0;
        DWORD L = 0;
        RegQueryValueExW(o->hkey,name,0,&ltype,0,&L);
        bf = Buffer_Init(L);
        if ( ERROR_SUCCESS == (err=RegQueryValueExW(o->hkey,name,0,&ltype,bf->at,&L)) )
          ret = bf;
        else
          if ( err != ERROR_FILE_NOT_FOUND )
            __Raise(YOYO_ERROR_IO,
              __Format("failed to query value '%s' of '%s': error %08x", (opt?opt:""),o->name,err));
      }
    return ret;
  }
#endif
  ;

void WinReg_Set_Binary(YOYO_WINREG *o,char *opt,void *val, int val_len)
#ifdef _YOYO_WINREG_BUILTIN
  {
    __Auto_Release
      {
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        DWORD ltype = REG_BINARY;
        long err = 0;
        if ( ERROR_SUCCESS != (err=RegSetValueExW(o->hkey,name,0,ltype,val,val_len)) )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to set value '%s' of '%s': error %08x",(opt?opt:""),o->name,err));
      }
  }
#endif
  ;

void WinReg_Delete_Value(YOYO_WINREG *o,char *opt)
#ifdef _YOYO_WINREG_BUILTIN
  {
    __Auto_Release
      {
        int err;
        wchar_t *name = opt?Str_Utf8_To_Unicode(opt):L"";
        if ( ERROR_SUCCESS != (err=RegDeleteValueW(o->hkey,name)) )
          __Raise(YOYO_ERROR_IO,
            __Format("failed to delete value '%s' of '%s': error %08x",(opt?opt:""),o->name,err));
      }
  }
#endif
  ;

YOYO_WINREG *WinReg_Object_Init()
#ifdef _YOYO_WINREG_BUILTIN
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,  WinReg_Destruct},
        {Oj_Close_OjMID,     WinReg_Close},
        {0}};
    return __Object(sizeof(YOYO_WINREG),funcs);
  }
#endif
  ;
  
void *WinReg_Open_Or_Create_Hkey(HKEY master, char *subkey, int create_if_need, char *parent_name)
#ifdef _YOYO_WINREG_BUILTIN
  {
    YOYO_WINREG *ret = 0;
    __Auto_Ptr(ret)
      {
        int err;
        wchar_t *name;
        
        ret = WinReg_Object_Init();
        name = Str_Utf8_To_Unicode(subkey);
        if ( parent_name )
          ret->name = Str_Join_Npl_2('\\',parent_name,subkey);
        else
          ret->name = Str_Concat_Npl(Yo_Format("%08x\\",master),subkey);
        
        if ( create_if_need )
          {
            if ( ERROR_SUCCESS != (err = RegCreateKeyExW(master,name,0,0,0,KEY_ALL_ACCESS,0,&ret->hkey,0)) )
              __Raise(YOYO_ERROR_IO,
                __Format("failed to create winreg key '%s': error %08x",ret->name,err));
          }
        else
          {
            if ( ERROR_SUCCESS != (err = RegOpenKeyExW(master,name,0,KEY_ALL_ACCESS,&ret->hkey)) )
              __Raise(YOYO_ERROR_IO,
                __Format("failed to open winreg key '%s': error %08x",ret->name,err));
          }
      }
    return ret;
  }
#endif
  ;

void *WinReg_Open_Or_Create_Hkey_Obj(YOYO_WINREG *obj, char *subkey, int create_if_need)
#ifdef _YOYO_WINREG_BUILTIN
  {
    return WinReg_Open_Or_Create_Hkey(obj->hkey,subkey,create_if_need,obj->name);
  }
#endif
  ;

void *WinReg_Open_Or_Create(char *subkey, int create_if_need)
#ifdef _YOYO_WINREG_BUILTIN
  {
    int i;
    HKEY master = 0;
    char *name = 0;
    char *parent = 0;
    static char *str_vars[3] =
        {"\\CURRENT_USER\\","\\LOCAL_MACHINE\\","\\CLASSES_ROOT\\"};
    static HKEY hkey_vars[3] =
        {HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE, HKEY_CLASSES_ROOT};
    for ( i = 0; i < 3; ++i )
      if ( Str_Starts_With(subkey,str_vars[i]) )
        {
          name = subkey+strlen(str_vars[i]);
          master = hkey_vars[i];
          parent = str_vars[i];
          break;
        }

    if ( !master )
      __Raise(YOYO_ERROR_DOESNT_EXIST,
        __Format("registry key '%s' doesn't exist",subkey));
    
    return WinReg_Open_Or_Create_Hkey(master,name,create_if_need,parent);
  }
#endif
  ;

YOYO_WINREG *WinReg_Assign(HKEY key, char *name)
#ifdef _YOYO_WINREG_BUILTIN
  {
    YOYO_WINREG *rkey = WinReg_Object_Init();
    rkey->hkey = key;
    rkey->name = Str_Copy_Npl(name,-1);
    return rkey;
  }
#endif
  ;

#define WinReg_Open_Subkey(Obj,Subkey) \
  WinReg_Open_Or_Create_Hkey_Obj(Obj,Subkey,0)
#define WinReg_Create_Subkey(Obj,Subkey) \
  WinReg_Open_Or_Create_Hkey_Obj(Obj,Subkey,1)
#define WinReg_Open(Key) \
  WinReg_Open_Or_Create(Key,0)
#define WinReg_Create(Key) \
  WinReg_Open_Or_Create(Key,1)

#define Open_Current_User_Subkey(Subkey) \
  WinReg_Open_Or_Create_Hkey(HKEY_CURRENT_USER,Subkey,0,"\\CURRENT_USER")
#define Open_Local_Machine_Subkey(Subkey) \
  WinReg_Open_Or_Create_Hkey(HKEY_LOCAL_MACHINE,Subkey,0,"\\LOCAL_MACHINE")
#define Open_Class_Root_Subkey(Subkey) \
  WinReg_Open_Or_Create_Hkey(HKEY_CLASS_ROOT,Subkey,0,"\\CLASSES_ROOT")
#define Create_Current_User_Subkey(Subkey) \
  WinReg_Open_Or_Create_Hkey(HKEY_CURRENT_USER,Subkey,1,"\\CURRENT_USER")
#define Create_Local_Machine_Subkey(Subkey) \
  WinReg_Open_Or_Create_Hkey(HKEY_LOCAL_MACHINE,Subkey,1,"\\LOCAL_MACHINE")
#define Create_Classes_Root_Subkey(Subkey) \
  WinReg_Open_Or_Create_Hkey(HKEY_CLASSES_ROOT,Subkey,1,"\\CLASSES_ROOT")


  
#endif /* __windoze */
#endif /* C_once_C5685DBF_3A67_41C0_895B_A26B0D757AE7 */

