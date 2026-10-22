// Copyright 2012-2025 David Robillard <d@drobilla.net>
// SPDX-License-Identifier: ISC
package pugl

import "core:c"

when ODIN_OS == .Windows {
    @export foreign import lib {
        "pugl.lib",
        "system:User32.lib",
        "system:Gdi32.lib",
        "system:Dwmapi.lib",
        "system:OpenGL32.lib",
    }
} else {
    @export foreign import lib "libpugl.a"
}
_ :: lib

Int16_T :: i32

/**
   A pixel coordinate within/of a view.

   This is used to represent coordinates in two different spaces, depending on
   context: parent-relative and view-relative.

   Parent-relative coordinates of a view are relative to the top-left of the
   parent it's embedded in, or to that of a system-specific root.  Top-level
   positions should be between -16000 and 16000.

   View-relative coordinates in a view are relative to the top-left of the
   view.
*/
Coord :: i16

/**
A pixel span (width or height) within/of a view.

The width and height of a view should be between 1 and 10000.
*/
Span :: u16

/// A 2-dimensional position within/of a view
Point :: [2]Coord

/// A 2-dimensional size within/of a view
Area :: struct {
    width:  Span,
    height: Span,
}

/// The type of a #PuglEvent
Event_Type :: enum c.int {
    NOTHING        = 0,  ///< No event
    REALIZE        = 1,  ///< View realized, a #PuglRealizeEvent
    UNREALIZE      = 2,  ///< View unrealized, a #PuglUnrealizeEvent
    CONFIGURE      = 3,  ///< View configured, a #PuglConfigureEvent
    UPDATE         = 4,  ///< View update before draw, a #PuglUpdateEvent
    EXPOSE         = 5,  ///< View expose during draw, a #PuglExposeEvent
    CLOSE          = 6,  ///< View will be closed, a #PuglCloseEvent
    FOCUS_IN       = 7,  ///< Keyboard focus entered view, a #PuglFocusEvent
    FOCUS_OUT      = 8,  ///< Keyboard focus left view, a #PuglFocusEvent
    KEY_PRESS      = 9,  ///< Key pressed, a #PuglKeyEvent
    KEY_RELEASE    = 10, ///< Key released, a #PuglKeyEvent
    TEXT           = 11, ///< Character entered, a #PuglTextEvent
    POINTER_IN     = 12, ///< Pointer entered view, a #PuglCrossingEvent
    POINTER_OUT    = 13, ///< Pointer left view, a #PuglCrossingEvent
    BUTTON_PRESS   = 14, ///< Mouse button pressed, a #PuglButtonEvent
    BUTTON_RELEASE = 15, ///< Mouse button released, a #PuglButtonEvent
    MOTION         = 16, ///< Pointer moved, a #PuglMotionEvent
    SCROLL         = 17, ///< Scrolled, a #PuglScrollEvent
    CLIENT         = 18, ///< Custom client message, a #PuglClientEvent
    TIMER          = 19, ///< Timer triggered, a #PuglTimerEvent
    LOOP_ENTER     = 20, ///< Recursive loop entered, a #PuglLoopEnterEvent
    LOOP_LEAVE     = 21, ///< Recursive loop left, a #PuglLoopLeaveEvent
    DATA_OFFER     = 22, ///< Data offered from clipboard, a #PuglDataOfferEvent
    DATA           = 23, ///< Data available from clipboard, a #PuglDataEvent
}

/// Common flags for all event types
Event_Flag :: enum u32 {
    SEND_EVENT = 1, ///< Event is synthetic
    HINT       = 2, ///< Event is a hint (not direct user input)
}

/// Bitwise OR of #PuglEventFlag values
Event_Flags :: u32

/// Common header for all events
Any_Event :: struct {
    type:  Event_Type,  ///< Event type
    flags: Event_Flags, ///< Bitwise OR of #PuglEventFlag values
}

/**
View style flags.

Style flags reflect special modes and states supported by the window system.
Applications can monitor or manipulate them to improve integration.
*/
View_Style_Flag :: enum u32 {
    /// View is mapped to a real window and potentially visible
    MAPPED     = 1,

    /// View is modal, typically a dialog box of its transient parent
    MODAL      = 2,

    /// View should be above most others
    ABOVE      = 4,

    /// View should be below most others
    BELOW      = 8,

    /// View is minimized, shaded, or otherwise invisible
    HIDDEN     = 16,

    /// View is maximized to fill the screen vertically
    TALL       = 32,

    /// View is maximized to fill the screen horizontally
    WIDE       = 64,

    /// View is enlarged to fill the entire screen with no decorations
    FULLSCREEN = 128,

    /// View is being resized
    RESIZING   = 256,

    /// View is ready for input or otherwise demanding attention
    DEMANDING  = 512,
}

/// Bitwise OR of #PuglViewStyleFlag values
View_Style_Flags :: u32

/**
View realize event.

This is sent when a view is realized before it's first displayed, with the
graphics context entered (but not prepared to draw).  This can be used to
set up the graphics system, for example by loading OpenGL extensions.
*/
Realize_Event :: Any_Event

/**
View unrealize event.

This counterpart to #PuglRealizeEvent is sent when the view will no longer
be displayed.  This can be used to tear down the graphics system, or free
any resources allocated when the view was realized.
*/
Unrealize_Event :: Any_Event

/**
View configure (resize/move) event.

This is sent whenever the view is resized or moved.  The graphics context
isn't active during a configure event, so these values should be saved if
necessary and applied the next time the view is exposed.
*/
Configure_Event :: struct {
    type:   Event_Type,       ///< #PUGL_CONFIGURE
    flags:  Event_Flags,      ///< Bitwise OR of #PuglEventFlag values
    x:      Coord,              ///< Parent-relative X coordinate of view
    y:      Coord,              ///< Parent-relative Y coordinate of view
    width:  Span,             ///< Width of view
    height: Span,             ///< Height of view
    style:  View_Style_Flags, ///< Bitwise OR of #PuglViewStyleFlag flags
}

/**
Recursive loop enter event.

This is sent when the window system enters a recursive loop.  While in the
recursive loop, the main loop will be stalled and no expose events will be
received.  A typical use is to install a timer to perform continuous
actions, such as drawing.

- MacOS: A recursive loop is entered while the window is being live resized.

- Windows: A recursive loop is entered while the window is being live
resized or the menu is shown.

- X11: A recursive loop is never entered and the event loop runs as usual
while the view is being resized.
*/
Loop_Enter_Event :: Any_Event

/**
Recursive loop leave event.

This is sent after a loop enter event when the recursive loop is finished
and normal iteration will continue.
*/
Loop_Leave_Event :: Any_Event

/**
View close event.

This is sent when the view is to be closed, for example when the user clicks
the close button.
*/
Close_Event :: Any_Event

/**
View update event.

This is sent near the end of a main loop iteration when the view is
potentially about to be redrawn.  It can be used to mark regions for
exposure with puglObscureView() or puglObscureRegion().  For example, to
continuously animate, obscure the view whenever an update event is received,
then receive and handle the expose event(s) shortly afterwards.
*/
Update_Event :: Any_Event

/**
Expose event requiring a redraw.

This is sent when a region needs to be redrawn, with the graphics context
entered and activated for drawing.  The application must completely draw the
given region.
*/
Expose_Event :: struct {
    type:   Event_Type,  ///< #PUGL_EXPOSE
    flags:  Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    x:      Coord,         ///< View-relative top-left X coordinate of region
    y:      Coord,         ///< View-relative top-left Y coordinate of region
    width:  Span,        ///< Width of exposed region
    height: Span,        ///< Height of exposed region
}

/**
Keyboard key codepoints.

All keys are identified by a Unicode code point in #PuglKeyEvent::key.  This
enumeration defines constants for special keys that don't have a standard
code point, and some convenience constants for control characters.  Note
that all keys are handled in the same way, this enumeration is just for
convenience when writing hard-coded key bindings.

Keys that don't have a standard code point use values in the Private Use
Area in the Basic Multilingual Plane (`U+E000` to `U+F8FF`).  Applications
must take care to not interpret these values beyond key detection, the
mapping used here is arbitrary and specific to Pugl.
*/
Key :: enum u32 {
    NONE          = 0,     ///< Sentinel value for no key
    BACKSPACE     = 8,     ///< Backspace
    TAB           = 9,     ///< Tab
    ENTER         = 13,    ///< Enter
    ESCAPE        = 27,    ///< Escape
    DELETE        = 127,   ///< Delete
    SPACE         = 32,    ///< Space
    F1            = 57344, ///< F1
    F2            = 57345, ///< F2
    F3            = 57346, ///< F3
    F4            = 57347, ///< F4
    F5            = 57348, ///< F5
    F6            = 57349, ///< F6
    F7            = 57350, ///< F7
    F8            = 57351, ///< F8
    F9            = 57352, ///< F9
    F10           = 57353, ///< F10
    F11           = 57360, ///< F11
    F12           = 57361, ///< F12
    PAGE_UP       = 57393, ///< Page Up
    PAGE_DOWN     = 57394, ///< Page Down
    END           = 57395, ///< End
    HOME          = 57396, ///< Home
    LEFT          = 57397, ///< Left
    UP            = 57398, ///< Up
    RIGHT         = 57399, ///< Right
    DOWN          = 57400, ///< Down
    PRINT_SCREEN  = 57409, ///< Print Screen
    INSERT        = 57410, ///< Insert
    PAUSE         = 57411, ///< Pause/Break
    MENU          = 57412, ///< Menu
    NUM_LOCK      = 57413, ///< Num Lock
    SCROLL_LOCK   = 57414, ///< Scroll Lock
    CAPS_LOCK     = 57415, ///< Caps Lock
    SHIFT_L       = 57425, ///< Left Shift
    SHIFT_R       = 57426, ///< Right Shift
    CTRL_L        = 57427, ///< Left Control
    CTRL_R        = 57428, ///< Right Control
    ALT_L         = 57429, ///< Left Alt
    ALT_R         = 57430, ///< Right Alt / AltGr
    SUPER_L       = 57431, ///< Left Super
    SUPER_R       = 57432, ///< Right Super
    PAD_0         = 57440, ///< Keypad 0
    PAD_1         = 57441, ///< Keypad 1
    PAD_2         = 57442, ///< Keypad 2
    PAD_3         = 57443, ///< Keypad 3
    PAD_4         = 57444, ///< Keypad 4
    PAD_5         = 57445, ///< Keypad 5
    PAD_6         = 57446, ///< Keypad 6
    PAD_7         = 57447, ///< Keypad 7
    PAD_8         = 57448, ///< Keypad 8
    PAD_9         = 57449, ///< Keypad 9
    PAD_ENTER     = 57456, ///< Keypad Enter
    PAD_PAGE_UP   = 57457, ///< Keypad Page Up
    PAD_PAGE_DOWN = 57458, ///< Keypad Page Down
    PAD_END       = 57459, ///< Keypad End
    PAD_HOME      = 57460, ///< Keypad Home
    PAD_LEFT      = 57461, ///< Keypad Left
    PAD_UP        = 57462, ///< Keypad Up
    PAD_RIGHT     = 57463, ///< Keypad Right
    PAD_DOWN      = 57464, ///< Keypad Down
    PAD_CLEAR     = 57501, ///< Keypad Clear/Begin
    PAD_INSERT    = 57502, ///< Keypad Insert
    PAD_DELETE    = 57503, ///< Keypad Delete
    PAD_EQUAL     = 57504, ///< Keypad Equal
    PAD_MULTIPLY  = 57514, ///< Keypad Multiply
    PAD_ADD       = 57515, ///< Keypad Add
    PAD_SEPARATOR = 57516, ///< Keypad Separator
    PAD_SUBTRACT  = 57517, ///< Keypad Subtract
    PAD_DECIMAL   = 57518, ///< Keypad Decimal
    PAD_DIVIDE    = 57519, ///< Keypad Divide
}

/// Keyboard modifier flags
Mod :: enum u32 {
    SHIFT       = 0, ///< Shift pressed
    CTRL        = 1, ///< Control pressed
    ALT         = 2, ///< Alt/Option pressed
    SUPER       = 3, ///< Super/Command/Windows pressed
    NUM_LOCK    = 4, ///< Num lock enabled
    SCROLL_LOCK = 5, ///< Scroll lock enabled
    CAPS_LOCK   = 6, ///< Caps lock enabled
}

/// Bitwise OR of #PuglMod values
Mods :: bit_set[Mod; i32]

/// Reason for a PuglCrossingEvent
Crossing_Mode :: enum c.int {
    NORMAL = 0, ///< Crossing due to pointer motion
    GRAB   = 1, ///< Crossing due to a grab
    UNGRAB = 2, ///< Crossing due to a grab release
}

/**
Keyboard focus event.

This is sent whenever the view gains or loses the keyboard focus.  The view
with the keyboard focus will receive any key press or release events.
*/
Focus_Event :: struct {
    type:  Event_Type,    ///< #PUGL_FOCUS_IN or #PUGL_FOCUS_OUT
    flags: Event_Flags,   ///< Bitwise OR of #PuglEventFlag values
    mode:  Crossing_Mode, ///< Reason for focus change
}

/**
Key press or release event.

This represents low-level key presses and releases.  This can be used for
"direct" keyboard handling like key bindings, but must not be interpreted as
text input.

Keys are represented portably as Unicode code points, using the "natural"
code point for the key where possible (see #PuglKey for details).  The `key`
field is the code for the pressed key, without any modifiers applied.  For
example, a press or release of the 'A' key will have `key` 97 ('a')
regardless of whether shift or control are being held.

Alternatively, the raw `keycode` can be used to work directly with physical
keys, but note that this value isn't portable and differs between platforms
and hardware.
*/
Key_Event :: struct {
    type:    Event_Type,  ///< #PUGL_KEY_PRESS or #PUGL_KEY_RELEASE
    flags:   Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    time:    f64,         ///< Time in seconds
    x:       f64,         ///< View-relative X coordinate
    y:       f64,         ///< View-relative Y coordinate
    xRoot:   f64,         ///< Root-relative X coordinate
    yRoot:   f64,         ///< Root-relative Y coordinate
    state:   Mods,        ///< Bitwise OR of #PuglMod flags
    keycode: u32,         ///< Raw key code
    key:     u32,         ///< Unshifted Unicode character code, or 0
}

/**
Character input event.

This represents text input, usually as the result of a key press.  The text
is given both as a Unicode character code and a UTF-8 string.

Note that this event is generated by the platform's input system, so there
isn't necessarily a direct correspondence between text events and physical
key presses.  For example, with some input methods a sequence of several key
presses will generate a single character.
*/
Text_Event :: struct {
    type:      Event_Type,  ///< #PUGL_TEXT
    flags:     Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    time:      f64,         ///< Time in seconds
    x:         f64,         ///< View-relative X coordinate
    y:         f64,         ///< View-relative Y coordinate
    xRoot:     f64,         ///< Root-relative X coordinate
    yRoot:     f64,         ///< Root-relative Y coordinate
    state:     Mods,        ///< Bitwise OR of #PuglMod flags
    keycode:   u32,         ///< Raw key code
    character: u32,         ///< Unicode character code
    _string:   [8]i8,       ///< UTF-8 string
}

/**
Scroll direction.

Describes the direction of a #PuglScrollEvent along with whether the scroll
is a "smooth" scroll.  The discrete directions are for devices like mouse
wheels with constrained axes, while a smooth scroll is for those with
arbitrary scroll direction freedom, like some touchpads.
*/
Scroll_Direction :: enum c.int {
    UP     = 0, ///< Scroll up
    DOWN   = 1, ///< Scroll down
    LEFT   = 2, ///< Scroll left
    RIGHT  = 3, ///< Scroll right
    SMOOTH = 4, ///< Smooth scroll in any direction
}

/**
Pointer enter or leave event.

This is sent when the pointer enters or leaves the view.  This can happen
for several reasons (not just the user dragging the pointer over the window
edge), as described by the `mode` field.
*/
Crossing_Event :: struct {
    type:  Event_Type,    ///< #PUGL_POINTER_IN or #PUGL_POINTER_OUT
    flags: Event_Flags,   ///< Bitwise OR of #PuglEventFlag values
    time:  f64,           ///< Time in seconds
    x:     f64,           ///< View-relative X coordinate
    y:     f64,           ///< View-relative Y coordinate
    xRoot: f64,           ///< Root-relative X coordinate
    yRoot: f64,           ///< Root-relative Y coordinate
    state: Mods,          ///< Bitwise OR of #PuglMod flags
    mode:  Crossing_Mode, ///< Reason for crossing
}

/**
Button press or release event.

Button numbers start from 0, and are ordered: primary, secondary, middle.
So, on a typical right-handed mouse, the button numbers are:

Left: 0
Right: 1
Middle (often a wheel): 2

Higher button numbers are reported in the same order they are represented on
the system.  There is no universal standard here, but buttons 3 and 4 are
typically a pair of buttons or a rocker, which are usually bound to "back"
and "forward" operations.

Note that these numbers may differ from those used on the underlying
platform, since they are manipulated to provide a consistent portable API.
*/
Button_Event :: struct {
    type:   Event_Type,  ///< #PUGL_BUTTON_PRESS or #PUGL_BUTTON_RELEASE
    flags:  Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    time:   f64,         ///< Time in seconds
    x:      f64,         ///< View-relative X coordinate
    y:      f64,         ///< View-relative Y coordinate
    xRoot:  f64,         ///< Root-relative X coordinate
    yRoot:  f64,         ///< Root-relative Y coordinate
    state:  Mods,        ///< Bitwise OR of #PuglMod flags
    button: u32,         ///< Button number starting from 0
}

/**
Pointer motion event.
*/
Motion_Event :: struct {
    type:  Event_Type,  ///< #PUGL_MOTION
    flags: Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    time:  f64,         ///< Time in seconds
    x:     f64,         ///< View-relative X coordinate
    y:     f64,         ///< View-relative Y coordinate
    xRoot: f64,         ///< Root-relative X coordinate
    yRoot: f64,         ///< Root-relative Y coordinate
    state: Mods,        ///< Bitwise OR of #PuglMod flags
}

/**
Scroll event.

The scroll distance is expressed in "lines", an arbitrary unit that
corresponds to a single tick of a detented mouse wheel.  For example, `dy` =
1.0 scrolls 1 line up.  Some systems and devices support finer resolution
and/or higher values for fast scrolls, so programs should handle any value
gracefully.
*/
Scroll_Event :: struct {
    type:      Event_Type,       ///< #PUGL_SCROLL
    flags:     Event_Flags,      ///< Bitwise OR of #PuglEventFlag values
    time:      f64,              ///< Time in seconds
    x:         f64,              ///< View-relative X coordinate
    y:         f64,              ///< View-relative Y coordinate
    xRoot:     f64,              ///< Root-relative X coordinate
    yRoot:     f64,              ///< Root-relative Y coordinate
    state:     Mods,             ///< Bitwise OR of #PuglMod flags
    direction: Scroll_Direction, ///< Scroll direction
    dx:        f64,              ///< Scroll X distance in lines
    dy:        f64,              ///< Scroll Y distance in lines
}

