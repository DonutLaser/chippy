package debugger

import "../gui"
import "core:fmt"

@(private = "file")
Register :: struct {
	value:         u8,
	text:          cstring,
	width, height: u16,
}

@(private = "file")
GPRS :: struct {
	registers: [16]Register,
}

@(private = "file")
state: GPRS

gprs_init :: proc() {
	state = GPRS{}

	main_font := assets_get_font(16)
	for i := 0; i < 16; i += 1 {
		state.registers[i].value = 0
		state.registers[i].text = fmt.caprintf("V%X: %d", i, state.registers[i].value)

		width, height := gui.measure_text(&main_font, state.registers[i].text)
		state.registers[i].width = width
		state.registers[i].height = height
	}
}

gprs_kill :: proc() {
	for register in state.registers {
		delete(register.text)
	}
}

gprs_update :: proc(registers: [16]u8) {
	main_font := assets_get_font(16)

	for register, index in registers {
		if state.registers[index].value == register {
			continue
		}

		state.registers[index].value = register
		delete(state.registers[index].text)
		state.registers[index].text = fmt.caprintf("V%X: %d", index, state.registers[index].value)

		width, height := gui.measure_text(&main_font, state.registers[index].text)
		state.registers[index].width = width
		state.registers[index].height = height
	}
}

gprs_render :: proc() {
	container_rect := gui.Rect {
		x = 328 + PADDING * 2, // @magic_number
		y = 356, // @magic_number
		w = 178, // @magic_number
		h = 140, // @magic_number
	}
	ui_begin_container(container_rect, "GP Registers", gui.Color{47, 47, 47, 255}) // @magic_number

	x: i32 = PADDING

	main_font := assets_get_font(16)
	for register, index in state.registers {
		rect := gui.Rect {
			x = x,
			y = PADDING / 2 + i32(index % 8) * i32(register.height),
			w = i32(register.width),
			h = i32(register.height),
		}
		ui_draw_text(register.text, &main_font, rect, gui.WHITE)

		if index == 7 {
			x += 87 // @magic_number
		}
	}

	ui_end_container()
}
