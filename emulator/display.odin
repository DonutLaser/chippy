package emulator

import "core:fmt"
import sdl "vendor:sdl2"

DISPLAY_WIDTH :: 64
DISPLAY_HEIGHT :: 32

Display :: struct {
	window:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    u8,
	height:   u8,
	scale:    u8,
	pixels:   [DISPLAY_WIDTH * DISPLAY_HEIGHT]u8, // @wasted_memory
}

display_new :: proc(scale: u8) -> (Display, bool) {
	ok := sdl.Init(sdl.INIT_EVERYTHING)
	if ok != 0 {
		print_sdl_error()
		return Display{}, false
	}

	sdl.GL_SetAttribute(sdl.GLattr.FRAMEBUFFER_SRGB_CAPABLE, 1)

	width := DISPLAY_WIDTH * u16(scale)
	height := DISPLAY_HEIGHT * u16(scale)

	window := sdl.CreateWindow("Chip8", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, i32(width), i32(height), {})
	if window == nil {
		print_sdl_error()
		return Display{}, false
	}

	renderer := sdl.CreateRenderer(window, -1, {.ACCELERATED, .PRESENTVSYNC})
	if renderer == nil {
		print_sdl_error()
		return Display{}, false
	}

	return Display{window = window, renderer = renderer, width = DISPLAY_WIDTH, height = DISPLAY_HEIGHT, scale = scale}, true
}

display_kill :: proc(display: ^Display) {
	sdl.DestroyRenderer(display.renderer)
	sdl.DestroyWindow(display.window)

	sdl.Quit()
}

display_clear :: proc(display: ^Display) {
	for i := 0; i < len(display.pixels); i += 1 {
		display.pixels[i] = 0
	}
}

display_draw_sprite :: proc(display: ^Display, x: u8, y: u8, data: []u8) -> bool {
	result := false

	cursor_x := u16(x)
	cursor_y := u16(y)

	for b in data {
		pixels := get_pixels_from_byte(b)
		for pixel in pixels {
			old_value := display.pixels[cursor_y * u16(display.width) + cursor_x]
			display.pixels[cursor_y * u16(display.width) + cursor_x] = old_value ~ pixel
			new_value := display.pixels[cursor_y * u16(display.width) + cursor_x]

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

display_render :: proc(display: ^Display) {
	sdl.SetRenderDrawColor(display.renderer, 0, 0, 0, 255)
	sdl.RenderClear(display.renderer)

	sdl.SetRenderDrawColor(display.renderer, 255, 255, 255, 255)
	for y: u16 = 0; y < u16(display.height); y += 1 {
		for x: u16 = 0; x < u16(display.width); x += 1 {
			pixel := display.pixels[y * u16(display.width) + x]
			if pixel == 1 {
				rect := sdl.Rect {
					x = i32(x * u16(display.scale)),
					y = i32(y * u16(display.scale)),
					w = i32(display.scale),
					h = i32(display.scale),
				}
				sdl.RenderFillRect(display.renderer, &rect)
			}
		}
	}

	sdl.RenderPresent(display.renderer)
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

@(private = "file")
print_sdl_error :: proc() {
	err := sdl.GetError()
	fmt.eprintf("Error: %s\n", err)
}
