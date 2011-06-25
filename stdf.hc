
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

#ifndef C_once_417421E0_F3B9_44A2_AA31_0384952C0D35
#define C_once_417421E0_F3B9_44A2_AA31_0384952C0D35

#include "core.hc"
#include "buffer.hc"
#include "file.hc"

/* returns -1 if error, 0 if eof and read bytes count on success */
typedef int Unknown_Read_Proc(void *buf, longptr_t f, int count, int *err);
/* returns -1 if error and read bytes count on success */
typedef int Unknown_Write_Proc(void *buf, longptr_t f, int count, int *err);

int Stdf_Read(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_STDF_BUILTIN
  {
    int q = fread(buf,1,count,(FILE*)f);
    if ( !q )
      {
        if ( !feof((FILE*)f) )
          {
            *err = ferror((FILE*)f);
            q = -1;
          }
        else
          q = 0;
      }
    return q;
  }
#endif
  ;

int Fdf_Read(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_STDF_BUILTIN
  {
    int q = read((int)f,buf,count);
    if ( q < 0 )
      q = errno;
    return q;
  }
#endif
  ;

int Stdf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_STDF_BUILTIN
  {
    int q = fwrite(buf,1,count,(FILE*)f);
    if ( !q )
      {
        *err = ferror((FILE*)f);
        q = -1;
      }
    return q;
  }
#endif
  ;

int Fdf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_STDF_BUILTIN
  {
    int q = write((int)f,buf,count);
    if ( q < 0 )
      q = errno;
    return q;
  }
#endif
  ;

int Bf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_STDF_BUILTIN
  {
    Buffer_Append((YOYO_BUFFER*)f,buf,count);
    return count;
  }
#endif
  ;

int Cf_Write(void *buf, longptr_t f, int count, int *err)
#ifdef _YOYO_STDF_BUILTIN
  {
    return Stdf_Write(buf,(longptr_t)((YOYO_CFILE*)f)->fd,count,err);
  }
#endif
  ;

int Buffer_Unknown_Read(YOYO_BUFFER *bf, 
  longptr_t f, int data_len, Unknown_Read_Proc xread)
#ifdef _YOYO_STDF_BUILTIN
  {
    int i, L, r, err;
    byte_t local_data[512];
    for ( i = 0; data_len < 0 || i < data_len; )
      {
        
        L = data_len < 0 ? sizeof(local_data) : data_len-i;
        L = Yo_MIN( L , sizeof(local_data) );
        r = xread(local_data,f,L,&err);
        if ( r > 0 )
          {
            Buffer_Append(bf,local_data,r);
            i += r;
          }
        else
          {
            if ( data_len < 0 )
              break;
            if ( !r )
              __Raise(YOYO_ERROR_IO,__yoTa("Buffer_x_Read: no enough data",0));
            else
              {
                if ( err == EAGAIN ) continue;
                __Raise_Format(YOYO_ERROR_IO,(__yoTa("Buffer_x_Read failed: %s",0),strerror(err)));
              }
          }
      }
    return i;
  }
#endif
  ;

int Unknown_Write(longptr_t f, void *bf, int count, Unknown_Write_Proc xwrite)
#ifdef _YOYO_STDF_BUILTIN
  {
    int i;
    for ( i = 0; i < count; )
      {
        int err = 0;
        int r = xwrite((char*)bf+i,f,count-i,&err);
        if ( r > 0 ) i += r;
        else if ( err != EAGAIN )
          __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to write: %s",0),strerror(err)));
      }
    return i;
  }
#endif
  ;
  
int Buffer_Unknown_Write(YOYO_BUFFER *bf, 
longptr_t f, int pos, int data_len, Unknown_Write_Proc xwrite)
#ifdef _YOYO_STDF_BUILTIN
  {
    int L;
    if ( pos > bf->count || data_len+pos > bf->count )
      __Raise(YOYO_ERROR_IO,__yoTa("Buffer_x_Write: no enough data",0));
    L = data_len < 0 ? bf->count-pos : data_len;
    return Unknown_Write(f,bf->at+pos,L,xwrite);
  }
#endif
  ;
  
#define Buffer_Stdf_Append_Whole(Bf,Stdf) Buffer_Stdf_Append(Bf,Stdf,-1)
#define Buffer_Fdf_Append_Whole(Bf,Stdf) Buffer_Stdf_Append(Bf,Fdf,-1)
#define Buffer_Stdf_Append(Bf,Stdf,Count) Buffer_Unknown_Read(Bf,(longptr_t)(Stdf),Count,Stdf_Read)
#define Buffer_Fdf_Append(Bf,Fdf,Count) Buffer_Unknown_Read(Bf,(longptr_t)(Fdf),Count,Fdf_Read)
#define Buffer_Stdf_Write_Whole(Bf,Stdf) Buffer_Stdf_Write(Bf,Stdf,0,-1)
#define Buffer_Fdf_Write_Whole(Bf,Stdf) Buffer_Stdf_Write(Bf,Fdf,0,-1)
#define Buffer_Stdf_Write(Bf,Stdf,Pos,Count) Buffer_Unknown_Write(Bf,(longptr_t)(Stdf),Pos,Count,Stdf_Write)
#define Buffer_Fdf_Write(Bf,Fdf,Pos,Count) Buffer_Unknown_Write(Bf,(longptr_t)(Fdf),Pos,Count,Fdf_Write)


enum 
  { 
    YOYO_STDF_PUMP_BUFFER = 1*KILOBYTE,
    YOYO_STDF_PUMP_BUFFER_W = YOYO_STDF_PUMP_BUFFER-1,
  };

int Stdf_Read_In(FILE *stdf,char *buf, int L)
#ifdef _YOYO_FILE_BUILTIN
  {
    int i;
    for ( i = 0; i < L; )
      {
        int q = fread(buf+i,1,L-i,stdf);
        if ( q ) 
          i += q;
        else if ( feof(stdf) )
          break;
        else
          {
            int err = ferror(stdf);
            if ( err == EAGAIN ) continue;
            __Raise_Format(YOYO_ERROR_IO,(__yoTa("failed to read: %s",0),strerror(err)));
          }
      }
    buf[i] = 0;
    return i;
  }
#endif
  ;
  
#define Stdf_Pump(stdf,buf) Stdf_Read_In(stdf,buf,YOYO_STDF_PUMP_BUFFER_W)

char *Stdf_Pump_Part(FILE *stdf, char *buf, char *S, int *L)
#ifdef _YOYO_FILE_BUILTIN
  {
    int l = *L;
    if ( !S ) S = buf+l;
    l -= ( S-buf);
    if ( l ) memmove(buf,S,l);
    l += Stdf_Read_In(stdf,buf+l,YOYO_STDF_PUMP_BUFFER_W-l);
    *L = l;
    STRICT_REQUIRE(l <= YOYO_STDF_PUMP_BUFFER_W);
    buf[l] = 0;
    return buf;
  }
#endif
  ;
  
#define Stdin_Pump(B) Stdf_Pump(stdin,B)
#define Stdin_Pump_Part(B,S,L) Stdf_Pump_Part(stdin,B,S,L)

#endif /* C_once_417421E0_F3B9_44A2_AA31_0384952C0D35 */

