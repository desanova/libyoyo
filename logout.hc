
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

#ifndef C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC
#define C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC

#include "core.hc"

enum 
  {
    YOYO_LOG_ERROR   = 0,
    YOYO_LOG_WARNING = 10,
    YOYO_LOG_NOTIFY  = 20,
    YOYO_LOG_ALL     = 100,
  };

#ifdef _YOYO_LOGOUT_BUILTIN
static clock_t YOYO_Log_Clock = 0;
static int YOYO_Log_Line_No = 0;
static int YOYO_Log_Level = YOYO_LOG_ERROR;
static int YOYO_Log_Fd = 2; // stderr
#endif

void Logout(int level, char *text)
#ifdef _YOYO_LOGOUT_BUILTIN  
  {
    if ( level <= YOYO_Log_Level )
      __Xchg_Interlock
        {        
          clock_t t = clock();
          char mark[64] = {0};
          int len = strlen(text);
          if ( t - YOYO_Log_Clock > CLOCKS_PER_SEC )
            {
              YOYO_Log_Clock = t;
              sprintf(mark, "%%clocks%% %.3f\n",(double)YOYO_Log_Clock/CLOCKS_PER_SEC);
              __Write_Out(YOYO_Log_Fd,mark,strlen(mark));
            }
          if (0) __Gogo
            {
              sprintf(mark,"[%4d] ",YOYO_Log_Line_No++);
              __Write_Out(YOYO_Log_Fd,mark,strlen(mark));
            }
          __Write_Out(YOYO_Log_Fd,text,len);
          if ( !len || text[len-1] != '\n' )
            write(YOYO_Log_Fd,"\n",1);
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
  
#endif /* C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC */

