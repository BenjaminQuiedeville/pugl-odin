// Copyright 2012-2023 David Robillard <d@drobilla.net>
// SPDX-License-Identifier: ISC

/*
  Note that this header includes Vulkan headers, so if you are writing a
  program or plugin that dynamically loads vulkan, you should first define
  `VK_NO_PROTOTYPES` before including it.
*/
package pugl

import vulkan "vendor:vulkan"

Vulkan_Loader :: struct {}

@(default_calling_convention="c", link_prefix="pugl")
foreign lib {
    /**
       Create a new dynamic loader for Vulkan functions.

       This dynamically loads the Vulkan library and gets the load functions from
       it.

       @param world The world the returned loader is a part of.

       @param libraryName The name of the Vulkan library to load, or null.
       Typically, this is left unset, which will load the standard Vulkan library
       for the current platform.  It can be set to an alternative name, or an
       absolute path, to support special packaging scenarios or unusual system
       configurations.  This name is passed directly to the underlying platform
       library loading function (`dlopen` or `LoadLibrary`).

       @return A new Vulkan loader, or null on failure.
    */
    NewVulkanLoader :: proc(world: ^World, libraryName: cstring) -> ^Vulkan_Loader ---

    /**
       Free a loader created with NewVulkanLoader().

       Note that this closes the Vulkan library, so the Vulkan API can no longer be
       used.
    */
    FreeVulkanLoader :: proc(loader: ^Vulkan_Loader)  ---

    /**
       Return the `vkGetInstanceProcAddr` function.

       @return Null if the Vulkan library does not contain this function (which is
       unlikely and indicates a broken system).
    */
    GetInstanceProcAddrFunc :: proc(loader: ^Vulkan_Loader) -> vulkan.ProcGetInstanceProcAddr ---

    /**
       Return the `vkGetDeviceProcAddr` function.

       @return Null if the Vulkan library does not contain this function (which is
       unlikely and indicates a broken system).
    */
    GetDeviceProcAddrFunc :: proc(loader: ^Vulkan_Loader) ->  vulkan.ProcGetDeviceProcAddr ---

    /**
       Return the Vulkan instance extensions required to draw to a PuglView.

       This simply returns static strings, it does not access Vulkan or the window
       system.  The returned array always contains at least "VK_KHR_surface".

       @param[out] count The number of extensions in the returned array.
       @return An array of extension name strings.
    */
    GetInstanceExtensions :: proc(count: ^u32) -> [^]cstring ---

    /**
       Create a Vulkan surface for a Pugl view.

       @param vkGetInstanceProcAddr Accessor for Vulkan functions.
       @param view The view the surface is to be displayed on.
       @param instance The Vulkan instance.
       @param allocator Vulkan allocation callbacks, may be NULL.
       @param[out] surface Pointed to a newly created Vulkan surface.
       @return `VK_SUCCESS` on success, or a Vulkan error code.
    */
    CreateSurface :: proc(vkGetInstanceProcAddr: vulkan.ProcGetInstanceProcAddr, view: ^View, instance: vulkan.Instance, allocator: ^vulkan.AllocationCallbacks, surface: ^vulkan.SurfaceKHR) ->  vulkan.Result ---

    /**
       Vulkan graphics backend.

       Pass the returned value to SetBackend() to draw to a view with Vulkan.
    */
    VulkanBackend :: proc() -> ^Backend ---
}

