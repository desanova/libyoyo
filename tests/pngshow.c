
#include <libyoyo.hc>
#include <extra/pictpng.hc>

HBITMAP bmp;

LRESULT __stdcall Window_Proc(HWND hwnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
  {
    if ( uMsg == WM_PAINT )
      {
        HBITMAP old;
        BITMAP bmpi;
        RECT rect;
        HDC dc,pdc;
        PAINTSTRUCT pst;
        
        pdc = BeginPaint(hwnd,&pst);
        GetObject(bmp,sizeof(BITMAP),&bmpi);
        GetClientRect(hwnd,&rect);
        
        dc = CreateCompatibleDC(pdc);
        old = SelectObject(dc,bmp);
        StretchBlt(pdc,0,0,rect.right,rect.bottom,
                   dc,0,0,bmpi.bmWidth,bmpi.bmHeight,
                   SRCCOPY);
        SelectObject(dc,old);
        DeleteDC(dc);
      }
    else
      return DefWindowProc(hwnd,uMsg,wParam,lParam);
  }
  
int main(int argc, char **argv)
  {
    RECT rect = {0};
    HWND hwnd;
    MSG  msg = {0};
    WNDCLASS wc = {0};
    YOYO_PICTURE *pict;
    int style  = WS_BORDER|WS_VISIBLE|WS_CAPTION;
    int ex_style = 0;
    
    Prog_Init(argc,argv,"?|h,l",PROG_EXIT_ON_ERROR);
    
    wc.lpszClassName = "PNG test class";
    wc.lpfnWndProc   = (WNDPROC)Window_Proc;
    wc.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
    wc.style = CS_HREDRAW|CS_VREDRAW;
    wc.hCursor = LoadCursor(0,IDC_ARROW);
    RegisterClassA(&wc);
    
    pict = Pict_From_PNG_File("test.png");
    bmp = Pict_Create_HBITMAP(pict);
    printf("bmp %p\n",bmp);
    
    rect.bottom = pict->height;
    rect.right = pict->width;
    AdjustWindowRectEx(&rect,style,0,ex_style);
    hwnd = CreateWindowEx(
            ex_style,
            "PNG test class",
            "PNG test class",
            style,
            rect.left,rect.top,
            rect.right-rect.left,rect.bottom-rect.top,
            0,0,0,0);
  
    while ( GetMessage(&msg,hwnd,0,0) )
      {
        if ( msg.message == WM_QUIT )
          break;
        else
          {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
          }
      }
  }
