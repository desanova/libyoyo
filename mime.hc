
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

#ifndef C_once_E5DC0CBD_6EF6_4E8C_A4F5_CF78FA971011
#define C_once_E5DC0CBD_6EF6_4E8C_A4F5_CF78FA971011

enum
  {
    YOYO_MIME_NONE  = __FOUR_CHARS('`','`','`','`'),
    YOYO_MIME_OCTS  = __FOUR_CHARS('O','C','T','S'),
    YOYO_MIME_JPEG  = __FOUR_CHARS('J','P','E','G'),
    YOYO_MIME_PNG   = __FOUR_CHARS('x','P','N','G'),
    YOYO_MIME_GIF   = __FOUR_CHARS('x','G','I','F'),
    YOYO_MIME_PICT  = __FOUR_CHARS('P','I','C','T'),
    YOYO_MIME_HTML  = __FOUR_CHARS('H','T','M','L'),
    YOYO_MIME_TEXT  = __FOUR_CHARS('T','E','X','T'),
    YOYO_MIME_GZIP  = __FOUR_CHARS('G','Z','I','P'),
    YOYO_MIME_PKZIP = __FOUR_CHARS('x','Z','I','P'),
    YOYO_MIME_7ZIP  = __FOUR_CHARS('7','Z','I','P'),
    YOYO_MIME_APP   = __FOUR_CHARS('x','A','P','P'),
    YOYO_MIME_UNKNOWN = -1,
  };

int Mime_Code_Of(char *mime_type)
  {
    int i;
    char S[80] = {0};
    for ( i = 0; mime_type[i] && i < sizeof(S)-1; ++i ) S[i] = tolower(mime_type[i]);
    if ( !strncmp(S,"application/",12) )
      {
        if ( !strcmp(S+12,"octet-stream") ) return YOYO_MIME_OCTS;
        return YOYO_MIME_APP;
      }
    else if ( !strncmp(S,"text/",5) )
      {
        if ( !strcmp(S+7,"html") ) return YOYO_MIME_HTML;
        else return YOYO_MIME_TEXT;
      }
    else if ( !strncmp(S,"image/",6) )
      {
        if ( !strcmp(S+6,"jpeg") ) return YOYO_MIME_JPEG;
        if ( !strcmp(S+6,"png") )  return YOYO_MIME_PNG;
        if ( !strcmp(S+6,"gif") )  return YOYO_MIME_GIF;
        return YOYO_MIME_PICT;
      }
    return YOYO_MIME_NONE;
  }
  
int Mime_Is_Image(int mime)
  {
    switch(mime)
      {
        case YOYO_MIME_JPEG:  
        case YOYO_MIME_PNG:   
        case YOYO_MIME_GIF: 
        case YOYO_MIME_PICT: 
          return 1;
      }
    return 0;
  }
  
int Mime_Is_Compressed(int mime)
  {
    switch(mime)
      {
        case YOYO_MIME_JPEG:  
        case YOYO_MIME_PNG:   
        case YOYO_MIME_GIF: 
        case YOYO_MIME_GZIP: 
        case YOYO_MIME_PKZIP: 
        case YOYO_MIME_7ZIP: 
          return 1;
      }
    return 0;
  }

int Mime_Is_Text(int mime)
  {
    switch(mime)
      {
        case YOYO_MIME_HTML:
        case YOYO_MIME_TEXT:
          return 1;
      }
    return 0;
  }

int Mime_Is_Binary(int mime)
  {
    return !Mime_Is_Text(mime);
  }

#define Mime_String_Of_Npl(Mime) Str_Copy_Npl(Mime_String_Of(Mime),-1)
char *Mime_String_Of(int mime)
  {
    switch(mime)
      {
        case YOYO_MIME_OCTS: return "application/octet-stream";
        case YOYO_MIME_JPEG: return "image/jpeg";
        case YOYO_MIME_PNG:  return "image/png";
        case YOYO_MIME_GIF:  return "image/gif";
        case YOYO_MIME_PICT: return "image/octet-stream";
        case YOYO_MIME_HTML: return "text/html";
        case YOYO_MIME_TEXT: return "text/plain";
        case YOYO_MIME_GZIP: return "application/x-gzip";
        case YOYO_MIME_PKZIP:return "application/zip";
        case YOYO_MIME_7ZIP: return "application/x-7zip";
        case YOYO_MIME_APP:  return "application/octet-stream";
      }
    return "application/octet-stream";
  }
  
#endif /* C_once_E5DC0CBD_6EF6_4E8C_A4F5_CF78FA971011 */

