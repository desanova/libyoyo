
/*

(C)2005-2011, Alexéy Sudáchen, alexey@sudachen.name

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

#ifndef C_once_9570D5A2_F57C_4879_851D_6EC6959C9420
#define C_once_9570D5A2_F57C_4879_851D_6EC6959C9420

#ifdef _LIBYOYO
#define _YOYO_LZSS_BUILTIN
#endif

#include "yoyo.hc"
#include "buffer.hc"

#ifdef _YOYO_LZSS_BUILTIN
enum 
  {
    LZSS_MIN_LEN = 4,
    LZSS_MAX_LEN = 15,
    LZSS_TABLE_MOD = 4095, /*4095, */
    LZSS_TABLE_LEN = LZSS_TABLE_MOD+1,
  };
#endif

int LZSS_Search_Index(char **table_S, char**iE, char* val, int strong, int *p_l, int maxl)
#ifdef _YOYO_LZSS_BUILTIN
  {
    char **iS = table_S;
    int len = iE - iS;
    int half;
    char ** middle;
    int  l = 0, ll = 0;
    if (p_l) *p_l = 0;

    while (len > 0)
      {
        half = len >> 1;
        middle = iS + half;
        if ( memcmp(*middle,val,maxl) < 0 )
          {
            iS = middle;
            ++iS;
            len = len - half - 1;
          }
        else
          {
            len = half;
          }
      }

    if ( iS != iE )
      {
        char **p = iS-1;
        for ( l = 0; l < maxl && (*iS)[l] == val[l]; ) ++l;
        if ( p >= table_S && strong == 2 )
          {
            for ( ll = 0; ll < maxl && (*p)[ll] == val[ll]; ) ++ll;
            if ( ll > l ) iS = p, l = ll;
          }
      }
    else
      l = 0;

    if ( strong == 1 )
      {
        char **k = iS;
        STRICT_REQUIRE ( iS != iE );

        if ( *k != val )
          for ( ; k > table_S ; --k ) if (*k == val || **k != *val) break;
        if ( *k != val )
          for ( k = iS ; k != iE ; ++k ) if (*k == val || **k != *val) break;
        if ( *k == val )
          iS = k;
      }

    STRICT_REQUIRE ( strong!=1 || *iS == val );
    STRICT_REQUIRE ( !l || memcmp(val,*iS,l) == 0 );
    if ( p_l ) *p_l = l;
    return iS-table_S;
  }
#endif
  ;

void LZSS_Replace_String(char **table, char *in_b, int r_i)
#ifdef _YOYO_LZSS_BUILTIN
  {
    int l, o_idx, idx;
    if (r_i >= LZSS_TABLE_MOD) // replace
      {
        char *p = in_b+(r_i-LZSS_TABLE_MOD);
        o_idx = LZSS_Search_Index(table,table+LZSS_TABLE_MOD,p,1,0,LZSS_MAX_LEN);

        STRICT_REQUIRE ( o_idx >=0 && o_idx < LZSS_TABLE_MOD );
        if ( !(l = memcmp(p,in_b+ r_i,LZSS_MAX_LEN)) )
          {
            table[o_idx] = in_b+r_i;
            return;
          }
      }
    else // append
      {
        o_idx = r_i;
        l = 1;
      }

    if ( l < 0  )  // old string less then new
      { // working with right part
        if ( o_idx == LZSS_TABLE_MOD-1 )
          {
            table[o_idx] = in_b+r_i;
          }
        else
          {
            char **table_L = table + (o_idx + 1);
            idx = LZSS_Search_Index(table_L,table+LZSS_TABLE_MOD,in_b+r_i,0,&l,LZSS_MAX_LEN);
            memmove(table_L-1,table_L,idx*sizeof(char*));
            table_L[idx-1] = in_b+r_i;
          }
      }
    else  // old string great then new
      { // working with left part
        char **table_R = table + o_idx;
        idx = LZSS_Search_Index(table,table_R,in_b+r_i,0,&l,LZSS_MAX_LEN);
        memmove(table+idx+1,table+idx,((table_R-table)-idx)*sizeof(char*));
        table[idx] = in_b+r_i;
      }
  }
