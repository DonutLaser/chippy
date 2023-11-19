package debugger

import "../gui"

@(private = "file")
SCROLL_SPEED := 20

@(private = "file")
Instruction_Line :: struct {
	text:          cstring,
	width, height: u16,
}

@(private = "file")
Instructions :: struct {
	current_instruction: u16,
	lines:               []Instruction_Line,
	scroll_offset:       i32,
}

@(private = "file")
state: Instructions

instructions_init :: proc(instructions: [dynamic]cstring) {
	state = Instructions {
		current_instruction = 0,
		lines               = make([]Instruction_Line, len(instructions)),
	}

	main_font := assets_get_font(16)
	for instruction, index in instructions {
		width, height := gui.measure_text(&main_font, instruction)
		state.lines[index] = Instruction_Line {
			text   = instruction,
			width  = width,
			height = height,
		}
	}
}

instructions_kill :: proc() {
	delete(state.lines)
}

instructions_set_current_instruction :: proc(index: u16) {
	state.current_instruction = index
}

instructions_tick :: proc() {
	state.scroll_offset += gui.input_get_wheel()
	if state.scroll_offset > 0 {
		state.scroll_offset = 0
	}
}

instructions_render :: proc() {
	ui_begin_container_vertical(326, "Instructions", gui.Color{22, 21, 21, 255}) // @magic_number

	main_font := assets_get_font(16)
	for line, index in state.lines {
		color := gui.Color{125, 125, 125, 255} // @magic_number
		if state.current_instruction == u16(index) {
			color = gui.Color{228, 189, 71, 255} // @magic_number
		}

		rect := gui.Rect {
			x = PADDING,
			y = PADDING / 2 + i32(index) * i32(line.height) + state.scroll_offset * i32(SCROLL_SPEED),
			w = i32(line.width),
			h = i32(line.height),
		}
		ui_draw_text(line.text, &main_font, rect, color)
	}

	ui_end_container_vertical()
}
