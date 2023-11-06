package gui

import sdl "vendor:sdl2"

Rect :: struct {
	x, y, w, h: i32,
}

rect_to_sdl_rect :: proc(rect: Rect) -> sdl.Rect {
	return sdl.Rect{rect.x, rect.y, rect.w, rect.h}
}

rect_are_equal :: proc(r1: Rect, r2: Rect) -> bool {
	return r1.x == r2.x && r1.y == r2.y && r1.w == r2.w && r1.h == r2.h
}
