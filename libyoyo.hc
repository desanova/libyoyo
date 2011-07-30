
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

#ifndef C_once_9C09BC1E_F80E_4C2D_8EF5_8B6E388D7975
#define C_once_9C09BC1E_F80E_4C2D_8EF5_8B6E388D7975

#ifdef _LIBYOYO
#define _YOYO_CORE_BUILTIN 
#define _YOYO_CRC_BUILTIN 
#define _YOYO_MD5_BUILTIN
#define _YOYO_SHA1_BUILTIN
#define _YOYO_SHA2_BUILTIN
#define _YOYO_ARRAY_BUILTIN
#define _YOYO_BUFFER_BUILTIN
#define _YOYO_FILE_BUILTIN
#define _YOYO_DICTO_BUILTIN
#define _YOYO_STRING_BUILTIN
#define _YOYO_PROG_BUILTIN
#define _YOYO_RANDOM_BUILTIN
#define _YOYO_WINREG_BUILTIN
#define _YOYO_CIPHER_BUILTIN
#define _YOYO_NEWDES96_BUILTIN
#define _YOYO_BLOWFISH_BUILTIN
#define _YOYO_AES_BUILTIN
#define _YOYO_PEFILE_BUILTIN
#define _YOYO_LZSS_BUILTIN
#define _YOYO_XDATA_BUILTIN
#define _YOYO_DEFPARS_BUILTIN
#define _YOYO_LOGOUT_BUILTIN
#define _YOYO_DATETIME_BUILTIN
#define _YOYO_BINGINT_BUILTIN
#endif

#include "core.hc"
#include "logout.hc"
#include "crc.hc"
#include "md5.hc"
#include "sha1.hc"
#include "sha2.hc"
#include "dicto.hc"
#include "array.hc"
#include "buffer.hc"
#include "string.hc"
#include "prog.hc"
#include "file.hc"
#include "random.hc"
#include "winreg.hc"
#include "cipher.hc"
#include "newdes96.hc"
#include "blowfish.hc"
#include "aes.hc"
#include "pefile.hc"
#include "lzss.hc"
#include "xdata.hc"
#include "defpars.hc"
#include "datetime.hc"
#include "bigint.hc"

/*
#define _YOYO_HTTPX_BUILTIN
#define _YOYO_TCPIP_BUILTIN
#include "tcpip.hc"
#include "httpx.hc"
*/

#endif /* C_once_9C09BC1E_F80E_4C2D_8EF5_8B6E388D7975 */

