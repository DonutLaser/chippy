package gui

import sdl "vendor:sdl2"

Rect :: struct {
	x, y, w, h: i32,
}

rect_to_sdl_rect :: proc(rect: Rect) -> sdl.Rect {
	return sdl.Rect{rect.x, rect.y, rect.w, rect.h}
}
