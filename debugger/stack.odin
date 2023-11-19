package debugger

import "../gui"
import "core:fmt"

@(private = "file")
Value :: struct {
	value:         u16,
	text:          cstring,
	width, height: u16,
}

@(private = "file")
Stack :: struct {
	top:    u8,
	values: [16]Value,
}

@(private = "file")
state: Stack

stack_init :: proc() {
	state = Stack{}

	main_font := assets_get_font(16)
	for i := 0; i < 16; i += 1 {
		state.values[i] = Value{}
		state.values[i].value = 0
		state.values[i].text = fmt.caprintf("%X: 0x%X", i, state.values[i].value)

		width, height := gui.measure_text(&main_font, state.values[i].text)
		state.values[i].width = width
		state.values[i].height = height
	}
}

stack_kill :: proc() {
	for value in state.values {
		delete(value.text)
	}
}

stack_update :: proc(values: [16]u16) {
	main_font := assets_get_font(16)

	for value, index in values {
		if state.values[index].value == value {
			continue
		}

		state.values[index].value = value
		delete(state.values[index].text)
		state.values[index].text = fmt.caprintf("%X: 0x%X", index, state.values[index].value)

		width, height := gui.measure_text(&main_font, state.values[index].text)
		state.values[index].width = width
		state.values[index].height = height
	}
}

stack_set_stack_top :: proc(top: u8) {
	state.top = top
}

stack_render :: proc() {
	ui_begin_container_horizontal(268, "Stack", gui.Color{47, 47, 47, 255}) // @magic_number

	main_font := assets_get_font(16)
	for i: i8 = 15; i >= 0; i -= 1 {
		color := gui.WHITE
		if state.top == u8(i) {
			color = gui.Color{228, 189, 71, 255} // @magic_number
		}

		rect := gui.Rect {
			x = PADDING,
			y = PADDING + i32(15 - i) * i32(state.values[i].height),
			w = i32(state.values[i].width),
			h = i32(state.values[i].height),
		}
		ui_draw_text(state.values[i].text, &main_font, rect, color)
	}

	ui_end_container_horizontal()
}
