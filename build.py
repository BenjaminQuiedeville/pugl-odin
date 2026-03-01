import sys
import os
import os.path as path
import platform

# manually builds pugl with the opengl backend
# on windows the meson build is broken for some reason
# the windows build uses clang, install it with "winget install llvm" and put "C:/Program Files/LLVM/bin" in your PATH

platform = platform.system()

print("Building pugl")

if platform == "Windows":
    os.chdir("pugl")
    os.makedirs("build", exist_ok=True)
    os.chdir("build")
    
    os.system("clang -c -O3 -DPUGL_API=\"\" -I../include ../src/common.c ../src/internal.c ../src/win.c ../src/win_gl.c")
    # os.system("clang -c -g -gcodeview -DPUGL_API=\"\" -I../include ../src/common.c ../src/internal.c ../src/win.c ../src/win_gl.c")
    os.system("llvm-ar r pugl.lib *.o")
    
    os.chdir("../..")
    os.makedirs("lib", exist_ok=True)
    os.system("copy /Y pugl\\build\\pugl.lib lib\\pugl.lib")    
    print("pugl.lib placed at pugl-odin/lib/pugl.lib")

else: # Linux, Darwin
    # untested
    os.chdir("pugl")
    os.system("meson setup build")
    os.system("meson compile -C build")
    os.chdir("..")
    os.makedirs("lib", exist_ok=True)
    os.system("cp pugl/build/libpugl.a lib/")
    print("libpugl.a placed at pugl-odin/lib/libpugl.a")
    
