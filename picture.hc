
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

#ifndef C_once_E194EBE7_E43F_4305_A75C_3872532B12DB
#define C_once_E194EBE7_E43F_4305_A75C_3872532B12DB

#ifdef _LIBYOYO
#define _YOYO_PICTURE_BUILTIN
#endif

#include "yoyo.hc"

enum
  {
    YOYO_PAL8_PICTURE  = __FOUR_CHARS('P',1,'8',0),
    YOYO_RGBAf_PICTURE = __FOUR_CHARS('R',16,'f','A'),
    YOYO_RGB8_PICTURE  = __FOUR_CHARS('R',3,'8',0),
    YOYO_RGB5_PICTURE  = __FOUR_CHARS('R',2,'5',0),
    YOYO_RGB6_PICTURE  = __FOUR_CHARS('R',2,'6',0),
    YOYO_RGBA8_PICTURE = __FOUR_CHARS('R',4,'8','A'),
    YOYO_RGBX8_PICTURE = __FOUR_CHARS('R',4,'8',0),
    YOYO_RGB5A1_PICTURE= __FOUR_CHARS('R',2,'5','A'),
    YOYO_BGR8_PICTURE  = __FOUR_CHARS('B',3,'8',0),
    YOYO_BGR5_PICTURE  = __FOUR_CHARS('B',2,'5',0),
    YOYO_BGR6_PICTURE  = __FOUR_CHARS('B',2,'6',0),
    YOYO_BGRA8_PICTURE = __FOUR_CHARS('B',4,'8','A'),
    YOYO_BGRX8_PICTURE = __FOUR_CHARS('B',4,'8',0),
    YOYO_BGR5A1_PICTURE= __FOUR_CHARS('B',2,'5','A'),
  };

#define Pict_Format_Bytes_PP(Fmt) ((Fmt>>8)&0x0ff)

typedef struct _YOYO_PICTURE
  {
    int width;
    int height;
    int pitch;
    int weight;
    int format;
    byte_t *pixels;
  } YOYO_PICTURE;

void YOYO_PICTURE_Destruct(YOYO_PICTURE *pict)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    free(pict->pixels);
    __Destruct(pict);
  }
#endif
  ;

typedef struct _YOYO_RGBA8
  {
    byte_t r;
    byte_t g;
    byte_t b;
    byte_t a;
  } YOYO_RGBA8;

typedef struct _YOYO_BGRA8
  {
    byte_t b;
    byte_t g;
    byte_t r;
    byte_t a;
  } YOYO_BGRA8;

typedef struct _YOYO_RGBAf
  {
    float r;
    float g;
    float b;
    float a;
  } YOYO_RGBAf;

typedef struct _YOYO_RGB8
  {
    byte_t r;
    byte_t g;
    byte_t b;
  } YOYO_RGB8;

typedef struct _YOYO_BGR8
  {
    byte_t b;
    byte_t g;
    byte_t r;
  } YOYO_BGR8;

