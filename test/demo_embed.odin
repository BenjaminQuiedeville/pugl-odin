package demo 

import "core:fmt"
import "core:os"
import "core:math"
import "base:runtime"

import gl "vendor:OpenGL"

import pugl "../../pugl-odin"

border_width :: 64
reverse_timer_id :: 1


Test_App :: struct {
    world: ^pugl.World,
    parent: ^pugl.View,
    child: ^pugl.View,
    x_angle: f64,
    y_angle: f64, 
    last_mouse_x: f64,
    last_mouse_y: f64,
    last_draw_time: f64,
    dist: f32,
    quit: i32,
    continuous: bool,
    mouse_entered: bool,
    verbose: bool, 
    reversing: bool,
}

Fps_Printer :: struct {
  lastReportTime: f64
}


backgroundVertices := []f32 {
  -1.0,  1.0,  -1.0, // Top left
   1.0,  1.0,  -1.0, // Top right
  -1.0, -1.0,  -1.0, // Bottom left
   1.0, -1.0,  -1.0, // Bottom right
}

backgroundColorVertices := []f32 {
  0.25, 0.25, 0.25, // Top left
  0.25, 0.50, 0.25, // Top right
  0.25, 0.50, 0.25, // Bottom left
  0.25, 0.75, 0.5,  // Bottom right
}

on_expose :: proc(view: ^pugl.View) {
    app := transmute(^Test_App)pugl.GetHandle(view)
    
    size := pugl.GetSizeHint(view, .CURRENT_SIZE)
    
    thisTime := pugl.GetTime(app.world)
    if app.continuous {
        dTime := (f64(thisTime) - app.last_draw_time) * (app.reversing ? -1.0 : 1.0)
        
        app.x_angle = math.mod(app.x_angle + (dTime * 100.0), 360.0)
        app.y_angle = math.mod(app.y_angle + (dTime * 100.0), 360.0)
    }
    
    app.last_draw_time = f64(thisTime)

}

swap_focus :: proc(app: ^Test_App) {
    
    if pugl.HasFocus(app.parent) {
        pugl.GrabFocus(app.child)
    } else {
        pugl.GrabFocus(app.parent)
    }
    
    if (!app.continuous) {
        pugl.ObscureView(app.parent)
        pugl.ObscureView(app.child)
    }
}

on_key_press :: proc(view: ^pugl.View, event: ^pugl.Key_Event) {}

on_parent_event :: proc "c" (view: ^pugl.View, event: ^pugl.Event) -> pugl.Status {
    context = runtime.default_context()
    
    app := transmute(^Test_App)pugl.GetHandle(view)
        
    #partial switch event.type {
        case .CONFIGURE: {
            pugl.SetSizeHint(app.child,
                             .CURRENT_SIZE,
                             u32(event.configure.width - (2 * border_width)),
                             u32(event.configure.height - (2 * border_width)))
        }
        case .UPDATE: {
            if app.continuous {
                pugl.ObscureView(view)
            }
        }
        case .EXPOSE: {
            if pugl.HasFocus(app.parent) {
                gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
                
                gl.DrawArrays(gl.TRIANGLE_STRIP, 0, 4)
            } else {
                gl.ClearColor(0.0, 0.0, 0.0, 1.0)
                gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
            }
        }
        case .KEY_PRESS: {
            on_key_press(view, &event.key)
        }
        case .MOTION: {}
        case .CLOSE: {
            app.quit = 1
        }
        case: {}
    }
    
    return .SUCCESS
}

on_event :: proc "c" (view: ^pugl.View, event: ^pugl.Event) -> pugl.Status {
    context = runtime.default_context()
    
    app := transmute(^Test_App)pugl.GetHandle(view)
        
    #partial switch event.type {
        case .UPDATE: {
            if app.continuous {
                pugl.ObscureView(view)
            }
        }
        case .EXPOSE: {
            on_expose(view)
        }
        case .CLOSE: {
            app.quit = 1
        }
        case .KEY_PRESS: {
            on_key_press(view, &event.key)
        }
        case .MOTION: {
            app.x_angle -= event.motion.x - app.last_mouse_x
            app.y_angle += event.motion.y - app.last_mouse_y
            app.last_mouse_x = event.motion.x
            app.last_mouse_y = event.motion.y
            if (!app.continuous) {
                pugl.ObscureView(view)
                pugl.ObscureView(app.parent)
            }
        }
        case .SCROLL: {
            app.dist = max(10.0, app.dist + f32(event.scroll.dy))
            if (!app.continuous) {
                pugl.ObscureView(view)
            }
        }
        case .POINTER_IN: {
            app.mouse_entered = true
        }
        case .POINTER_OUT: {
            app.mouse_entered = false
        }
        case .TIMER: {
            app.reversing = !app.reversing
        }
        case: {}
    }
    
    return .SUCCESS
}

