package main

import "base:intrinsics"
import "core:fmt"
import "vendor:glfw"

Window :: struct {
	handlerID: glfw.WindowHandle,
	Width:     i32,
	Height:    i32,
	Title:     cstring,
}

NewWindow :: proc(width, height: i32, title: cstring) -> ^Window {
	window := new(Window)
	window.Width = width
	window.Height = height
	window.Title = title

    // Window hints to config OpenGL version and profile
	glfw.WindowHint(glfw.RESIZABLE, false)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)


	// open window
	window.handlerID = glfw.CreateWindow(window.Width, window.Height, window.Title, nil, nil)
	if window.handlerID == nil {
		fmt.println("Error creating glfw window")
		intrinsics.debug_trap()
	}

	return window
}