#endif
  ;

short LZSS_Update_Table(char **table, char *in_b, int _in_i, int out_l)
#ifdef _YOYO_LZSS_BUILTIN
  {
    int code = 0, idx = 0, s_i, l=0;
    char **table_R;
    int r_i = _in_i-(LZSS_MAX_LEN-1);  // old (will replaced) string
    int t_i = _in_i;                   // encoded string
    int maxl = (out_l >= LZSS_MAX_LEN ? LZSS_MAX_LEN : out_l);

    if ( r_i > LZSS_TABLE_MOD )
      table_R = table + LZSS_TABLE_MOD;
    else
      {
        table_R = table + r_i;
        if ( out_l < LZSS_MAX_LEN ) table_R -= (LZSS_MAX_LEN - out_l);
      }

    // encoding
    idx = LZSS_Search_Index(table,table_R,in_b+t_i,2,&l,maxl);
    s_i = t_i - (table[idx]-in_b);
    if ( l >= LZSS_MIN_LEN )
      {
        STRICT_REQUIRE ( s_i <= LZSS_TABLE_MOD+LZSS_MAX_LEN && s_i >= LZSS_MAX_LEN );
        code = (((s_i-LZSS_MAX_LEN)%LZSS_TABLE_MOD)<<4)|l;
      }

    if ( out_l-- >= LZSS_MAX_LEN )
      LZSS_Replace_String(table,in_b,r_i++);

    // adding new strings
    if ( l >= LZSS_MIN_LEN )
      while ( --l && out_l-- >= LZSS_MAX_LEN )
        LZSS_Replace_String(table,in_b,r_i++);

    return code;
  }
#endif
  ;

int LZSS_Compress(void *_in_b, int in_b_len, void *_out_b, int out_b_len)
#ifdef _YOYO_LZSS_BUILTIN
  {
    
    char *in_b = _in_b;
    unsigned char *out_b = _out_b;
    char **table = 0;
    int  out_i = 4, in_i = 0;
    unsigned char *cnt_p = 0;

    if ( in_b_len < 2*LZSS_MAX_LEN ) return 0;

    out_b[0] = in_b_len&0x0ff;
    out_b[1] = (in_b_len>>8)&0x0ff;
    out_b[2] = (in_b_len>>16)&0x0ff;
    out_b[3] = (in_b_len>>24)&0x0ff;

    table = (char**)Yo_Malloc_Npl(LZSS_TABLE_LEN*sizeof(char**));
    memset(table,0,LZSS_TABLE_LEN*sizeof(char**));
    table[0] = in_b;

    out_b[out_i++] = 0;
    cnt_p = out_b+out_i;
    out_b[out_i++] = LZSS_MAX_LEN-1;
    memcpy(out_b+out_i,in_b,LZSS_MAX_LEN);
    out_i += LZSS_MAX_LEN;
    in_i  += LZSS_MAX_LEN;

    while ( in_i <  in_b_len && out_i+1 < out_b_len )
      {
        unsigned short code = LZSS_Update_Table(table,in_b,in_i,in_b_len-in_i);
        if ( !code )
          {
            if ( !cnt_p || (!cnt_p[-1] && *cnt_p == 255) )
              {
                out_b[out_i++] = 0x80;
                *(cnt_p = out_b + out_i++) = in_b[in_i++];
              }
            else
              {
                if ( cnt_p[-1] == 0x80 )
                  {
                    out_b[out_i++] = *cnt_p;
                    *cnt_p = cnt_p[-1] = 0;
                  }
                ++*cnt_p;
                out_b[out_i++] = in_b[in_i++];
              }
          }
        else
          {
            int l = code&0x0f;
            cnt_p = 0;
            out_b[out_i++] = code&0x0ff;
            out_b[out_i++] = (code>>8)&0x0ff;
            in_i += l;
          }
      }
    if ( in_i != in_b_len ) out_i = -out_i;
    free(table);
    return out_i;
  }
#endif
  ;

int LZSS_Compress_Inplace(void *buf, int in_len)
#ifdef _YOYO_LZSS_BUILTIN
  {
    void *b = Yo_Malloc_Npl(in_len);
    int q = LZSS_Compress(buf,in_len,b,in_len);
    if ( q > 0 )
      memcpy(buf,b,q);
    free(b);
    return q;
  }
#endif
  ;
  
int LZSS_Decompress(void *_in_b, int in_b_len, void *_out_b, int out_b_len)
#ifdef _YOYO_LZSS_BUILTIN
  {
    unsigned char *in_b = _in_b;
    char *out_b = _out_b;
    int in_i = 0;
    int out_i = 0;
    
    int original_len = Four_To_Unsigned(in_b);
    in_i += 4; /* skip original length */
    
    while ( in_i < in_b_len && out_i < out_b_len )
      {
        if ( in_b[in_i] == 0x80 )
          {// one char
            out_b[out_i++] = in_b[++in_i];
            ++in_i;
          }
        else if ( !in_b[in_i] )
          {// several chars
            int l = (int)in_b[++in_i]+1;
            ++in_i;
            while ( l-- )
              {
                out_b[out_i++] = in_b[in_i++];
              }
          }
        else
          {// code
            unsigned short code = (short)in_b[in_i]|((short)in_b[in_i+1] << 8);
            int l = code & 0x0f;
            int off = code >> 4;
            memcpy(out_b+out_i,out_b+out_i-off-LZSS_MAX_LEN,l);
            out_i += l;
            in_i += 2;
          }
      }
    
    if ( out_i != original_len ) out_i = -out_i;
    return out_i;
  }
#endif
  ;

int LZSS_Decompress_Inplace(void *buf, int in_len, int max_len)
#ifdef _YOYO_LZSS_BUILTIN
  {
    void *b = Yo_Malloc_Npl(max_len);
    int q = LZSS_Decompress(buf,in_len,b,max_len);
    if ( q > 0 )
      memcpy(buf,b,q);
    free(b);
    return q;
  }
#endif
  ;

void Buffer_LZSS_Compress(YOYO_BUFFER *bf)
#ifdef _YOYO_LZSS_BUILTIN
  {
    void *b = Yo_Malloc_Npl(bf->count);
    int q = LZSS_Compress(bf->at,bf->count,b,bf->count);
    
    if ( q > 0 )
      {
        memcpy(bf->at,b,q);
        Buffer_Resize(bf,q);
      }
    free(b);
    
    if ( q < 0 )
      __Raise(YOYO_ERROR_COMPRESS_DATA,"uncompressable data");
  }
#endif
  ;

void Buffer_LZSS_Decompress(YOYO_BUFFER *bf)
#ifdef _YOYO_LZSS_BUILTIN
  {
    int sz = Four_To_Unsigned(bf->at);
    if ( sz > bf->count*30 ) 
      __Raise(YOYO_ERROR_CORRUPTED,"is not LZSS compressed buffer"); 
    else
      {
        void *b = Yo_Malloc_Npl(sz);
        int q = LZSS_Decompress(bf->at,bf->count,b,sz);
    
        if ( q > 0 )
          {
            Buffer_Resize(bf,q);
            memcpy(bf->at,b,q);
          }
        free(b);
    
        if ( q < 0 )
          __Raise(YOYO_ERROR_DECOMPRESS_DATA,"failed to decompress buffer");
      }
  }
#endif
  ;

#endif /* C_once_9570D5A2_F57C_4879_851D_6EC6959C9420 */