PrintFps :: proc(thisTime: f64, printer: ^Fps_Printer, framesDrawn: ^u32) {
  if thisTime > printer.lastReportTime + 5.0 {
    elapsed := (thisTime - printer.lastReportTime)
    fps     := f64(framesDrawn^) / elapsed
    fmt.fprintf(os.stderr,
            "FPS: %.2f (%u frames / %.2f seconds)\n",
            fps,
            framesDrawn^,
            elapsed)

    printer.lastReportTime = thisTime
    framesDrawn^ = 0
  }
}


main :: proc() {

    app: Test_App
    app.dist = 10
    
    gl.load_up_to(3, 2,  proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = cast(rawptr)pugl.GetProcAddress(name)
	})

    
    app.continuous = true
    app.verbose = false
    
    app.world = pugl.NewWorld(.PROGRAM, 0)
    defer pugl.FreeWorld(app.world)
    
    app.parent = pugl.NewView(app.world)
    defer pugl.FreeView(app.parent)
    
    app.child = pugl.NewView(app.world)
    defer pugl.FreeView(app.child)

    
    pugl.SetWorldString(app.world, .CLASS_NAME, "pugl test odin")
    
    pugl.SetSizeHint(app.parent, .DEFAULT_SIZE, 512, 512)
    pugl.SetSizeHint(app.parent, .MIN_SIZE, 192, 192)
    pugl.SetSizeHint(app.parent, .MAX_SIZE, 1024, 1024)
    pugl.SetSizeHint(app.parent, .MIN_ASPECT, 1, 1)
    pugl.SetSizeHint(app.parent, .MAX_ASPECT, 16, 9)
    pugl.SetBackend(app.parent, pugl.GlBackend())
    
    pugl.SetViewHint(app.parent, .CONTEXT_DEBUG, 0)
    pugl.SetViewHint(app.parent, .RESIZABLE, 0)
    pugl.SetViewHint(app.parent, .SAMPLES, 0)
    pugl.SetViewHint(app.parent, .DOUBLE_BUFFER, 0)
    pugl.SetViewHint(app.parent, .SWAP_INTERVAL, 0)
    pugl.SetViewHint(app.parent, .IGNORE_KEY_REPEAT, 0)
    pugl.SetHandle(app.parent, &app)
    pugl.SetEventFunc(app.parent, on_parent_event)
    
    st := pugl.Status.SUCCESS
    title: cstring = "parent view name"
    pugl.SetViewString(app.parent, .WINDOW_TITLE, title)
    
    st = pugl.Realize(app.parent)
    if st != nil {
        panic("Failed to create the parent window")
    }
    
    pugl.SetParent(app.child, pugl.GetNativeView(app.parent))
    pugl.SetPositionHint(app.child, .DEFAULT_POSITION, border_width, border_width)
    pugl.SetSizeHint(app.child, .DEFAULT_SIZE, 512 - (2*border_width), 512 - (2*border_width))
    
    pugl.SetViewHint(app.child, .CONTEXT_DEBUG, 0)
    pugl.SetViewHint(app.child, .SAMPLES, 0)
    pugl.SetViewHint(app.child, .DOUBLE_BUFFER, 0)
    pugl.SetViewHint(app.child, .SWAP_INTERVAL, 0)
    pugl.SetBackend(app.child, pugl.GlBackend())
    pugl.SetViewHint(app.child, .IGNORE_KEY_REPEAT, 0)
    pugl.SetHandle(app.child, &app)
    pugl.SetEventFunc(app.child, on_event)
    
    st = pugl.Realize(app.child)
    if st != nil {
        panic("Failed to create child window")
    }
    
    pugl.Show(app.parent, .RAISE)
    pugl.Show(app.child, .RAISE)
    
    pugl.StartTimer(app.child, reverse_timer_id, 3.6)
    
    fps_printer := Fps_Printer { cast(f64)pugl.GetTime(app.world) }
    frames_drawn : u32 = 0
    requested_attention := false
    
    for app.quit == 0 {
        this_time := pugl.GetTime(app.world)
        
        pugl.Update(app.world, app.continuous ? 0.0 : -1.0)
        frames_drawn += 1
        if !requested_attention && (this_time > 5.0) {
            pugl.SetViewStyle(app.parent, pugl.GetViewStyle(app.parent) | cast(u32)pugl.View_Style_Flag.DEMANDING)
            requested_attention = true
        }
        
        if app.continuous {
            PrintFps(cast(f64)pugl.GetTime(app.world), &fps_printer, &frames_drawn)
        }
    }
}
