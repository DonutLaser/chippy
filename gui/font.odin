package gui

import "core:fmt"
import "core:strings"
import ttf "vendor:sdl2/ttf"

Font :: struct {
	instance:   ^ttf.Font,
	size:       u16,
	char_width: u16,
}

load_font :: proc(path: cstring, size: u16) -> (Font, bool) {
	data := ttf.OpenFont(path, i32(size))
	if data == nil {
		print_ttf_error()
		return Font{}, false
	}

	minx, maxx, miny, maxy, advance: i32
	ok := ttf.GlyphMetrics(data, 'm', &minx, &maxx, &miny, &maxy, &advance)
	if ok != 0 {
		print_ttf_error()
		return Font{}, false
	}

	return Font{instance = data, size = size, char_width = u16(advance)}, true
}

close_font :: proc(font: ^Font) {
	ttf.CloseFont(font.instance)
}

measure_text :: proc(font: ^Font, text: cstring) -> (u16, u16) {
	return u16(len(text)) * font.char_width, font.size
}
