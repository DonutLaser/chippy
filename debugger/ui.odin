package debugger

CONTAINER_TITLE_HEIGHT :: 24
CONTAINER_BORDER :: 1
PADDING :: 5

import "../gui"

@(private = "file")
state: UI_State

UI_State :: struct {
	stack:         [4]gui.Rect,
	stack_pointer: u8,
}

ui_init :: proc(window_width: u16, window_height: u16) {
	state = UI_State {
		stack = [4]gui.Rect{},
		stack_pointer = 0,
	}

	ui_reset(window_width, window_height)
}

ui_reset :: proc(window_width: u16, window_height: u16) {
	state.stack_pointer = 0
	state.stack[state.stack_pointer] = gui.Rect {
		x = PADDING,
		y = PADDING,
		w = i32(window_width) - PADDING * 2,
		h = i32(window_height) - PADDING * 2,
	}

	gui.draw_background(gui.Color{60, 60, 60, 255}) // @magic_number
}

ui_begin_toolbar_horizontal :: proc(height: u16, bg_color: gui.Color) {
	parent_rect := state.stack[state.stack_pointer]

	// Draw toolbar
	toolbar_rect := gui.Rect {
		x = parent_rect.x,
		y = parent_rect.y,
		w = parent_rect.w,
		h = i32(height),
	}
	gui.draw_rect(toolbar_rect, bg_color)

	state.stack[state.stack_pointer].y += toolbar_rect.h + PADDING
	state.stack[state.stack_pointer].h -= toolbar_rect.h + PADDING

	state.stack_pointer += 1
	state.stack[state.stack_pointer] = toolbar_rect

	gui.clip_rect(toolbar_rect)
}

ui_end_toolbar_horizontal :: proc() {
	state.stack_pointer -= 1
	gui.clip_rect(gui.Rect{0, 0, 0, 0})
}

ui_begin_container_horizontal :: proc(height: u16, title: cstring, bg_color: gui.Color) {
	parent_rect := state.stack[state.stack_pointer]

	// Draw container box
	container_color := gui.Color{125, 125, 125, 255} // @magic_number	
	container_rect := gui.Rect {
		x = parent_rect.x,
		y = parent_rect.y,
		w = parent_rect.w,
		h = i32(height) + CONTAINER_BORDER * 2 + CONTAINER_TITLE_HEIGHT,
	}
	gui.draw_rect(container_rect, container_color)

	// Draw container title
	title_font := assets_get_font(16)
	title_width, title_height := gui.measure_text(&title_font, title)
	title_rect := gui.Rect {
		x = container_rect.x + PADDING,
		y = container_rect.y + CONTAINER_TITLE_HEIGHT / 2 - i32(title_height) / 2,
		w = i32(title_width),
		h = i32(title_height),
	}
	gui.draw_text(title, &title_font, title_rect, gui.BLACK)

	// Draw container body
	body_rect := gui.Rect {
		x = container_rect.x + CONTAINER_BORDER,
		y = container_rect.y + CONTAINER_TITLE_HEIGHT + CONTAINER_BORDER,
		w = container_rect.w - CONTAINER_BORDER * 2,
		h = i32(height),
	}
	gui.draw_rect(body_rect, bg_color)

	state.stack[state.stack_pointer].y += container_rect.h + PADDING
	state.stack[state.stack_pointer].h -= container_rect.h + PADDING

	state.stack_pointer += 1
	state.stack[state.stack_pointer] = body_rect

	gui.clip_rect(body_rect)
}

ui_end_container_horizontal :: proc() {
	state.stack_pointer -= 1
	gui.clip_rect(gui.Rect{0, 0, 0, 0})
}

ui_begin_container_vertical :: proc(width: u16, title: cstring, bg_color: gui.Color) {
	parent_rect := state.stack[state.stack_pointer]

	// Draw container box
	container_color := gui.Color{125, 125, 125, 255} // @magic_number
	container_rect := gui.Rect {
		x = parent_rect.x,
		y = parent_rect.y,
		w = i32(width) + CONTAINER_BORDER * 2,
		h = parent_rect.h,
	}
	gui.draw_rect(container_rect, container_color)

	// Draw container title
	title_font := assets_get_font(16)
	title_width, title_height := gui.measure_text(&title_font, title)
	title_rect := gui.Rect {
		x = container_rect.x + PADDING,
		y = container_rect.y + CONTAINER_TITLE_HEIGHT / 2 - i32(title_height) / 2,
		w = i32(title_width),
		h = i32(title_height),
	}
	gui.draw_text(title, &title_font, title_rect, gui.BLACK)

	// Draw container body
	body_rect := gui.Rect {
		x = container_rect.x + CONTAINER_BORDER,
		y = container_rect.y + CONTAINER_TITLE_HEIGHT + CONTAINER_BORDER,
		w = i32(width),
		h = container_rect.h - CONTAINER_BORDER * 2 - CONTAINER_TITLE_HEIGHT,
	}
	gui.draw_rect(body_rect, bg_color)

	state.stack[state.stack_pointer].x += container_rect.w + PADDING
	state.stack[state.stack_pointer].w -= container_rect.w + PADDING

	state.stack_pointer += 1
	state.stack[state.stack_pointer] = body_rect

	gui.clip_rect(body_rect)
}

ui_end_container_vertical :: proc() {
	state.stack_pointer -= 1
	gui.clip_rect(gui.Rect{0, 0, 0, 0})
}

ui_begin_group_horizontal :: proc(height: u16) {
	parent_rect := state.stack[state.stack_pointer]

	group_rect := gui.Rect {
		x = parent_rect.x,
		y = parent_rect.y,
		w = parent_rect.w,
		h = i32(height) + CONTAINER_BORDER * 2,
	}

	state.stack[state.stack_pointer].y += group_rect.h + PADDING
	state.stack[state.stack_pointer].h -= group_rect.h + PADDING

	state.stack_pointer += 1
	state.stack[state.stack_pointer] = group_rect
}

ui_end_group_horizontal :: proc() {
	state.stack_pointer -= 1
}

ui_begin_group_vertical :: proc(width: u16) {
	parent_rect := state.stack[state.stack_pointer]

	group_rect := gui.Rect {
		x = parent_rect.x,
		y = parent_rect.y,
		w = i32(width) + CONTAINER_BORDER * 2,
		h = parent_rect.h,
	}

	state.stack[state.stack_pointer].x += group_rect.w + PADDING
	state.stack[state.stack_pointer].w -= group_rect.w + PADDING

	state.stack_pointer += 1
	state.stack[state.stack_pointer] = group_rect
}

ui_end_group_vertical :: proc() {
	state.stack_pointer -= 1
}

ui_draw_rect :: proc(rect: gui.Rect, color: gui.Color) {
	parent_rect := state.stack[state.stack_pointer]

	actual_rect := rect
	actual_rect.x += parent_rect.x
	actual_rect.y += parent_rect.y

	gui.draw_rect(actual_rect, color)
}

ui_draw_text :: proc(text: cstring, font: ^gui.Font, rect: gui.Rect, color: gui.Color) {
	parent_rect := state.stack[state.stack_pointer]

	actual_rect := rect
	actual_rect.x += parent_rect.x
	actual_rect.y += parent_rect.y

	gui.draw_text(text, font, actual_rect, color)
}
