package debugger

import "../gui"

@(private = "file")
Instruction_Line :: struct {
	text:          cstring,
	width, height: u16,
}

@(private = "file")
Instructions :: struct {
	current_instruction: u16,
	lines:               []Instruction_Line,
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

instructions_render :: proc() {
	container_rect := gui.Rect {
		x = PADDING,
		y = PADDING + CONTAINER_TITLE_HEIGHT,
		w = 326, // @magic_number
		h = WINDOW_HEIGHT - PADDING * 2 - CONTAINER_TITLE_HEIGHT,
	}
	ui_begin_container(container_rect, "Instructions")

	main_font := assets_get_font(16)
	for line, index in state.lines {
		rect := gui.Rect {
			x = PADDING,
			y = PADDING + i32(index) * i32(line.height),
			w = i32(line.width),
			h = i32(line.height),
		}
		ui_draw_text(line.text, &main_font, rect, gui.WHITE)
	}

	ui_end_container()
}
