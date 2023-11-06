package computer

import "core:fmt"
import sdl "vendor:sdl2"

DISPLAY_WIDTH :: 64
DISPLAY_HEIGHT :: 32

@(private)
Display :: struct {
	pixels: [DISPLAY_WIDTH * DISPLAY_HEIGHT]u8, // @wasted_memory
}

@(private)
display_new :: proc() -> Display {
	return Display{pixels = [DISPLAY_WIDTH * DISPLAY_HEIGHT]u8{}}
}

@(private)
display_clear :: proc(display: ^Display) {
	for i := 0; i < len(display.pixels); i += 1 {
		display.pixels[i] = 0
	}
}

@(private)
display_draw_sprite :: proc(display: ^Display, x: u8, y: u8, data: []u8) -> bool {
	result := false

	cursor_x := u16(x)
	cursor_y := u16(y)

	for b in data {
		pixels := get_pixels_from_byte(b)
		for pixel in pixels {
			old_value := display.pixels[cursor_y * DISPLAY_WIDTH + cursor_x]
			display.pixels[cursor_y * DISPLAY_WIDTH + cursor_x] = old_value ~ pixel
			new_value := display.pixels[cursor_y * DISPLAY_WIDTH + cursor_x]

			if old_value == 1 && new_value == 0 {
				result = true
			}

			if cursor_x == DISPLAY_WIDTH - 1 {
				cursor_x = 0
			} else {
				cursor_x += 1
			}
		}

		if cursor_y == DISPLAY_HEIGHT - 1 {
			cursor_y = 0
		} else {
			cursor_y += 1
		}

		cursor_x = u16(x)
	}

	return result
}

@(private = "file")
get_pixels_from_byte :: proc(b: u8) -> [8]u8 {
	result := [8]u8{}

	start: u8 = 1
	for i: u8 = 0; i < 8; i += 1 {
		result[7 - i] = (b & start) >> i
		start <<= 1
	}

	return result
}
