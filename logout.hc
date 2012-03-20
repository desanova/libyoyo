
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

#ifndef C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC
#define C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC

#ifdef _LIBYOYO
#define _YOYO_LOGOUT_BUILTIN
#endif

#include "yoyo.hc"
#include "file.hc"

enum 
  {
    YOYO_LOG_ERROR   = 0,
    YOYO_LOG_WARN    = 10,
    YOYO_LOG_INFO    = 20,
    YOYO_LOG_DEBUG   = 50,
    YOYO_LOG_ALL     = 100,
  };

#ifdef _YOYO_LOGOUT_BUILTIN
static clock_t YOYO_Log_Clock = 0;
static int YOYO_Log_Line_No = 0;
static int YOYO_Log_Fd = -1;
static int YOYO_Log_Opt = 0;
int YOYO_Log_Level = YOYO_LOG_ERROR;
/* static int YOYO_Log_Pid = 0; */
#else
int YOYO_Log_Level;
#endif

enum
  {
    YOYO_LOG_DATESTAMP = 1 << 16,
    YOYO_LOG_PID       = 1 << 17,
    YOYO_LOG_DATEMARK  = 1 << 18,
    YOYO_LOG_LINENO    = 1 << 19,
    YOYO_LOG_LEVEL     = 1 << 20,
  };
  
void Close_Log()
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    if ( YOYO_Log_Fd >= 0 )
      {
        close(YOYO_Log_Fd);
        YOYO_Log_Fd = -1;
      }
  }
#endif
  ;
  
void Append_Log(char *logname, int opt)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    Close_Log();
    Create_Required_Dirs(logname);
    YOYO_Log_Fd = Open_File_Raise(logname,O_CREAT|O_APPEND|O_WRONLY);
    YOYO_Log_Opt = opt;
    YOYO_Log_Level = opt & 0x0ff;
  }
#endif
  ;
  
void Rewrite_Log(char *logname, int opt)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    Close_Log();
    Create_Required_Dirs(logname);
    YOYO_Log_Fd = Open_File_Raise(logname,O_CREAT|O_APPEND|O_WRONLY|O_TRUNC);
    YOYO_Log_Opt = opt;
    YOYO_Log_Level = opt & 0x0ff;
  }
#endif
  ;
  
void Set_Logout_Opt(int opt)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    YOYO_Log_Opt = opt;
  }
#endif
  ;

void Logout(int level, char *text)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    if ( level <= YOYO_Log_Level )
      __Xchg_Interlock
        {        
          int log_fd = YOYO_Log_Fd >= 0 ? YOYO_Log_Fd : fileno(stderr);
          char mark[80] = {0};
          int len = strlen(text);
          if ( YOYO_Log_Opt & YOYO_LOG_DATESTAMP )
            {
              clock_t t = clock();
              if ( t - YOYO_Log_Clock > CLOCKS_PER_SEC )
                {
                  YOYO_Log_Clock = t;
                  sprintf(mark, "%%clocks%% %.3f\n",(double)YOYO_Log_Clock/CLOCKS_PER_SEC);
                  Write_Out(log_fd,mark,strlen(mark));
                }
            }
          if ( YOYO_Log_Opt & (YOYO_LOG_LEVEL) )
            {
              if ( level == YOYO_LOG_ERROR )
                Write_Out(log_fd,"{error} ",8);
              else if ( level == YOYO_LOG_WARN )
                Write_Out(log_fd,"{warn!} ",8);
              else if ( level == YOYO_LOG_INFO )
                Write_Out(log_fd,"{info!} ",8);
              else
                Write_Out(log_fd,"{debug} ",8);
            }
          if ( YOYO_Log_Opt & (YOYO_LOG_DATEMARK|YOYO_LOG_PID|YOYO_LOG_LINENO) )
            {
              int i = 1;
              mark[0] = '[';
              if ( YOYO_Log_Opt & YOYO_LOG_LINENO )
                i += sprintf(mark+i,"%4d",YOYO_Log_Line_No);
              if ( YOYO_Log_Opt & YOYO_LOG_PID ) 
                {
                  int YOYO_Log_Pid = getpid();
                  if ( i > 1 ) mark[i++] = ':';
                  i += sprintf(mark+i,"%5d",YOYO_Log_Pid);
                }
              if ( YOYO_Log_Opt & YOYO_LOG_DATEMARK ) 
                {
                  time_t t = time(0);
                  struct tm *tm = localtime(&t);
                  if ( i > 1 ) mark[i++] = ':';
                  i += sprintf(mark+i,"%02d%02d%02d/%02d:%02d",
                          tm->tm_mday,tm->tm_mon+1,(tm->tm_year+1900)%100,
                          tm->tm_hour,tm->tm_min);
                }
              mark[i++] = ']';
              mark[i++] = ' ';
              mark[i] = 0;  
              Write_Out(log_fd,mark,i);
            }
          ++YOYO_Log_Line_No;
          Write_Out(log_fd,text,len);
          if ( !len || text[len-1] != '\n' )
            Write_Out(log_fd,"\n",1);
        }
  }
#endif
  ;
  
void Logoutf(int level, char *fmt, ...)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    if ( level <= YOYO_Log_Level )
      {
        va_list va;
        char *text;
        va_start(va,fmt);
        text = Yo_Format_(fmt,va);
        Logout(level,text);
        free(text);
        va_end(va);
      }
  }
#endif
  ;

#define Log_Debug if (YOYO_Log_Level<YOYO_LOG_DEBUG); else Log_Debug_
void Log_Debug_(char *fmt, ...)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = Yo_Format_(fmt,va);
    Logout(YOYO_LOG_DEBUG,text);
    free(text);
    va_end(va);
  }
#endif
  ;


#define Log_Info if (YOYO_Log_Level<YOYO_LOG_INFO); else Log_Info_
void Log_Info_(char *fmt, ...)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = Yo_Format_(fmt,va);
    Logout(YOYO_LOG_INFO,text);
    free(text);
    va_end(va);
  }
#endif
  ;

#define Log_Warning if (YOYO_Log_Level<YOYO_LOG_WARN); else Log_Warning_
void Log_Warning_(char *fmt, ...)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = Yo_Format_(fmt,va);
    Logout(YOYO_LOG_WARN,text);
    free(text);
    va_end(va);
  }
#endif
  ;

/*#define Log_Error if (YOYO_Log_Level<YOYO_LOG_ERROR); else Log_Error_*/
void Log_Error(char *fmt, ...)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = Yo_Format_(fmt,va);
    Logout(YOYO_LOG_ERROR,text);
    free(text);
    va_end(va);
  }
#endif
  ;

#endif /* C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC */

