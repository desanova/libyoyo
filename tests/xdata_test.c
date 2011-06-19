
/*

(C)2010-2011, Alexéy Sudáchen, alexey@sudachen.tag

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

Except as contained in this notice, the tag of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#include <libyoyo.hc>

char codb_name[] = "codb";

YOYO_XDATA *Generate_Random_Doc()
  {
    YOYO_XDATA *doc = Xdata_Init();
    return doc;
  }

int main(int argc, char **argv)
  {

    Prog_Init(argc,argv,0,0);

    __Gogo
      {
        YOYO_XDATA *tmpl = Xtmpl_Load_Template(".","test.tmpl");
        //puts(Def_Format_Into(0,&tmpl->root,0));
        __Gogo
          {
            char *html;
            YOYO_XDATA *model = Xdata_Init();
            YOYO_XNODE *n = Xnode_Insert(&model->root,"USER");
            Xnode_Value_Set_Str(n,"name","Вася");
            n = Xnode_Append(&model->root,"USER");
            Xnode_Value_Set_Str(n,"@","Goblin");
            Xnode_Value_Set_Str(n,"name","Петя");
            html = Xtmpl_Produce_Out(0,tmpl,model);
            puts(html);
          }
      }

    if (0) __Gogo
      {
        YOYO_XDATA *xd = Def_Parse_File("xdata_test.def");
        Def_Format_File("xdata_test_1.def",&xd->root,0);
      }
      
    if (0) __Gogo
      {
        YOYO_XDATA *doc,*doc2;
        char *doc_key;
        YOYO_XDATA_CO *co = 0;

        __Try
          co = Xdata_Co_Open(codb_name);
        __Catch(YOYO_ERROR_DOESNT_EXIST)
          co = Xdata_Co_Create(codb_name,YOYO_XDATA_CO_DEVELOPER_CF);

        doc = Generate_Random_Doc();
        Xdata_Co_Override(co,doc,0);
        doc_key = Xdata_Get_Key(doc);
        printf("$key$: %s\n",doc_key);
        Xnode_Value_Set_Str(doc,"special_test_value","special test string");
        Xdata_Co_Update(co,doc);
        doc2 = Xdata_Co_Get(co,doc_key,YOYO_XDATA_RAISE_DOESNT_EXIST);
      }
  }


