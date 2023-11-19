package debugger

import "../gui"
import "core:fmt"

@(private = "file")
Register :: struct {
	value:         u16,
	text:          cstring,
	width, height: u16,
}

@(private = "file")
Other_Registers :: struct {
	I:  Register,
	PC: Register,
	SP: Register,
}

@(private = "file")
state: Other_Registers

other_registers_init :: proc() {
	state = Other_Registers{}
	state.I = Register {
		value = 0,
		text  = fmt.caprintf("I:  0x%X", 0),
	}
	state.PC = Register {
		value = 0,
		text  = fmt.caprintf("PC: 0x%X", 0),
	}
	state.SP = Register {
		value = 0,
		text  = fmt.caprintf("SP: %X", 0),
	}

	main_font := assets_get_font(16)

	width, height := gui.measure_text(&main_font, state.I.text)
	state.I.width = width
	state.I.height = height

	width, height = gui.measure_text(&main_font, state.PC.text)
	state.PC.width = width
	state.PC.height = height

	width, height = gui.measure_text(&main_font, state.SP.text)
	state.SP.width = width
	state.SP.height = height
}

other_registers_kill :: proc() {
	delete(state.I.text)
	delete(state.PC.text)
	delete(state.SP.text)
}

other_registers_update :: proc(I: u16, SP: u16, PC: u16) {
	main_font := assets_get_font(16)

	if (state.I.value != I) {
		state.I.value = I
		delete(state.I.text)
		state.I.text = fmt.caprintf("I:  0x%X", state.I.value)
		width, height := gui.measure_text(&main_font, state.I.text)
		state.I.width = width
		state.I.height = height
	}

	if (state.PC.value != PC) {
		state.PC.value = PC
		delete(state.PC.text)
		state.PC.text = fmt.caprintf("PC: 0x%X", state.PC.value)
		width, height := gui.measure_text(&main_font, state.PC.text)
		state.PC.width = width
		state.PC.height = height
	}

	if (state.SP.value != SP) {
		state.SP.value = SP
		delete(state.SP.text)
		state.SP.text = fmt.caprintf("SP: %X", state.SP.value)
		width, height := gui.measure_text(&main_font, state.SP.text)
		state.SP.width = width
		state.SP.height = height
	}
}

other_registers_render :: proc() {
	ui_begin_container_horizontal(70, "Other Registers", gui.Color{47, 47, 47, 255}) // @magic_number

	main_font := assets_get_font(16)
	y: i32 = PADDING

	I_rect := gui.Rect {
		x = PADDING,
		y = y,
		w = i32(state.I.width),
		h = i32(state.I.height),
	}
	ui_draw_text(state.I.text, &main_font, I_rect, gui.WHITE)
	y += i32(state.I.height) + PADDING

	PC_rect := gui.Rect {
		x = PADDING,
		y = y,
		w = i32(state.PC.width),
		h = i32(state.PC.height),
	}
	ui_draw_text(state.PC.text, &main_font, PC_rect, gui.WHITE)
	y += i32(state.PC.height) + PADDING

	SP_rect := gui.Rect {
		x = PADDING,
		y = y,
		w = i32(state.SP.width),
		h = i32(state.SP.height),
	}
	ui_draw_text(state.SP.text, &main_font, SP_rect, gui.WHITE)

	ui_end_container_horizontal()
}
