module ve.main_loop;

import core.sys.windows.windows;

pragma(lib, "user32.lib");
pragma(lib, "gdi32.lib");
pragma(lib, "opengl32.lib");

class MainLoop
{
    void onInit()
    {
    }

    void onShutdown()
    {
    }

    void onUpdate()
    {
    }
}

void veRun(T)()
{
    assert(!hwnd);
    assert(!hInstance);
    assert(!hDC);
    assert(!hRC);
    assert(!gLoop);
    assert(!gDone);

    gLoop = new T();

    veCreateWindow();
    veCreateOpenGLContext();

    gLoop.onInit();

    while (!gDone)
    {
        MSG msg;
        while (PeekMessageA(&msg, null, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&msg);
            DispatchMessageA(&msg);
        }

        gLoop.onUpdate();

        SwapBuffers(hDC);
    }

    gLoop.onShutdown();

    veDestroyOpenGLContext();
    veDestroyWindow();
}

private:

__gshared HWND hwnd;
__gshared HINSTANCE hInstance;
__gshared HDC hDC;
__gshared HGLRC hRC;
__gshared MainLoop gLoop;
__gshared bool gDone;

void veCreateWindow()
{
    hInstance = GetModuleHandle(null);
    assert(hInstance);

    WNDCLASSEXA wc;
    wc.cbSize = WNDCLASSEXA.sizeof;
    wc.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC | CS_DBLCLKS;
    wc.lpfnWndProc = &WndProc;
    wc.hInstance = hInstance;
    wc.hIcon = LoadIcon(null, IDI_WINLOGO);
    wc.lpszClassName = "ve";

    ATOM ok = RegisterClassExA(&wc);
    assert(ok);

    DWORD dwStyle = WS_OVERLAPPEDWINDOW | WS_POPUP;
    DWORD dwExStyle = WS_EX_WINDOWEDGE | WS_EX_APPWINDOW;

    hwnd = CreateWindowExA(dwExStyle, "ve", "", dwStyle, 0, 0, 640, 480, null,
            null, hInstance, null);
    assert(hwnd);

    ShowWindow(hwnd, SW_SHOW);
    UpdateWindow(hwnd);
}

void veDestroyWindow()
{
    DestroyWindow(hwnd);
    UnregisterClass("ve", hInstance);
}

void veCreateOpenGLContext()
{
    PIXELFORMATDESCRIPTOR pfd;
    pfd.nSize = PIXELFORMATDESCRIPTOR.sizeof;
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cAlphaBits = 8;
    pfd.cDepthBits = 24;
    pfd.iLayerType = PFD_MAIN_PLANE;

    hDC = GetDC(hwnd);
    assert(hDC);

    auto pixelFormat = ChoosePixelFormat(hDC, &pfd);
    assert(pixelFormat);

    BOOL ok = SetPixelFormat(hDC, pixelFormat, &pfd);
    assert(ok);

    hRC = wglCreateContext(hDC);
    assert(hRC);

    wglMakeCurrent(hDC, hRC);
}

void veDestroyOpenGLContext()
{
    wglMakeCurrent(hDC, null);
    wglDeleteContext(hRC);
}

extern (Windows) LRESULT WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) nothrow @system
{
    switch (msg)
    {
    case WM_QUIT:
    case WM_DESTROY:
    case WM_CLOSE:
        gDone = true;
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}