/**
Custom client message event.

This is a custom event sent to a view with puglSendEvent(), which wakes up
the event loop and delivers two pointer-sized data fields.  These
client-specific fields are opaque to Pugl and aren't interpreted in any way.
*/
Client_Event :: struct {
    type:  Event_Type,  ///< #PUGL_CLIENT
    flags: Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    data1: rawptr,      ///< Client-specific data
    data2: rawptr,      ///< Client-specific data
}

/**
Timer event.

This is sent while the timer with the given `id` is activated at the regular
interval specified in the corresponding puglStartTimer() call.  Other
platform-specific timers may exist, so applications must always check the
`id` field before reacting to a timer event.
*/
Timer_Event :: struct {
    type:  Event_Type,  ///< #PUGL_TIMER
    flags: Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    id:    rawptr,      ///< Timer ID
}

/**
Clipboard data offer event.

This is sent when a clipboard has data present, possibly with several
datatypes.  While handling this event, the types can be investigated with
puglGetClipboardType() to decide whether to accept the offer with
puglAcceptOffer().
*/
Data_Offer_Event :: struct {
    type:  Event_Type,  ///< #PUGL_DATA_OFFER
    flags: Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    time:  f64,         ///< Time in seconds
}

/**
Clipboard data event.

This is sent after accepting a data offer when the data has been retrieved
and converted.  While handling this event, the data can be accessed with
puglGetClipboard().
*/
Data_Event :: struct {
    type:      Event_Type,  ///< #PUGL_DATA
    flags:     Event_Flags, ///< Bitwise OR of #PuglEventFlag values
    time:      f64,         ///< Time in seconds
    typeIndex: u32,         ///< Index of datatype
}

/**
View event.

This is a union of all event types.  The `type` must be checked to determine
which fields are safe to access.  A pointer to PuglEvent can either be cast
to the appropriate type, or the union members used.

The graphics system may only be accessed when handling certain events.  The
graphics context is active for #PUGL_REALIZE, #PUGL_UNREALIZE, and
#PUGL_EXPOSE, but only enabled for drawing for #PUGL_EXPOSE.
*/
Event :: struct #raw_union {
    _any:      Any_Event,        ///< Valid for all event types
    type:      Event_Type,       ///< Event type
    button:    Button_Event,     ///< #PUGL_BUTTON_PRESS, #PUGL_BUTTON_RELEASE
    configure: Configure_Event,  ///< #PUGL_CONFIGURE
    expose:    Expose_Event,     ///< #PUGL_EXPOSE
    key:       Key_Event,        ///< #PUGL_KEY_PRESS, #PUGL_KEY_RELEASE
    text:      Text_Event,       ///< #PUGL_TEXT
    crossing:  Crossing_Event,   ///< #PUGL_POINTER_IN, #PUGL_POINTER_OUT
    motion:    Motion_Event,     ///< #PUGL_MOTION
    scroll:    Scroll_Event,     ///< #PUGL_SCROLL
    focus:     Focus_Event,      ///< #PUGL_FOCUS_IN, #PUGL_FOCUS_OUT
    client:    Client_Event,     ///< #PUGL_CLIENT
    timer:     Timer_Event,      ///< #PUGL_TIMER
    offer:     Data_Offer_Event, ///< #PUGL_DATA_OFFER
    data:      Data_Event,       ///< #PUGL_DATA
}

/// Return status code
Status :: enum c.int {
    SUCCESS               = 0,  ///< Success
    FAILURE               = 1,  ///< Non-fatal failure
    UNKNOWN_ERROR         = 2,  ///< Unknown system error
    BAD_BACKEND           = 3,  ///< Invalid or missing backend
    BAD_CONFIGURATION     = 4,  ///< Invalid view configuration
    BAD_PARAMETER         = 5,  ///< Invalid parameter
    BAD_CALL              = 6,  ///< Invalid call
    BACKEND_FAILED        = 7,  ///< Backend initialization failed
    REGISTRATION_FAILED   = 8,  ///< Class registration failed
    REALIZE_FAILED        = 9,  ///< System view realization failed
    SET_FORMAT_FAILED     = 10, ///< Failed to set pixel format
    CREATE_CONTEXT_FAILED = 11, ///< Failed to create drawing context
    UNSUPPORTED           = 12, ///< Unsupported operation
    NO_MEMORY             = 13, ///< Failed to allocate memory
}

/// A string property for configuration
String_Hint :: enum c.int {
    /**
    The application name.

    This is a stable identifier for the application, usually something like
    "my_app" which is the same as the name of the executable.  It's used as
    the applications name for X11 resources.
    */
    APPLICATION_NAME = 0,

    /**
    The application or window class name.

    This is a stable identifier for the application window class, a short
    camel-case name like "MyApp".  This should be the same for every instance
    of the application, but different from any other application.  On X11 and
    Windows, it's used to set the class name of windows, which is used for
    window management and configuration.
    */
    CLASS_NAME       = 1,

    /**
    The title of the window or application.

    This is used by the system to display a title for the application or
    window, for example in title bars or window/application switchers.  It's
    only used to display a label to the user, not as an identifier, and can
    change over time to reflect the current state of the application.  For
    example, it's common for programs to add the name of the current
    document, like "myfile.txt - Fancy Editor".
    */
    WINDOW_TITLE     = 2,
}

/// The number of #PuglStringHint values
NUM_STRING_HINTS :: 3

/**
The "world" of application state.

The world represents everything that isn't associated with a particular
view.  Several worlds can be created in a single process, but code using
different worlds must be isolated so they are never mixed.  Views are
strongly associated with the world they were created in.
*/
World      :: World_Impl
World_Impl :: struct {}

/// The type of a World
World_Type :: enum u32 {
    PROGRAM = 0, ///< Top-level application
    MODULE  = 1, ///< Plugin or module within a larger application
}

