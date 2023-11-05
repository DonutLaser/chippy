package gui

import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
// WINDOW_WIDTH :: 934
// WINDOW_HEIGHT :: 712

@(private = "file")
instance: Window

@(private)
Window :: struct {
	internal: ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    u16,
	height:   u16,
}

@(private)
window_init :: proc(width: u16, height: u16, title: cstring) -> bool {
	ok := sdl.Init(sdl.INIT_EVERYTHING)
	if ok != 0 {
		print_sdl_error()
		return false
	}

	ok = ttf.Init()
	if ok != 0 {
		print_ttf_error()
		return false
	}

	sdl.GL_SetAttribute(sdl.GLattr.FRAMEBUFFER_SRGB_CAPABLE, 1)

	actual_width := width
	if actual_width == 0 {actual_width = WINDOW_WIDTH}
	actual_height := height
	if actual_height == 0 {actual_height = WINDOW_HEIGHT}
	actual_title := title
	if actual_title == "" {actual_title = "New window"}

	window := sdl.CreateWindow(actual_title, sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, i32(actual_width), i32(actual_height), {})
	if window == nil {
		print_sdl_error()
		return false
	}

	instance = Window {
		internal = window,
		width    = WINDOW_WIDTH,
		height   = WINDOW_HEIGHT,
	}

	return true
}

@(private)
window_kill :: proc() {
	sdl.DestroyWindow(instance.internal)

	sdl.Quit()
}

@(private)
window_instance :: proc() -> ^Window {
	return &instance
}