YOYO_RGBA8 Pict_Get_RGBA8_Pixel(byte_t *ptr, int format)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    switch ( format )
      {
        case YOYO_RGBA8_PICTURE:
          return *(YOYO_RGBA8*)ptr;
        case YOYO_RGB8_PICTURE:
          {
            YOYO_RGBA8 rgba;
            rgba.r = ((YOYO_RGB8*)ptr)->r;
            rgba.g = ((YOYO_RGB8*)ptr)->g;
            rgba.b = ((YOYO_RGB8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case YOYO_RGBX8_PICTURE:
          {
            YOYO_RGBA8 rgba;
            rgba.r = ((YOYO_RGB8*)ptr)->r;
            rgba.g = ((YOYO_RGB8*)ptr)->g;
            rgba.b = ((YOYO_RGB8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case YOYO_BGR8_PICTURE:
          {
            YOYO_RGBA8 rgba;
            rgba.r = ((YOYO_BGR8*)ptr)->r;
            rgba.g = ((YOYO_BGR8*)ptr)->g;
            rgba.b = ((YOYO_BGR8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case YOYO_BGRX8_PICTURE:
          {
            YOYO_RGBA8 rgba;
            rgba.r = ((YOYO_BGRA8*)ptr)->r;
            rgba.g = ((YOYO_BGRA8*)ptr)->g;
            rgba.b = ((YOYO_BGRA8*)ptr)->b;
            rgba.a = 0xff;
            return rgba;
          }
        case YOYO_BGRA8_PICTURE:
          {
            YOYO_RGBA8 rgba;
            rgba.r = ((YOYO_BGRA8*)ptr)->r;
            rgba.g = ((YOYO_BGRA8*)ptr)->g;
            rgba.b = ((YOYO_BGRA8*)ptr)->b;
            rgba.a = ((YOYO_BGRA8*)ptr)->a;
            return rgba;
          }
        case YOYO_RGBAf_PICTURE:
          {
            YOYO_RGBA8 rgba;
            rgba.r = (byte_t)(Yo_MAX(((YOYO_RGBAf*)ptr)->r + .5f ,1.f) * 255.f);
            rgba.g = (byte_t)(Yo_MAX(((YOYO_RGBAf*)ptr)->g + .5f ,1.f) * 255.f);
            rgba.b = (byte_t)(Yo_MAX(((YOYO_RGBAf*)ptr)->b + .5f ,1.f) * 255.f);
            rgba.a = (byte_t)(Yo_MAX(((YOYO_RGBAf*)ptr)->a + .5f ,1.f) * 255.f);
            return rgba;
          }
        default:
          {
            YOYO_RGBA8 rgba = {0};
            __Raise(YOYO_ERROR_UNSUPPORTED,"bad pixel format");
            return rgba;
          }
      }
  }
#endif
  ;

YOYO_RGBA8 Pict_Get_RGBA8(YOYO_PICTURE *pict, int x, int y)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    byte_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    
    if ( pict->format == YOYO_RGBA8_PICTURE )
      return *(YOYO_RGBA8*)ptr;
    
    return Pict_Get_RGBA8_Pixel(ptr, pict->format);
  }
#endif
  ;

YOYO_RGBAf Pict_Get_RGBAf_Pixel(byte_t *ptr, int format)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    if ( format == YOYO_RGBAf_PICTURE )
      return *(YOYO_RGBAf*)ptr;
    else if ( format == YOYO_RGBA8_PICTURE )
      {
        YOYO_RGBAf rgba;
        rgba.r = (((YOYO_RGBA8*)ptr)->r + .5f) / 255.f;
        rgba.g = (((YOYO_RGBA8*)ptr)->g + .5f) / 255.f;
        rgba.b = (((YOYO_RGBA8*)ptr)->b + .5f) / 255.f;
        rgba.a = (((YOYO_RGBA8*)ptr)->a + .5f) / 255.f;
        return rgba;
      }
    else
      {
        YOYO_RGBA8 tmp = Pict_Get_RGBA8_Pixel(ptr,format);
        YOYO_RGBAf rgba;
        rgba.r = (tmp.r + .5f) / 255.f;
        rgba.g = (tmp.g + .5f) / 255.f;
        rgba.b = (tmp.b + .5f) / 255.f;
        rgba.a = (tmp.a + .5f) / 255.f;
        return rgba;
      }
  }
#endif
  ;

void Pict_Set_RGBA8_Pixel(byte_t *ptr, YOYO_RGBA8 pix, int format)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    switch ( format )
      {
        case YOYO_RGBA8_PICTURE:
          *(YOYO_RGBA8*)ptr = pix;
          break;
        case YOYO_RGB8_PICTURE:
          ((YOYO_RGB8*)ptr)->r = pix.r;
          ((YOYO_RGB8*)ptr)->g = pix.g;
          ((YOYO_RGB8*)ptr)->b = pix.b;
          break;
        case YOYO_RGBX8_PICTURE:
          ((YOYO_RGBA8*)ptr)->r = pix.r;
          ((YOYO_RGBA8*)ptr)->g = pix.g;
          ((YOYO_RGBA8*)ptr)->b = pix.b;
          ((YOYO_RGBA8*)ptr)->a = 0;
          break;
        case YOYO_BGR8_PICTURE:
          ((YOYO_BGRA8*)ptr)->r = pix.r;
          ((YOYO_BGRA8*)ptr)->g = pix.g;
          ((YOYO_BGRA8*)ptr)->b = pix.b;
          break;
        case YOYO_BGRX8_PICTURE:
          ((YOYO_BGRA8*)ptr)->r = pix.r;
          ((YOYO_BGRA8*)ptr)->g = pix.g;
          ((YOYO_BGRA8*)ptr)->b = pix.b;
          ((YOYO_BGRA8*)ptr)->a = 0;
          break;
        case YOYO_BGRA8_PICTURE:
          ((YOYO_BGRA8*)ptr)->r = pix.r;
          ((YOYO_BGRA8*)ptr)->g = pix.g;
          ((YOYO_BGRA8*)ptr)->b = pix.b;
          ((YOYO_BGRA8*)ptr)->a = pix.a;
          break;
        case YOYO_RGBAf_PICTURE:
          ((YOYO_RGBAf*)ptr)->r = (pix.r + .5f) / 255.f;
          ((YOYO_RGBAf*)ptr)->g = (pix.g + .5f) / 255.f;
          ((YOYO_RGBAf*)ptr)->b = (pix.b + .5f) / 255.f;
          ((YOYO_RGBAf*)ptr)->a = (pix.a + .5f) / 255.f;
          break;
        default:
          __Raise(YOYO_ERROR_UNSUPPORTED,"bad pixel format");
      }
  }
#endif
  ;

void Pict_Set_RGBA8(YOYO_PICTURE *pict, int x, int y, YOYO_RGBA8 pix)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    byte_t *ptr = pict->pixels + (pict->pitch * y + x * pict->weight);
    
    if ( pict->format == YOYO_RGBA8_PICTURE )
      *(YOYO_RGBA8*)ptr = pix;
    
    Pict_Set_RGBA8_Pixel(pict->pixels + (pict->pitch * y + x * pict->weight), pix, pict->format);
  }
#endif
  ;

void Pict_Allocate_Buffer(YOYO_PICTURE *pict)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    if ( pict->pixels ) 
      __Raise(YOYO_ERROR_ALREADY_EXISTS,"pixel buffer already exists");
    
    switch( pict->format )
      {
        case YOYO_RGBA8_PICTURE:
        case YOYO_RGBX8_PICTURE:
          pict->pitch  = sizeof(YOYO_RGBA8)*pict->width;
          pict->weight = sizeof(YOYO_RGBA8);
          break;
        case YOYO_RGB8_PICTURE:
          pict->pitch  = sizeof(YOYO_RGB8)*pict->width;
          pict->weight = sizeof(YOYO_RGB8);
          break;
        case YOYO_BGRA8_PICTURE:
        case YOYO_BGRX8_PICTURE:
          pict->pitch  = sizeof(YOYO_BGRA8)*pict->width;
          pict->weight = sizeof(YOYO_BGRA8);
          break;
        case YOYO_BGR8_PICTURE:
          pict->pitch  = sizeof(YOYO_BGR8)*pict->width;
          pict->weight = sizeof(YOYO_BGR8);
          break;
        case YOYO_RGBAf_PICTURE:
          pict->pitch  = sizeof(YOYO_RGBAf)*pict->width;
          pict->weight = sizeof(YOYO_RGBAf);
          break;
        default:
          __Raise(YOYO_ERROR_UNSUPPORTED,"bad pixel format");
      }
      
    pict->pixels = __Malloc_Npl(pict->pitch*pict->height);
  }
#endif
  ;
  
void Pict_Nullify_Transparent_Pixels(YOYO_PICTURE *pict, byte_t threshold)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    if ( pict->format == YOYO_RGBA8_PICTURE || pict->format == YOYO_BGRA8_PICTURE )
      {
        int i;
        for ( i = 0; i < pict->height; ++i )
          {
            YOYO_RGBA8 *pixel = (YOYO_RGBA8 *)(pict->pixels+i*pict->pitch);
            YOYO_RGBA8 *pixelE = pixel+pict->width;
            for ( ; pixel < pixelE; ++pixel  )
              if ( pixel->a < threshold ) 
                memset(pixel,0,sizeof(*pixel));
          }
      }
  }
#endif
  ;
  
void Pict_Convert_Pixels_Row(byte_t *src, int src_format, byte_t *dst, int dst_format, int count )
#ifdef _YOYO_PICTURE_BUILTIN
  {
    int i;
    int src_weight = ((src_format >> 8) & 0x0ff);
    int dst_weight = ((dst_format >> 8) & 0x0ff);
    byte_t *src_pixel = src;
    byte_t *dst_pixel = dst;
    if ( src_format == dst_format )
      {
        memcpy(dst,src,count*dst_weight);
      }
    else if ( dst_format  == YOYO_RGBAf_PICTURE )
      for ( i = 0; i < count; ++i )
        {
          *(YOYO_RGBAf*)dst_pixel = Pict_Get_RGBAf_Pixel(src_pixel,src_format);
          src_pixel += src_weight;
          dst_pixel += dst_weight;
        }
    else if ( dst_format  == YOYO_RGBA8_PICTURE )
      for ( i = 0; i < count; ++i )
        {
          *(YOYO_RGBA8*)dst_pixel = Pict_Get_RGBA8_Pixel(src_pixel,src_format);
          src_pixel += src_weight;
          dst_pixel += dst_weight;
        }
    else
      for ( i = 0; i < count; ++i )
        {
          YOYO_RGBA8 tmp = Pict_Get_RGBA8_Pixel(src_pixel,src_format);
          Pict_Set_RGBA8_Pixel(dst_pixel,tmp,dst_format);
          src_pixel += src_weight;
          dst_pixel += dst_weight;
        }
  }
#endif
  ;
  
void Pict_Convert_Pixels_Row_Pal(byte_t *src, int src_format, byte_t *dst, int dst_format, int count, void *pal, int pal_count )
#ifdef _YOYO_PICTURE_BUILTIN
  {
    int i, bpp = Pict_Format_Bytes_PP(dst_format);
    byte_t palx[256*16]; /* sizeof(rgbaf) == 16 */
    Pict_Convert_Pixels_Row(pal,src_format,palx,dst_format,pal_count);
    if ( bpp == 4 )
      for ( i = 0; i < count; ++i )
        ((u32_t*)dst)[i] = ((u32_t*)palx)[src[i]];
    else if ( bpp == 2 )
      for ( i = 0; i < count; ++i )
        ((u32_t*)dst)[i] = ((u32_t*)palx)[src[i]];
    else
      for ( i = 0; i < count; ++i )
        memcpy((dst + i * bpp),palx + src[i]*bpp,bpp);
  }
#endif
  ;

#ifdef __windoze
HBITMAP Pict_Create_HBITMAP(YOYO_PICTURE *pict)
#ifdef _YOYO_PICTURE_BUILTIN
  {
    BITMAPINFOHEADER bi;
    HDC dc;
    HBITMAP bmp;
    byte_t *bits = 0;
    bi.biSize = sizeof(BITMAPINFOHEADER);
    bi.biWidth  = pict->width;
    bi.biHeight = -pict->height;
    bi.biPlanes = 1;
    bi.biBitCount = 32;
    bi.biCompression = BI_RGB;
    bi.biSizeImage = pict->width * pict->height * 4;
    dc  = GetDC(0);
    //bmp = CreateCompatibleBitmap(dc,pict->width,pict->height);
    //SetDIBits(dc,bmp,0,pict->height,pict->pixels,(BITMAPINFO*)&bi,DIB_RGB_COLORS);
    bmp = CreateDIBSection(dc, (BITMAPINFO*)&bi, DIB_RGB_COLORS, &bits, 0, 0);
    if ( pict->format == YOYO_BGRA8_PICTURE )
      memcpy(bits,pict->pixels,bi.biSizeImage);
    else
      {
        int i;
        for ( i = 0; i < pict->height; ++i )
          Pict_Convert_Pixels_Row(
              pict->pixels+i*pict->pitch,pict->format,
              bits+pict->width*4*i,YOYO_BGRA8_PICTURE,
              pict->width);          
      }
    ReleaseDC(0,dc);
    return bmp;
  }
#endif
  ;
#endif

#endif /* C_once_E194EBE7_E43F_4305_A75C_3872532B12DB */

