
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

#ifndef C_once_A998DD5F_3579_4977_B115_DCCE42423C49
#define C_once_A998DD5F_3579_4977_B115_DCCE42423C49

#ifdef _LIBYOYO
#define _YOYO_DATETIME_BUILTIN
#endif

#include "yoyo.hc"

typedef quad_t datetime_t;

#define Get_Curr_Datetime()    Current_Gmt_Datetime()
#define Get_Posix_Datetime(Dt) Timet_Of_Datetime(Dt)
#define Get_Gmtime_Datetime(T) Gmtime_Datetime(T)
#define Get_System_Useconds()  System_Useconds()
#define Get_System_Millis()    (Get_System_Useconds()/1000)

#define System_Millis() (System_Useconds()/1000)
quad_t System_Useconds()
#ifdef _YOYO_DATETIME_BUILTIN
  {
  #ifdef __windoze
    SYSTEMTIME systime = {0};
    FILETIME   ftime;
    quad_t Q;
    GetSystemTime(&systime);
    SystemTimeToFileTime(&systime,&ftime);
    Q = ((quad_t)ftime.dwHighDateTime << 32) + (quad_t)ftime.dwLowDateTime;
    Q -= 116444736000000000LL; /* posix epoche */
    return Q/10;
  #else
    struct timeval tv = {0};
    gettimeofday(&tv,0);
    return  ( (quad_t)tv.tv_sec * 1000*1000 + (quad_t)tv.tv_usec );
  #endif
  }
#endif
  ;
  
uint_t Get_Mclocks()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    double c = clock();
    return (uint_t)((c/CLOCKS_PER_SEC)*1000);
  }
#endif
  ;

double Get_Sclocks()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    double c = clock();
    return c/CLOCKS_PER_SEC;
  }
#endif
  ;

quad_t Tm_To_Datetime(struct tm *tm,int msec)
#ifdef _YOYO_DATETIME_BUILTIN
  {
    uint_t dt = (((uint_t)tm->tm_year+1900)<<16)|(((uint_t)tm->tm_mon+1)<<8)|tm->tm_mday;
    uint_t mt = ((uint_t)tm->tm_hour<<24)|(uint_t)(tm->tm_min<<16)|((uint_t)tm->tm_sec<<8)|((msec/10)%100);
    return ((quad_t)dt << 32)|(quad_t)mt;
  }
#endif
  ;

#define Gmtime_Datetime(T) _Gmtime_Datetime(T,0)
quad_t _Gmtime_Datetime(time_t t, int ms)
#ifdef _YOYO_DATETIME_BUILTIN
  {
    struct tm *tm;
    tm = gmtime(&t);
    return Tm_To_Datetime(tm,ms);
  }
#endif
  ;

#define Local_Datetime(T) _Local_Datetime(T,0)
quad_t _Local_Datetime(time_t t, int ms)
#ifdef _YOYO_DATETIME_BUILTIN
  {
    struct tm *tm;
    tm = localtime(&t);
    return Tm_To_Datetime(tm,ms);
  }
#endif
  ;

quad_t Current_Gmt_Datetime()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    quad_t usec = Get_System_Useconds();
    return _Gmtime_Datetime((time_t)(usec/1000000),(int)((usec/1000)%1000));
  }
#endif
  ;

quad_t Current_Local_Datetime()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    quad_t usec = Get_System_Useconds();
    return _Local_Datetime((time_t)(usec/1000000),(int)((usec/1000)%1000));
  }
#endif
  ;

#define Dt_Hour(Dt) ((int)((Dt)>>24)&0x0ff)
#define Dt_Min(Dt)  ((int)((Dt)>>16)&0x0ff)
#define Dt_Sec(Dt)  ((int)((Dt)>> 8)&0x0ff)
#define Dt_Msec(Dt) ((int)((Dt)>> 0)&0x0ff)
#define Dt_Year(Dt) ((int)((Dt)>>(32+16))&0x0ffff)
#define Dt_Mon(Dt)  ((int)((Dt)>>(32+ 8))&0x0ff)
#define Dt_Mday(Dt) ((int)((Dt)>>(32+ 0))&0x0ff)

quad_t Get_Datetime(uint_t year, uint_t month, uint_t day, uint_t hour, uint_t minute, uint_t segundo )
#ifdef _YOYO_DATETIME_BUILTIN
  {
    uint_t dt = ((year%0x0ffff)<<16)|((month%13)<<8)|(day%32);
    uint_t mt = ((hour%24)<<24)|((minute%60)<<16)|((segundo%60)<<8);
    return ((quad_t)dt << 32)|(quad_t)mt;
  }
#endif
  ;

time_t Timet_Of_Datetime(quad_t dtime)
#ifdef _YOYO_DATETIME_BUILTIN
  {
    struct tm tm;
    memset(&tm,0,sizeof(tm));
    tm.tm_year = Dt_Year(dtime)-1900;
    tm.tm_mon  = Dt_Mon(dtime)-1;
    tm.tm_mday = Dt_Mday(dtime);
    tm.tm_hour = Dt_Hour(dtime);
    tm.tm_min  = Dt_Min(dtime);
    return mktime(&tm);
  }
#endif
  ;

#ifdef __windoze
  void Timet_To_Filetime(time_t t, FILETIME *pft)
# ifdef _YOYO_DATETIME_BUILTIN
    {
      quad_t ll = (quad_t)t * 10000000 + 116444736000000000LL;
      pft->dwLowDateTime = (DWORD)ll;
      pft->dwHighDateTime = (DWORD)(ll >> 32);
    }
# endif
    ;
  #define Timet_To_Largetime(T,Li) Timet_To_Filetime(T,(FILETIME*)(Li))
#endif /*__windoze*/

#endif /* C_once_A998DD5F_3579_4977_B115_DCCE42423C49 */