/// World flags
World_Flag :: enum u32 {
    /**
    Set up support for threads if necessary.

    X11: Calls XInitThreads() which is required for some drivers.
    */
    WORLD_THREADS = 1,
}

/// Bitwise OR of #PuglWorldFlag values
World_Flags  :: u32
Backend_Impl :: struct {}

/**
A graphics backend.

The backend dictates how graphics are set up for a view, and how drawing is
performed.  A backend must be set by calling puglSetBackend() before
realizing a view.
*/
Backend :: Backend_Impl

/**
A drawable region that receives events.

A view can be thought of as a window, but doesn't necessarily correspond to
a top-level window in a desktop environment.  For example, a view can be
embedded in another, or represent a simple embedded system with no concept
of windows at all.
*/
View      :: View_Impl
View_Impl :: struct {}

/**
A native view handle.

A "native view" is a system-specific handle for a view (or "window").  A
#PuglView is itself a native view, which may be embedded in another.  Like
the native world handle, this serves as a common denominator between this
and other APIs.

X11: This is a `Window`.

MacOS: This is a pointer to an `NSView*`.

Windows: This is a `HWND`.
*/
Native_View :: rawptr

/// An integer hint for configuring a view
View_Hint :: enum u32 {
    CONTEXT_API           = 0,  ///< OpenGL render API (GL/GLES)
    CONTEXT_VERSION_MAJOR = 1,  ///< OpenGL context major version
    CONTEXT_VERSION_MINOR = 2,  ///< OpenGL context minor version
    CONTEXT_PROFILE       = 3,  ///< OpenGL context profile (core/compatibility)
    CONTEXT_DEBUG         = 4,  ///< OpenGL context debugging enabled
    RED_BITS              = 5,  ///< Number of bits for red channel
    GREEN_BITS            = 6,  ///< Number of bits for green channel
    BLUE_BITS             = 7,  ///< Number of bits for blue channel
    ALPHA_BITS            = 8,  ///< Number of bits for alpha channel
    DEPTH_BITS            = 9,  ///< Number of bits for depth buffer
    STENCIL_BITS          = 10, ///< Number of bits for stencil buffer
    SAMPLE_BUFFERS        = 11, ///< Number of sample buffers (AA)
    SAMPLES               = 12, ///< Number of samples per pixel (AA)
    DOUBLE_BUFFER         = 13, ///< True if double buffering should be used
    SWAP_INTERVAL         = 14, ///< Number of frames between buffer swaps
    RESIZABLE             = 15, ///< True if view should be resizable
    IGNORE_KEY_REPEAT     = 16, ///< True if key repeat events are ignored
    REFRESH_RATE          = 17, ///< Refresh rate in Hz
    VIEW_TYPE             = 18, ///< View type (a #PuglViewType)
    DARK_FRAME            = 19, ///< True if window frame should be dark
}

/// The number of #PuglViewHint values
NUM_VIEW_HINTS :: 20

/// A special view hint value
View_Hint_Value :: enum i32 {
    DONT_CARE                    = -1, ///< Generic trinary: unset
    FALSE                        = 0,  ///< Generic trinary: false
    TRUE                         = 1,  ///< Generic trinary: true
    OPENGL_API                   = 2,  ///< For #PUGL_CONTEXT_API
    OPENGL_ES_API                = 3,  ///< For #PUGL_CONTEXT_API
    OPENGL_CORE_PROFILE          = 4,  ///< For #PUGL_CONTEXT_PROFILE
    OPENGL_COMPATIBILITY_PROFILE = 5,  ///< For #PUGL_CONTEXT_PROFILE
}

/// View type
View_Type :: enum u32 {
    NORMAL  = 0, ///< A normal top-level window
    UTILITY = 1, ///< A utility window like a palette or toolbox
    DIALOG  = 2, ///< A dialog window
}

/**
A hint for configuring or constraining the position of a view.

The system will attempt to make the view adhere to these, but they are
suggestions, not hard constraints.  Applications should handle any view
position gracefully.

An unset position has `INT16_MIN` (-32768) for both `x` and `y`.  In
practice, set positions should be between -16000 and 16000 for portability.
Usually, the origin is the top left of the display, although negative
coordinates are possible, particularly on multi-display systems.
*/
Position_Hint :: enum u32 {
    /**
    Default position.

    This is used as the initial position if no other position is specified.
    It isn't necessary to set a default position (unlike the default size,
    which is required).  If not even a default position is set, then the
    window will be placed somewhere reasonable according to platform
    conventions.  Applications must not make assumptions about the initial
    position, which is implementation-defined, platform-specific, and for
    embedded views, may become invalid if the parent's size is adjusted.
    */
    DEFAULT_POSITION = 0,

    /**
    Current position.

    This reflects the current position of the view, which may be different
    from the default position if the view has been moved by the user, window
    manager, or for any other reason.  It overrides the default position.
    */
    CURRENT_POSITION = 1,
}

/// The number of #PuglPositionHint values
NUM_POSITION_HINTS :: 2

/**
A hint for configuring/constraining the size of a view.

The system will attempt to make the view adhere to these, but they are
suggestions, not hard constraints.  Applications should handle any view size
gracefully.
*/
Size_Hint :: enum u32 {
    /**
    Default size.

    This is used as the size during window creation as a default, if no other
    size is specified.
    */
    DEFAULT_SIZE = 0,

    /**
    Current size.

    This reflects the current size of the view, which may be different from
    the default size if the view is resizable.  It overrides the default size.
    */
    CURRENT_SIZE = 1,

    /**
    Minimum size.

    If set, the view should be at least this large.
    */
    MIN_SIZE     = 2,

    /**
    Maximum size.

    If set, the view should be at most this large.
    */
    MAX_SIZE     = 3,

    /**
    Fixed aspect ratio.

    If set, the view should have this aspect ratio.  Mutually exclusive with
    #PUGL_MIN_ASPECT and #PUGL_MAX_ASPECT.
    */
    FIXED_ASPECT = 4,

    /**
    Minimum aspect ratio.

    If set, the view should have an aspect ratio no lower than this.  Mutually
    exclusive with #PUGL_FIXED_ASPECT.
    */
    MIN_ASPECT   = 5,

    /**
    Maximum aspect ratio.

    If set, the view should have an aspect ratio no higher than this.
    Mutually exclusive with #PUGL_FIXED_ASPECT.
    */
    MAX_ASPECT   = 6,
}

