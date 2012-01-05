
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

#ifndef C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC
#define C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC

#include "yoyo.hc"
#include "string.hc"
#include "file.hc"
#include "tcpip.hc"

#ifdef _LIBYOYO
#define _YOYO_HTTPX_BUILTIN
#endif

enum
  {
    YOYO_HTTPX_DOING_NOTHING      = 0,
    YOYO_HTTPX_IS_PREPARING       = 1,
    YOYO_HTTPX_IS_RESOLVING       = 2,
    YOYO_HTTPX_IS_CONNECTING      = 3,
    YOYO_HTTPX_IS_QUERYING        = 4,
    YOYO_HTTPX_IS_GETTING_STATUS  = 5,
    YOYO_HTTPX_IS_GETTING_HEADERS = 6,
    YOYO_HTTPX_IS_GETTING_CONTENT = 7,
    YOYO_HTTPX_IS_FINISHED        = 8,
    YOYO_HTTPX_IS_FAILED          = 9,
    YOYO_HTTPX_RESOLVING_ERROR    = 0x1001,
    YOYO_HTTPX_URLPARSING_ERROR   = 0x1002,
    YOYO_HTTPX_GETTING_ERROR      = 0x1003,
  };

typedef struct _YOYO_HTTPX_NTFY
  {
    void (*progress)(struct _YOYO_HTTPX_NTFY *, int st, int count, int total);
    void (*error)(struct _YOYO_HTTPX_NTFY *, int st, char *msg);
  } YOYO_HTTPX_NTFY;

#endif /* C_once_DAA1D391_392F_467C_B5A8_6C8D0D3A9DCC */

