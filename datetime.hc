
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

#ifndef C_once_A998DD5F_3579_4977_B115_DCCE42423C49
#define C_once_A998DD5F_3579_4977_B115_DCCE42423C49

#include "core.hc"

typedef quad_t datetime_t;

uint_t Get_Curr_Date()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    time_t t;
    struct tm *tm;
    time(&t);
    tm = gmtime(&t);
    return (((uint_t)tm->tm_year+1900)<<16)|((uint_t)(tm->tm_mon+1)<<8)|tm->tm_mday;
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

uint_t Get_Curr_Time()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    uint_t msec;
    time_t t;
    struct tm *tm;
    time(&t);
    msec = Get_Mclocks();
    tm = gmtime(&t);
    return ((uint_t)tm->tm_hour<<24)|((uint_t)tm->tm_min<<16)|((uint_t)tm->tm_sec<<8)|((msec/10)%100);
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

quad_t Get_Curr_Datetime()
#ifdef _YOYO_DATETIME_BUILTIN
  {
    uint_t msec,dt,mt;
    time_t t;
    struct tm *tm;
    time(&t);
    tm = gmtime(&t);
    msec = Get_Mclocks();
    dt = (((uint_t)tm->tm_year+1900)<<16)|(((uint_t)tm->tm_mon+1)<<8)|tm->tm_mday;
    mt = ((uint_t)tm->tm_hour<<24)|(uint_t)(tm->tm_min<<16)|((uint_t)tm->tm_sec<<8)|((msec/10)%100);
    return ((quad_t)dt << 32)|(quad_t)mt;
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

#endif /* C_once_A998DD5F_3579_4977_B115_DCCE42423C49 */

