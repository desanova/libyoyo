
/*

Copyright © 2010-2012, Alexéy Sudáchen, alexey@sudachen.name, Chile

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

#ifndef C_once_91A90154_CD39_414F_9D05_4B45029B172F
#define C_once_91A90154_CD39_414F_9D05_4B45029B172F

#ifdef _LIBYOYO
#define _YOYO_BIO_BUILTIN
#endif

enum 
  { 
    YOYO_BIO_BUFFER_SIZE = 512,
    YOYO_BIO_WRITE = __FOUR_CHARS('W','R','I','T'), 
    YOYO_BIO_READ  = __FOUR_CHARS('R','E','A','D'),
  };

typedef struct _YOYO_BIO_BUFFER
  {
    int    start, end;
    byte_t data[YOYO_BIO_BUFFER_SIZE];
  } YOYO_BIO_BUFFER;

typedef struct _YOYO_BIO
  {
    YOYO_BIO_BUFFER bf;
    int (*inout)(void*,void*,int,int);
    void *strm;
    int  direction;
  } YOYO_BIO;

YOYO_BIO *Bio_Input(void *strm)
#ifdef _YOYO_BIO_BUILTIN
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    YOYO_BIO_Destruct},
        {Oj_Read_OjMID,        Buffer_File_Read},
      };
    YOYO_BIO *bio = __Object(sizeof(YOYO_BIO),funcs);
    bio->direction = YOYO_BIO_READ;
    bio->inout = (int(*)(void*,void*,int,int))Yo_Find_Method_Of(&strm,Oj_Read_OjMID,YO_RAISE_ERROR)
    bio->strm = __Refe(strm);
    return bio;
  }
#endif  
  ;
  
YOYO_BIO *Bio_Output(void *strm)
#ifdef _YOYO_BIO_BUILTIN
  {
    static YOYO_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    YOYO_BIO_Destruct},
        {Oj_Write_OjMID,       Bio_Write},
        {Oj_Flush_OjMID,       Bio_Flush},
      };
      
    YOYO_BIO *bio = __Object(sizeof(YOYO_BIO),funcs);
    bio->direction = YOYO_BIO_WRITE;
    bio->inout = (int(*)(void*,void*,int,int))Yo_Find_Method_Of(&strm,Oj_Write_OjMID,YO_RAISE_ERROR)
    bio->strm  = __Refe(strm);
    return bio;
  }
#endif  
  ;

void Bio_Flush(YOYO_BIO *bio)
#ifdef _YOYO_BIO_BUILTIN
  {
    /* output bio doesn´t use bf.start */
    if ( bio->direction != YOYO_BIO_WRITE )
      __Raise(YOYO_ERROR_UNSUPPORTED,__yoTa("input BIO doesn't support Flush"));
    if ( bio->bf.data )
      bio->inout(bio->strm,bio->bf.data,bio->bf.end);
    bio->bf.end = 0;
    Oj_Flush(bio->strm);
  }
#endif
  ;
  
int Bio_Write(YOYO_BIO *bio,void *dta,int count,int mincount)
#ifdef _YOYO_BIO_BUILTIN
  {
    /* output bio doesn´t use bf.start */
    int q,cc=0;
    
    if ( bio->direction != YOYO_BIO_WRITE )
      __Raise(YOYO_ERROR_UNSUPPORTED,__yoTa("input BIO doesn't support Write"));
    
    while ( cc != count )
      {
        q = Yo_MIN(count-cc,(sizeof(bio->bf.data)-bio->bf.end));
        
        if ( q )
          {
            memcpy(bio->bf.data+bio->bf.end,(char*)dta+cc,q);
            bio->bf.end += q;
            cc += q;
          }
        
        if ( bio->bf.end == sizeof(bio->bf.data) )
          {
            bio->inout(bio->strm,bio->bf.data,bio->bf.end,bio->bf.end);
            bio->bf.end = 0;
          }
      }
       
    return cc;
  }
#endif
  ;

int _Bio_Fill_Buffer(YOYO_BIO *bio, int read_or_die)
#ifdef _YOYO_BIO_BUILTIN
  {
    bio->bf.start = 0;
    bio->bf.end = 0;
    q = bio->inout(bio->strm,bio->bf.data,sizeof(bio->bf.data),read_or_die?1:0);
    bio->bf.end = q;

    if ( !q && read_or_die ) 
      __Raise(YOYO_ERROR_UNEXPECTED,__yoTa("chained read should return least 1 byte or die!",0))
  }
