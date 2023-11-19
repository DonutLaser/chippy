package debugger

import "../gui"

display_render :: proc(pixels: []u8, display_width: u16, display_height: u16, pixel_size: u8) {
	ui_begin_container_horizontal(display_height * u16(pixel_size), "Display", gui.BLACK)

	for y: i32 = 0; y < i32(display_height); y += 1 {
		for x: i32 = 0; x < i32(display_width); x += 1 {
			pixel := pixels[y * i32(display_width) + x]
			if pixel == 1 {
				ui_draw_rect(gui.Rect{x = x * i32(pixel_size), y = y * i32(pixel_size), w = i32(pixel_size), h = i32(pixel_size)}, gui.WHITE)
			}
		}
	}

	ui_end_container_horizontal()
}
