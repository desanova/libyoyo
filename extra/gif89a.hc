
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

#ifndef C_once_E194EBE7_E43F_4305_A75C_3872532B12DB
#define C_once_E194EBE7_E43F_4305_A75C_3872532B12DB

#include "../libyoyo.hc"

enum
  {
    YOYO_RGBA8_PICTURE = __FOUR_CHARS('R','3','8','A'),
    YOYO_RGBAf_PICTURE = __FOUR_CHARS('R','3','f','A'),
  };

typedef struct _YOYO_PICTURE
  {
    int width;
    int height;
    int pitch;
    int weight;
    int format;
    byte_t *pixels;
  } YOYO_PICTURE;

typedef struct _YOYO_RGBA8
  {
    byte_t r;
    byte_t g;
    byte_t b;
    byte_t a;
  } YOYO_RGBA8;

typedef struct _YOYO_RGBAf
  {
    float r;
    float g;
    float b;
    float a;
  } YOYO_RGBAf;

//YOYO_PICTURE *Pict_Convert(YOYO_PICTURE *pict, int format)
//  {
//  }

#ifdef __windoze
HBITMAP Pict_Create_HBITMAP(YOYO_PICTURE *pict)
#ifdef _YOYO_PICTURE_BUILTIN
  {
  }
#endif
  ;
#endif

//YOYO_RGBA8 Pict_Get_RGBA8(YOYO_PICTURE *pic, int x, int y)
//  {
//  }
//
//void Pict_Set_RGBA8(YOYO_PICTURE *pic, int x, int y, YOYO_RGBA8 pix)
//  {
//  }

void Pict_Allocate_Buffer(YOYO_PICTIRE *pict)
  {
    if ( pict->pixels ) 
      __Raise(YOYO_ERROR_ALREADY_EXISTS,"pixel buffer already allocated");
    
    if ( pict->format == YOYO_RGBA8_PICTURE )
      {
        pict->pitch  = sizeof(YOYO_RGBA8)*pict->width;
        pict->wight  = sizeof(YOYO_RGBA8);
      }
    else if ( pict->format == YOYO_RGBAf_PICTURE )
      {
        pict->pitch  = sizeof(YOYO_RGBAf)*pict->width;
        pict->wight  = sizeof(YOYO_RGBAf);
      }
    else
      __Raise(YOYO_ERROR_UNSUPPORTED,"pixel format unsupported");
      
    pict->pixels = __Malloc_Npl(pict->pitch*pict->height);
  }

#define Pict_From_Gif89a(Bytes,Count) Pict_From_Gif89a_Specific(Bytes,Count,YOYO_RGBA8_PICTURE)
YOYO_PICTIRE *Pict_From_Gif89a_Specific(void *bytes, int count, int format)
#ifdef _YOYO_GIF89A_BUILTIN
  {
    YOYO_PICTURE *pict = __Object_Dtor(sizeof(YOYO_PICTURE),YOYO_PICTURE_Destruct);
    int i,j;
    int ptx = 6;
    int bgcolor_idx;
    int sizeof_color_table;
    int sizeof_local_table;
    int has_local_colors;
    
    YOYO_RGBA8 color_table[256] = {0};
    YOYO_RGBA8 local_table[256] = {0};
    YOYO_RGBA8 *colors = 0;

    if ( memcmp(bytes,"GIF89a",6) && memcmp(bytes,"GIF87a",6) )
      __Raise(YOYO_ERROR_UNSUPPORTED,"is not GIF image");
    
    pict->format = format;
    pict->width  = Two_To_Unsigned(bytes+ptx); ptx += 2;
    pict->height = Two_To_Unsigned(bytes+ptx); ptx += 2;
    sizeof_color_table = 1<<((*bytes&0x07)+1);
    ++ptx; /* Packed Value */
    bgcolor_idx = bytes[ptx++];
    ++ptx; /* Pixel Aspect Ratio */
    
    for ( i = 0; i < sizeof_color_table; ++i )
      {
        color_table[i].r = bytes[ptx++];
        color_table[i].g = bytes[ptx++];
        color_table[i].b = bytes[ptx++];
      }
      
    if ( *bytes[ptx++] != 0x2c )
      __Raise(YOYO_ERROR_CORRUPTED,"expected image separator");
      
    ptx += 2; /* left */
    ptx += 2; /* top */
    pict->width  = Two_To_Unsigned(bytes+ptx); ptx += 2;
    pict->height = Two_To_Unsigned(bytes+ptx); ptx += 2;
    has_local_colors = *bytes & 0x80;
    ++ptx;
    
    if ( has_local_colors )
      {
        for ( i = 0; i < sizeof_local_table; ++i )
          {
            local_table[i].r = bytes[ptx++];
            local_table[i].g = bytes[ptx++];
            local_table[i].b = bytes[ptx++];
          }
        colors = local_table;
      }
    else
      colors = color_table;
      
    Pict_Allocate_Buffer(pict);
    
    __Gogo /* LZW decoder */
      {
        int mincodelen = bytes[ptx++];
        int codelen = mincodelen;
        int bitsread = 0;
        byte_t *pixel_ptr = pict->pixels;
        
        for (;;)
          {
            /* get n bits */
            int code = 
            
            if ( format == YOYO_RGBA8_PICTURE )
              (YOYO_RGBA8*)pixel_ptr = colors[pixel];
            else
              Pict_Set_Pixel_From_RGBA8(pixel_ptr,colors[pixel],format);
            
            pixel_ptr += pict->weight;
          }
      }
  }
#endif
  ;
#endif /* C_once_E194EBE7_E43F_4305_A75C_3872532B12DB */

