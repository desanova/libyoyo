
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

#ifndef C_once_F02ABD1D_F661_464B_8226_CBED6A3DA7CE
#define C_once_F02ABD1D_F661_464B_8226_CBED6A3DA7CE

#ifdef _LIBYOYO
#define _YOYO_PICTBMP_BUILTIN
#endif

#include "picture.hc"  
#include "buffer.hc"
#include "file.hc"

#ifdef _YOYO_PICTBMP_BUILTIN

enum { YOYO_BI_BITFIELDS = 3, YOYO_BI_RGB = 0, };

#pragma pack(push,2)
typedef struct _YOYO_BITMAPFILEHEADER 
  {
    u16_t  bfType;
    u32_t  bfSize;
    u16_t  bfReserved1;
    u16_t  bfReserved2;
    u32_t  bfOffBits;
  } YOYO_BITMAPFILEHEADER;
typedef struct _YOYO_BITMAPINFOHEADER
  {
    u32_t  biSize;
    i32_t  biWidth;
    i32_t  biHeight;
    u16_t  biPlanes;
    u16_t  biBitCount;
    u32_t  biCompression;
    u32_t  biSizeImage;
    i32_t  biXPelsPerMeter;
    i32_t  biYPelsPerMeter;
    u32_t  biClrUsed;
    u32_t  biClrImportant;
  } YOYO_BITMAPINFOHEADER;
#pragma pack(pop)

#endif

#define Pict_From_BMP(Bytes,Count) Pict_From_BMP_Specific(Bytes,Count,YOYO_RGBA8_PICTURE)
YOYO_PICTURE *Pict_From_BMP_Specific(void *bytes, int count, int format)
#ifdef _YOYO_PICTBMP_BUILTIN
  {
    YOYO_PICTURE *pict = __Object_Dtor(sizeof(YOYO_PICTURE),YOYO_PICTURE_Destruct);
    pict->format = format;

    if ( !pict->format ) pict->format = YOYO_RGBA8_PICTURE;
    
    __Auto_Release
      {
        YOYO_BITMAPFILEHEADER *bmFH = bytes;
        YOYO_BITMAPINFOHEADER *bmIH = (YOYO_BITMAPINFOHEADER *)((char*)bytes + sizeof(YOYO_BITMAPFILEHEADER));
        u32_t  *palette = (u32_t*)((char*)bmIH+bmIH->biSize);
        byte_t *image  = (byte_t*)bmFH+bmFH->bfOffBits;
        
        if ( (bmFH->bfType == 0x4D42) && (bmFH->bfSize <= count) )
          {
            int bpp = (bmIH->biBitCount/8);
            int stride, jformat, i;
            byte_t *row = 0;
            if ( bmIH->biCompression != YOYO_BI_RGB )
              __Raise(YOYO_ERROR_CORRUPTED,"supporting BI_RGB comression bitmaps only");
            
            switch ( bmIH->biBitCount )
              {
                case 32: jformat = YOYO_BGRA8_PICTURE; break;
                case 24: jformat = YOYO_BGR8_PICTURE; break;
                case 8:  jformat = YOYO_PAL8_PICTURE; break;
                case 16:
                  if ( bmIH->biCompression == YOYO_BI_BITFIELDS && palette[1] != 0x03e0 )
                    jformat = YOYO_BGR6_PICTURE;
                  else
                    jformat = YOYO_BGR5A1_PICTURE; 
                  break;
                default:
                  __Raise_Format(YOYO_ERROR_CORRUPTED,("bitCount %d is not supported",bmIH->biBitCount));
              }
            
            stride = (bmIH->biWidth*Pict_Format_Bytes_PP(jformat) + 3) & ~3;
            pict->width  = bmIH->biWidth;
            pict->height = Yo_Absi(bmIH->biHeight); /* sign selects direction of rendering rows down-to-up or up-to-down*/
            Pict_Allocate_Buffer(pict);

            for ( i = 0; i < pict->height; ++i )
              {
                int l = (bmIH->biHeight < 0) ? i : pict->height - i - 1; 
                if ( jformat != pict->format )
                  {
                    if ( jformat == YOYO_PAL8_PICTURE )
                      Pict_Convert_Pixels_Row_Pal(
                        image + l*stride, YOYO_BGRX8_PICTURE,
                        pict->pixels+i*pict->pitch, pict->format,
                        pict->width,
                        palette, bmIH->biClrUsed);
                    else
                      Pict_Convert_Pixels_Row(
                        image + l*stride, jformat,
                        pict->pixels+i*pict->pitch, pict->format,
                        pict->width);
                  }
                else
                  memcpy(pict->pixels+i*pict->pitch, image + l*stride, pict->width*Pict_Format_Bytes_PP(jformat));
              }
          }
      }
      
    return pict;
  }
#endif
  ;
  
#define Pict_From_BMP_File(Filename) Pict_From_BMP_File_Specific(Filename,YOYO_RGBA8_PICTURE)
YOYO_PICTURE *Pict_From_BMP_File_Specific(char *filename, int format)
#ifdef _YOYO_PICTBMP_BUILTIN
  {
    YOYO_PICTURE *pict = 0;
    __Auto_Ptr(pict)
      {
        YOYO_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"r"));
        pict = Pict_From_BMP_Specific(bf->at,bf->count,format);
      }
    return pict;
  }
#endif
  ;

#endif /* C_once_F02ABD1D_F661_464B_8226_CBED6A3DA7CE */