/// The number of #PuglSizeHint values
NUM_SIZE_HINTS :: 7

/// A function called when an event occurs
Event_Func :: proc "c" (view: ^View, event: ^Event) -> Status

/// A command to control the behaviour of puglShow()
Show_Command :: enum c.int {
    /**
    Realize and show the window without intentionally raising it.

    This will weakly "show" the window but without making any effort to raise
    it.  Depending on the platform or system configuration, the window may be
    raised above some others regardless.
    */
    PASSIVE     = 0,

    /**
    Raise the window to the top of the application's stack.

    This is the normal "well-behaved" way to show and raise the window, which
    should be used in most cases.
    */
    RAISE       = 1,

    /**
    Aggressively force the window to be raised to the top.

    This will attempt to raise the window to the top, even if this isn't the
    active application, or if doing so would otherwise go against the
    platform's guidelines.  This generally shouldn't be used, and isn't
    guaranteed to work.  On modern Windows systems, the active application
    must explicitly grant permission for others to steal the foreground from
    it.
    */
    FORCE_RAISE = 2,
}

/**
A mouse cursor type.

This is a portable subset of mouse cursors that exist on X11, MacOS, and
Windows.
*/
Cursor :: enum u32 {
    ARROW              = 0, ///< Default pointing arrow
    CARET              = 1, ///< Caret (I-Beam) for text entry
    CROSSHAIR          = 2, ///< Cross-hair
    HAND               = 3, ///< Hand with a pointing finger
    NO                 = 4, ///< Operation not allowed
    LEFT_RIGHT         = 5, ///< Left/right arrow for horizontal resize
    UP_DOWN            = 6, ///< Up/down arrow for vertical resize
    UP_LEFT_DOWN_RIGHT = 7, ///< Diagonal arrow for down/right resize
    UP_RIGHT_DOWN_LEFT = 8, ///< Diagonal arrow for down/left resize
    ALL_SCROLL         = 9, ///< Omnidirectional "arrow" for scrolling
}

/// The number of #PuglCursor values
NUM_CURSORS :: 10

