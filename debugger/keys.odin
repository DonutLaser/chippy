package debugger

import "../gui"
import "core:fmt"

@(private = "file")
Key :: struct {
	on:            bool,
	text:          cstring,
	width, height: u16,
}

@(private = "file")
Keys :: struct {
	data:         [16]Key,
	render_order: [16]u16,
}

@(private = "file")
state: Keys

keys_init :: proc() {
	main_font := assets_get_font(28)

	state = Keys{}
	for i := 0; i < 16; i += 1 {
		state.data[i].on = false
		state.data[i].text = fmt.caprintf("%X", i)

		width, height := gui.measure_text(&main_font, state.data[i].text)
		state.data[i].width = width
		state.data[i].height = height
	}

	// Render order is the following:
	// 1 2 3 C
	// 4 5 6 D
	// 7 8 9 E
	// A 0 B F
	state.render_order = [16]u16{0x1, 0x2, 0x3, 0xC, 0x4, 0x5, 0x6, 0xD, 0x7, 0x8, 0x9, 0xE, 0xA, 0x0, 0xB, 0xF}
}

keys_kill :: proc() {
	for key in state.data {
		delete(key.text)
	}
}

keys_update :: proc(keys: [16]bool) {
	for key, index in keys {
		state.data[index].on = key
	}
}

keys_render :: proc() {
	ui_begin_container_horizontal(172, "Keys", gui.Color{47, 47, 47, 255}) // @magic_number

	key_width: i32 = 172 / 4
	key_height: i32 = 172 / 4

	main_font := assets_get_font(28)

	index := 0
	for y: i32 = 0; y < 4; y += 1 {
		for x: i32 = 0; x < 4; x += 1 {
			base_rect := gui.Rect {
				x = x * key_width,
				y = y * key_height,
				w = key_width,
				h = key_height,
			}

			key := state.data[state.render_order[index]]
			color := gui.WHITE
			if key.on {
				color = gui.Color{228, 189, 71, 255} // @magic_number
			}

			rect := gui.Rect {
				x = base_rect.x + base_rect.w / 2 - i32(key.width) / 2,
				y = base_rect.y + base_rect.h / 2 - i32(key.height) / 2,
				w = i32(key.width),
				h = i32(key.height),
			}
			ui_draw_text(key.text, &main_font, rect, color)

			index += 1
		}
	}

	ui_end_container_horizontal()
}
