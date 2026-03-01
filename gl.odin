// Copyright 2012-2023 David Robillard <d@drobilla.net>
// SPDX-License-Identifier: ISC
package pugl

import "vendor:OpenGL"
/**
   @defgroup pugl_gl OpenGL
   OpenGL graphics support.
   @ingroup pugl_backend
   @{
*/

/**
OpenGL extension function.
*/
Gl_Func :: proc "c" ()

@(default_calling_convention="c", link_prefix="pugl")
foreign lib {
    /**
       Return the address of an OpenGL extension function.

       The returned void function pointer must be cast to the appropriate function
       type (defined by the OpenGL specification) in order to be called.
    */
    GetProcAddress :: proc(name: cstring) -> Gl_Func ---

    /**
       Enter the OpenGL context.

       This can be used to enter the graphics context in unusual situations, for
       doing things like loading textures.  Note that this must not be used for
       drawing, which may only be done while processing an expose event.
    */
    EnterContext :: proc(view: ^View) -> Status ---

    /**
       Leave the OpenGL context.

       This must only be called after puglEnterContext().
    */
    LeaveContext :: proc(view: ^View) -> Status ---

    /**
       OpenGL graphics backend.

       Pass the returned value to puglSetBackend() to draw to a view with OpenGL.
    */
    GlBackend :: proc() -> ^Backend ---
}
