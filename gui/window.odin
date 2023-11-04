package gui

import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

WINDOW_WIDTH :: 934
WINDOW_HEIGHT :: 712

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
window_init :: proc() -> bool {
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

	window := sdl.CreateWindow("Chip8 Debugger", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, {})
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