#endif
  ;
  
int Bio_Read(YOYO_BIO *bio,void *out,int count,int mincount)
#ifdef _YOYO_BIO_BUILTIN
  {
    int q,cc = 0;
    if ( bio->direction != YOYO_BIO_READ )
      __Raise(YOYO_ERROR_UNSUPPORTED,__yoTa("output BIO doesn't support Read"));
    
    if ( !count ) return 0;
    
    while ( cc != count )
      {
        q = Yo_MIN(count-cc,(bio->bf.end-bio->bf.start));

        if ( !q )
          {
            if ( mincount <= cc ) return cc;
            _Bio_Fill_Buffer(bio,mincount);     
          }
        else
          {        
            STRICT_REQUIRE(bio->bf.start < bio->bf.end);
            STRICT_REQUIRE(bio->bf.start+q <= bio->bf.end);
            memcpy((char*)dta+cc,bio->bf.data+bio->bf.start,q);
            bio->bf.start += q;
            cc += q;
          }
      }
    
    return cc;
  }
#endif
  ;

char *Bio_Read_Line(YOYO_BIO *bio, YOYO_BUFFER *bf)
#ifdef _YOYO_BIO_BUILTIN
  {
    int i, E;
    YOYO_BUFFER *out = bf;
    if ( !out ) out  = Buffer_Init(0);
    out->count = 0;
    
    for(;;)
      {
        char *p;
        if ( bio->bf.end == bio->bf.start )
          {
            _Bio_Fill_Buffer(bio,0);
            if ( bio->bf.end == bio->bf.start ) break;
          }
        Buffer_Grow_Reserve(out,out->count+128+1);
        p = (char*)bio->bf.data+bio->bf.start;
        for ( i = 0, E = Yo_MIN((bio->bf.end-bio->bf.start),128); i < E; ++i )
          {
            if ( p[i] == '\n' ) { ++i; break; }
          }
        memcpy(out->at,bio->bf.data+bio->bf.start,i);
        out->count += i;
        bio->bf.start += i;
        if ( i && out->at[out->count-1] == '\r' ) --out->count;
        out->at[out->count] = 0;
      }
    
    if ( !bf )
      {
        char *r = Buffer_Take_Data(out);
        __Unrefe(out);
        return r;
      }
    else
      return bf->at;
  }
#endif 
  ;

int Bio_Copy_Into(YOYO_BIO *bio, void *strm, int count)
#ifdef _YOYO_BIO_BUILTIN
  {
    byte_t bf[512];
    int i;
    int (*oj_read)(void*,void*,int,int) = 
      ((int(*)(void*,void*,int,int))Yo_Find_Method_Of(&strm,Oj_Read_OjMID,YO_RAISE_ERROR));
    for ( i = 0; i < count || count < 0; )
      {
        int l = oj_read(strm,bf,sizeof(bf),0);
        if ( l ) 
          {
            Bio_Write(bio,bf,l,l);
            i += l;
          }
        else if ( count < 0 )
          break;
        else
          __Raise(YOYO_ERROR_IO_EOF,__yoTa("stream out of data",0));
      }
    return i;
  }
#endif 
  ;

int Bio_Copy_From(YOYO_BIO *bio, void *strm, int count)
#ifdef _YOYO_BIO_BUILTIN
  {
    byte_t bf[512];
    int i;
    int (*oj_write)(void*,void*,int,int) = 
      ((int(*)(void*,void*,int,int))Yo_Find_Method_Of(&strm,Oj_Write_OjMID,YO_RAISE_ERROR));
    for ( i = 0; i < count || count < 0; )
      {
        int l = Bio_Read(bio,bf,sizeof(bf),0);
        if ( l ) 
          {
            oj_write(strm,bf,l,l);
            i += l;
          }
        else if ( count < 0 )
          break;
        else
          __Raise(YOYO_ERROR_IO_EOF,__yoTa("stream out of data",0));
      }
    return i;
  }
#endif 
  ;

void Bio_Reset(YOYO_BIO *bio)
#ifdef _YOYO_BIO_BUILTIN
  {
    bio->bf.start = bio->bf.end = 0;
  }
#endif 
  ;

#endif /* C_once_91A90154_CD39_414F_9D05_4B45029B172F */
