
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

#ifndef C_once_324CA35F_3399_4699_91FD_FC523999882D
#define C_once_324CA35F_3399_4699_91FD_FC523999882D

#ifdef _LIBYOYO
#define _YOYO_PICTPNG_BUILTIN
#endif

#include "picture.hc"

#ifdef _YOYO_PICTPNG_BUILTIN
#include <png.h>
#include <pngstruct.h>

static void Pict_From_PNG_Read_Data(png_structp png_ptr, void *dest, png_size_t count)
  {
    byte_t **p = png_ptr->io_ptr;
    if ( *p + count > p[1] ) 
      png_error(png_ptr, "png read error in Pict_From_PNG_Read_Data"); 
    memcpy(dest,*p,count);
    *p += count;
  }

#endif

#define Pict_From_PNG(Bytes,Count) Pict_From_PNG_Specific(Bytes,Count,YOYO_RGBA8_PICTURE)
YOYO_PICTURE *Pict_From_PNG_Specific(void *bytes, int count, int format)
#ifdef _YOYO_PICTPNG_BUILTIN
  {
    YOYO_PICTURE *pict = __Object_Dtor(sizeof(YOYO_PICTURE),YOYO_PICTURE_Destruct);
    pict->format = format;
    
    __Auto_Release
      {
        png_struct* png_ptr;
        png_info*   info_ptr;
        byte_t*     read_ptr[2];
        int         stride;
        byte_t     *row;
        int         jformat;
        int         i;
        
        if ( !png_check_sig(bytes,8) )
          __Raise(YOYO_ERROR_UNSUPPORTED,"is not PNG image");

        png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING,0,0,0);
        info_ptr = png_create_info_struct(png_ptr);
        
        if ( !setjmp(png_jmpbuf(png_ptr)) ) 
          {
            int bpp;
            read_ptr[0] = (byte_t*)bytes+8;
            read_ptr[1] = (byte_t*)bytes+(count-8);
            png_set_read_fn(png_ptr,read_ptr,Pict_From_PNG_Read_Data);
            png_set_sig_bytes(png_ptr,8);
            png_read_info(png_ptr,info_ptr);
            png_set_strip_16(png_ptr);
            png_set_packing(png_ptr);
      
            if ( png_ptr->bit_depth < 8 
              || png_ptr->color_type == PNG_COLOR_TYPE_PALETTE
              || png_get_valid(png_ptr,info_ptr,PNG_INFO_tRNS) )
              png_set_expand(png_ptr);
      
            png_read_update_info(png_ptr,info_ptr);
            pict->width  = png_get_image_width(png_ptr,info_ptr);
            pict->height = png_get_image_height(png_ptr,info_ptr);

            if (  png_ptr->color_type == PNG_COLOR_TYPE_RGB_ALPHA )
              bpp = 4;
            else 
              bpp = 3;

            stride = (bpp*pict->width + 7) & ~3;
            jformat = (bpp==4?YOYO_RGBA8_PICTURE:YOYO_RGB8_PICTURE);
            if ( jformat != pict->format )
              row = __Malloc(stride);
          }
        else
          {
            if ( !setjmp(png_jmpbuf(png_ptr)) )
              png_destroy_read_struct(&png_ptr,&info_ptr,0);
            __Raise(YOYO_ERROR_CORRUPTED,"failed to decode PNG info");
          }
          
        Pict_Allocate_Buffer(pict);
        
        if ( !setjmp(png_jmpbuf(png_ptr)) ) 
          {
            for ( i = 0; i < pict->height; ++i )
              {
                if ( jformat != pict->format )
                  {
                    png_read_row(png_ptr,row,0);
                    Pict_Convert_Pixels_Row(
                      row,jformat,
                      pict->pixels+i*pict->pitch, pict->format,
                      pict->width);
                  }
                else
                  png_read_row(png_ptr,pict->pixels+i*pict->pitch,0);
              }
            //png_read_end(png_ptr,info_ptr);
          }
        else
          {
            if ( !setjmp(png_jmpbuf(png_ptr)) )
              png_destroy_read_struct(&png_ptr,&info_ptr,0);
            __Raise(YOYO_ERROR_CORRUPTED,"failed to decode PNG bits");
          }
      }
      
    return pict;
  }
#endif
  ;

#define Pict_From_PNG_File(Filename) Pict_From_PNG_File_Specific(Filename,YOYO_RGBA8_PICTURE)
YOYO_PICTURE *Pict_From_PNG_File_Specific(char *filename, int format)
#ifdef _YOYO_PICTPNG_BUILTIN
  {
    YOYO_PICTURE *pict = 0;
    __Auto_Ptr(pict)
      {
        YOYO_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"r"));
        pict = Pict_From_PNG_Specific(bf->at,bf->count,format);
      }
    return pict;
  }
#endif
  ;

#endif /* C_once_324CA35F_3399_4699_91FD_FC523999882D */