@(default_calling_convention="c", link_prefix="pugl")
foreign lib {
    /// Return a string describing a status code
    Strerror :: proc(status: Status) -> cstring ---

    /**
       Create a new world.

       @param type The type, which dictates what this world is responsible for.
       @param flags Flags to control world features.
       @return A new world, which must be later freed with puglFreeWorld().
    */
    NewWorld :: proc(type: World_Type, flags: World_Flags) -> ^World ---


    /// Free a world allocated with puglNewWorld()
    FreeWorld :: proc(world: ^World)  ---

    /**
    Set the user data for the world.

    This is usually a pointer to a struct that contains all the state shared by
    any views.

    The handle is opaque to Pugl and isn't interpreted in any way.
    */
    SetWorldHandle :: proc(world: ^World, handle: rawptr) ---

    /// Get the user data for the world
    GetWorldHandle :: proc(world: ^World) -> rawptr ---

    /**
    Return the native world handle.

    The "native world" is a system-specific handle that's shared across an
    entire program or module.  It serves as a common denominator between Pugl,
    applications, and the windowing system API.

    X11: Returns a pointer to the `Display`.

    MacOS: Returns a pointer to the `NSApplication`.

    Windows: Returns the `HMODULE` of the calling process.
    */
    GetNativeWorld :: proc(world: ^World) -> rawptr ---

    /**
       Set a string property to configure the world or application.

       The string value only needs to be valid for the duration of this call, it
       will be copied if necessary.
    */
    SetWorldString :: proc(world: ^World, key: String_Hint, value: cstring) -> Status ---


    /**
    Get a world or application string property.

    The returned string should be accessed immediately or copied if necessary,
    it may be invalidated by any change to the same world.
    */
    GetWorldString :: proc(world: ^World, key: String_Hint) -> cstring ---

    /**
    Return the time in seconds.

    This is a monotonically increasing clock with high resolution.  The returned
    time is only useful to compare against other times returned by this
    function, its absolute value has no meaning.
    */
    GetTime :: proc(world: ^World) -> f64 ---


    /**
       Update by processing events from the window system.

       This runs a single iteration of the main loop, and needs to be called
       repeatedly to update all views.

       Plugins should always use a timeout of zero to avoid blocking the host.  For
       continuously animating programs, a timeout that's a reasonable fraction of
       the ideal frame period should be used, to minimize input latency by ensuring
       that as many input events are consumed as possible before drawing.

       @param world The world to update.

       @param timeout If zero, then this call won't block.  If positive, then
       events will be processed for that amount of time, starting from when this
       function was called.  If negative, then this call will block until an event
       occurs.

       @return #PUGL_SUCCESS if events are read, #PUGL_FAILURE if no events are
       read, or an error.
    */
    Update :: proc(world: ^World, timeout: f64) -> Status ---



    /**
       @defgroup pugl_setup Setup
       Functions for creating and destroying a view.
       @{
    */

    /**
       Create a new view.

       A newly created view doesn't correspond to a real system view or window
       until it's configured and realized.
    */
    NewView :: proc(world: ^World) -> ^View ---

    /// Free a view created with puglNewView()
    FreeView :: proc(view: ^View)  ---

    /// Return the world that `view` is a part of
    GetWorld :: proc(view: ^View) -> ^World ---

    /**
    Set the user data for a view.

    This is usually a pointer to a struct that contains all the state needed by
    a view.  Everything needed to process events should be stored here, not in
    static variables.

    The handle is opaque to Pugl and isn't interpreted in any way.
    */
    SetHandle :: proc(view: ^View, handle: rawptr) ---

    /// Get the user data for a view
    GetHandle :: proc(view: ^View) -> rawptr ---


    /**
       Set the graphics backend to use for a view.

       This must be called once to set the graphics backend before calling
    Realize().

       Pugl includes a "stub" backend for platform-specific applications, and
       several portable backends:

       - puglCairoBackend()
       - puglGlBackend()
       - puglVulkanBackend()

       These backends are modules that aren't compiled in to the main Pugl library
       to avoid unnecessary dependencies.  To use a particular backend,
       applications must link against the appropriate backend library, or be sure
       to compile in the appropriate code if using a local copy of Pugl.
    */
    SetBackend :: proc(view: ^View, backend: ^Backend) -> Status ---

    /// Return the graphics backend used by a view
    GetBackend :: proc(view: ^View) -> ^Backend ---

    /// Set the function to call when an event occurs
    SetEventFunc :: proc(view: ^View, eventFunc: Event_Func) -> Status ---

    /**
       Set a hint to configure view properties.

       This only has an effect when called before puglRealize().
    */
    SetViewHint :: proc(view: ^View, hint: View_Hint, value: c.int) -> Status ---


    /**
    Get the value for a view hint.

    If the view has been realized, this can be used to get the actual value of a
    hint which was initially set to PUGL_DONT_CARE, or has been adjusted from
    the suggested value.
    */
    GetViewHint :: proc(view: ^View, hint: View_Hint) -> c.int ---

    /**
       Set a string property to configure view properties.

       This is similar to puglSetViewHint() but sets hints with string values.  The
       string value only needs to be valid for the duration of this call, it will
       be copied if necessary.
    */
    SetViewString :: proc(view: ^View, key: String_Hint, value: cstring) -> Status ---


    /**
    Get a view string property.

    The returned string should be accessed immediately, or copied.  It may
    become invalid upon any call to any function that manipulates the same view.
    */
    GetViewString :: proc(view: ^View, key: String_Hint) -> cstring ---

    /**
    Return the scale factor of the view.

    This factor describe how large UI elements (especially text) should be
    compared to "normal".  For example, 2.0 means the UI should be drawn twice
    as large.  "Normal" is loosely defined as a typical default size on a
    "standard DPI" display (around 96 DPI).
    */
    GetScaleFactor :: proc(view: ^View) -> f64 ---

    /**
       Get a position hint for the view.

       This can be used to get the default or current position of a view, in screen
       coordinates with an upper left origin.
    */
    GetPositionHint :: proc(view: ^View, hint: Position_Hint) -> Point ---

    /**
       Set a position hint for the view.

       This can be used to set the default or current position of a view.

       This should be called before puglRealize() so the initial window for the
       view can be configured correctly.  It may also be used dynamically after the
       window is realized, for some hints.

       @return An error code on failure, but always succeeds if the view isn't yet
       realized.
    */
    SetPositionHint :: proc(view: ^View, hint: Position_Hint, x, y: c.int) -> Status ---

    /**
       Get a size hint for the view.

       This can be used to get the default, current, minimum, and maximum size of a
       view, as well as the supported range of aspect ratios.
    */
    GetSizeHint :: proc(view: ^View, hint: Size_Hint) -> Area ---

    /**
       Set a size hint for the view.

       This can be used to set the default, current, minimum, and maximum size of a
       view, as well as the supported range of aspect ratios.

       This should be called before puglRealize() so the initial window for the
       view can be configured correctly.  It may also be used dynamically after the
       window is realized, for some hints.

       @return An error code on failure, but always succeeds if the view isn't yet
       realized.
    */
    SetSizeHint :: proc(view: ^View, hint: Size_Hint, width, height: c.uint) -> Status ---

    /**
       @}
       @defgroup pugl_window Window
       Functions to control the top-level window of a view.
       @{
    */

    /**
       Set the native view the view will be embedded in.

       This must be called before puglRealize(), reparenting isn't supported.
    */
    SetParent :: proc(view: ^View, parent: Native_View) -> Status ---

    /**
       Return the native view that the view is embedded in.

       @return The native view handle of the parent that `view` is embedded in, or
       zero (if view is top-level or unrealized).
    */
    GetParent :: proc(view: ^View) -> Native_View ---

    /**
       Set the transient parent of the window.

       Set this for transient children like dialogs, to have them properly
       associated with their parent window.  This should be called before
    Realize().

       A view can either have a parent (for embedding) or a transient parent (for
       top-level windows like dialogs), but not both.
    */
    SetTransientParent :: proc(view: ^View, parent: Native_View) -> Status ---

    /**
       Return the transient parent of the window.

       @return The native handle to the window this view is a transient child of,
       or null.
    */
    GetTransientParent :: proc(view: ^View) -> Native_View ---

    /**
       Realize a view by creating a corresponding system view or window.

       After this call, the (initially invisible) underlying system view exists and
       can be accessed with GetNativeView().

       The view should be fully configured using the above functions before this is
       called.  This function may only be called once per view.
    */
    Realize :: proc(view: ^View) -> Status ---

    /**
       Unrealize a view by destroying the corresponding system view or window.

       This is the inverse of puglRealize().  After this call, the view no longer
       corresponds to a real system view, and can be realized again later.
    */
    Unrealize :: proc(view: ^View) -> Status ---


    /**
       Show the view.

       If the view has not yet been realized, the first call to this function will
       do so automatically.  If the view is currently hidden, it will be shown and
       possibly raised to the top depending on the platform.

       @return #PUGL_SUCCESS, an error from realization, or #PUGL_FAILURE if the
       window was shown but not raised.
    */
    Show :: proc(view: ^View, command: Show_Command) -> Status ---

    /**
       Hide the view.

       This is the counterpart to puglShow().  If the view is currently visible, it
       will be hidden, otherwise, this does nothing.
    */
    Hide :: proc(view: ^View) -> Status ---

    /**
       Set a view style, if supported by the system.

       This can be used to manipulate the window into various special states, but
       note that not all states are supported on all systems.  This function may
       return failure or an error if the platform implementation doesn't
       "understand" how to set the given style, but the return value here can't be
       used to determine if the state has actually been set.  Any changes to the
       actual state of the view will arrive in later configure events.
    */
    SetViewStyle :: proc(view: ^View, flags: View_Style_Flags) -> Status ---

    /// Return the style flags currently set for a view
    GetViewStyle :: proc(view: ^View) -> View_Style_Flags ---

    /// Return true iff the view is currently visible
    GetVisible :: proc(view: ^View) -> bool ---

    /// Return the native window handle
    GetNativeView :: proc(view: ^View) -> Native_View ---


    /**
    Get the graphics context.

    This is a backend-specific context used for drawing if the backend graphics
    API requires one.  It's only available during an expose.

    Cairo: Returns a pointer to a
    [cairo_t](http://www.cairographics.org/manual/cairo-cairo-t.html).

    All other backends: returns null.
    */
    GetContext :: proc(view: ^View) -> rawptr ---

    /**
       Request a redisplay for the entire view.

       This will cause an expose event to be dispatched later.  If called from
       within the event handler, the expose should arrive at the end of the current
       event loop iteration, though this isn't strictly guaranteed on all
       platforms.  If called elsewhere, an expose will be enqueued to be processed
       in the next event loop iteration.
    */
    ObscureView :: proc(view: ^View) -> Status ---

    /**
       "Obscure" a region so it will be exposed in the next render.

       This will cause an expose event to be dispatched later.  If called from
       within the event handler, the expose should arrive at the end of the current
       event loop iteration, though this isn't strictly guaranteed on all
       platforms.  If called elsewhere, an expose will be enqueued to be processed
       in the next event loop iteration.

       The region is clamped to the size of the view if necessary.

       @param view The view to expose later.
       @param x The top-left X coordinate of the rectangle to obscure.
       @param y The top-left Y coordinate of the rectangle to obscure.
       @param width The width of the rectangle to obscure.
       @param height The height coordinate of the rectangle to obscure.
    */
    ObscureRegion :: proc(view: ^View, x, y: c.int, width, height: c.uint) -> Status ---




    /**
       Grab the keyboard input focus.

       Note that this will fail if the view isn't mapped and so shouldn't, for
       example, be called immediately after puglShow().

       @return #PUGL_SUCCESS if the focus was successfully grabbed, or an error.
    */
    GrabFocus :: proc(view: ^View) -> Status ---

    /**
       Return whether `view` has the keyboard input focus.

       @return True if the view is realized and focused for keyboard input.
    */
    HasFocus :: proc(view: ^View) -> bool ---

    /**
       Request data from the general copy/paste clipboard.

       A #PUGL_DATA_OFFER event will be sent if data is available.
    */
    Paste :: proc(view: ^View) -> Status ---

    /**
       Return the number of types available for the data in a clipboard.

       Returns zero if the clipboard is empty.
    */
    GetNumClipboardTypes :: proc(view: ^View) -> u32 ---

    /**
        Return the identifier of a type available in a clipboard.

        This is usually a MIME type, but may also be another platform-specific type
        identifier.  Applications must ignore any type they don't recognize.

        Returns null if `typeIndex` is out of bounds according to
        puglGetNumClipboardTypes().
    */
    GetClipboardType :: proc(view: ^View, typeIndex: u32) -> cstring ---

    /**
       Accept data offered from a clipboard.

       To accept data, this must be called while handling a #PUGL_DATA_OFFER event.
       Doing so will request the data from the source as the specified type.  When
       the data is available, a #PUGL_DATA event will be sent to the view which can
       then retrieve the data with puglGetClipboard().

       @param view The view.

       @param offer The data offer event.

       @param typeIndex The index of the type that the view will accept.  This is
       the `typeIndex` argument to the call of puglGetClipboardType() that returned
       the accepted type.
    */
    AcceptOffer :: proc(view: ^View, offer: ^Data_Offer_Event, typeIndex: u32) -> Status ---

    /**
       Set the clipboard contents.

       This sets the system clipboard contents, which can be retrieved with
    GetClipboard() or pasted into other applications.

       @param view The view.
       @param type The MIME type of the data, "text/plain" is assumed if `NULL`.
       @param data The data to copy to the clipboard.
       @param len The length of data in bytes (including terminator if necessary).
    */
    SetClipboard :: proc(view: ^View, type: cstring, data: rawptr, len: c.size_t) -> Status ---

    /**
        Get the clipboard contents.

        This gets the system clipboard contents, which may have been set with
        puglSetClipboard() or copied from another application.

        @param view The view.
        @param typeIndex Index of the data type to get the item as.
        @param[out] len Set to the length of the data in bytes.
        @return The clipboard contents, or null.
    */
    GetClipboard :: proc(view: ^View, typeIndex: u32, len: ^c.size_t) -> rawptr ---

    /**
        Set the mouse cursor.

        This changes the system cursor that is displayed when the pointer is inside
        the view.  May fail if setting the cursor isn't supported on this system,
        for example if compiled on X11 without Xcursor support.

        @return #PUGL_BAD_PARAMETER if the given cursor is invalid,
        #PUGL_UNSUPPORTED if setting the cursor isn't supported on this system, or
        another error if the cursor is known but loading it fails.
    */
    SetCursor :: proc(view: ^View, cursor: Cursor) -> Status ---

    /**
       Activate a repeating timer event.

       This starts a timer which will send a #PuglTimerEvent to `view` every
       `timeout` seconds.  This can be used to perform some action in a view at a
       regular interval with relatively low frequency.  Note that the frequency of
       timer events may be limited by how often puglUpdate() is called.

       If the given timer already exists, it is replaced.

       @param view The view to begin sending #PUGL_TIMER events to.

       @param id The identifier for this timer.  This is an application-specific
       ID, usually a small positive integer enumerator.  Only a limited number of
       timers is supported, and each adds overhead, so applications should create
       only a few timers, and perform several tasks in each if necessary.

       @param timeout The period, in seconds, of this timer.  The maximum supported
       resolution is about 10 ms on Windows, and about 1 ms on X11 and MacOS.

       @return #PUGL_FAILURE if timers aren't supported by the system,
       #PUGL_UNKNOWN_ERROR if setting the timer failed.
    */
    StartTimer :: proc(view: ^View, id: uintptr, timeout: f64) -> Status ---

    /**
       Stop an active timer.

       @param view The view that the timer is set for.
       @param id The ID previously passed to puglStartTimer().

       @return #PUGL_FAILURE if timers aren't supported by this system,
       #PUGL_UNKNOWN_ERROR if stopping the timer failed.
    */
    StopTimer :: proc(view: ^View, id: uintptr) -> Status ---

    /**
       Send an event to a view via the window system.

       If supported, the event will be delivered to the view via the event loop
       like any other.  Only a few event types are currently supported.

       Opaque #PUGL_CLIENT events are supported on all platforms.

       X11: A #PUGL_EXPOSE event can be sent, which is similar to calling
    ObscureRegion(), but will always send a message to the X server, even
       when called in an event handler.

       @return #PUGL_UNSUPPORTED if sending this type of event isn't supported in
       general, #PUGL_FAILURE if the event can't be sent now.
    */
    SendEvent :: proc(view: ^View, event: ^Event) -> Status ---

}

