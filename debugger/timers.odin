package debugger

import "../gui"
import "core:fmt"

@(private = "file")
Timer :: struct {
	value:         u8,
	text:          cstring,
	width, height: u16,
}

@(private = "file")
Timers :: struct {
	DT: Timer,
	ST: Timer,
}

@(private = "file")
state: Timers

timers_init :: proc() {
	state = Timers{}
	state.DT = Timer {
		value = 0,
		text  = fmt.caprintf("DT: 0x%X", 0),
	}
	state.ST = Timer {
		value = 0,
		text  = fmt.caprintf("ST: 0x%X", 0),
	}

	main_font := assets_get_font(16)

	width, height := gui.measure_text(&main_font, state.DT.text)
	state.DT.width = width
	state.DT.height = height

	width, height = gui.measure_text(&main_font, state.ST.text)
	state.ST.width = width
	state.ST.height = height
}

timers_kill :: proc() {
	delete(state.DT.text)
	delete(state.ST.text)
}

timers_update :: proc(DT: u8, ST: u8) {
	main_font := assets_get_font(16)

	if (state.DT.value != DT) {
		state.DT.value = DT
		delete(state.DT.text)
		state.DT.text = fmt.caprintf("DT: 0x%X", state.DT.value)
		width, height := gui.measure_text(&main_font, state.DT.text)
		state.DT.width = width
		state.DT.height = height
	}

	if (state.ST.value != ST) {
		state.ST.value = ST
		delete(state.ST.text)
		state.ST.text = fmt.caprintf("ST: 0x%X", state.ST.value)
		width, height := gui.measure_text(&main_font, state.ST.text)
		state.ST.width = width
		state.ST.height = height
	}
}

timers_render :: proc() {
	container_rect := gui.Rect {
		x = 518 + PADDING * 2, // @magic_number
		y = 459, // @magic_number
		w = 178, // @magic_number
		h = 50, // @magic_number
	}
	ui_begin_container(container_rect, "Timers", gui.Color{47, 47, 47, 255}) // @magic_number

	main_font := assets_get_font(16)
	y: i32 = PADDING / 2

	DT_rect := gui.Rect {
		x = PADDING,
		y = y,
		w = i32(state.DT.width),
		h = i32(state.DT.height),
	}
	ui_draw_text(state.DT.text, &main_font, DT_rect, gui.WHITE)
	y += i32(state.DT.height) + PADDING / 2

	ST_rect := gui.Rect {
		x = PADDING,
		y = y,
		w = i32(state.ST.width),
		h = i32(state.ST.height),
	}
	ui_draw_text(state.ST.text, &main_font, ST_rect, gui.WHITE)
	y += i32(state.ST.height) + PADDING / 2

	ui_end_container()
}
