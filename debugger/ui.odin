package debugger

CONTAINER_TITLE_HEIGHT :: 24
CONTAINER_BORDER :: 1

import "gui"

@(private = "file")
state: UI_State

UI_State :: struct {
	offset_x, offset_y: i32,
}

ui_begin_container :: proc(rect: gui.Rect, name: cstring) {
	color := gui.Color{60, 60, 60, 255}

	title_rect := gui.Rect{rect.x - CONTAINER_BORDER, rect.y - CONTAINER_TITLE_HEIGHT, rect.w + CONTAINER_BORDER * 2, CONTAINER_TITLE_HEIGHT}
	gui.draw_rect(title_rect, color)

	base_rect := gui.Rect{rect.x - CONTAINER_BORDER, rect.y - CONTAINER_BORDER, rect.w + CONTAINER_BORDER * 2, rect.h + CONTAINER_BORDER * 2}
	gui.draw_rect(base_rect, color)

	gui.draw_rect(rect, gui.BLACK)
}

ui_end_container :: proc() {
	state.offset_x = 0
	state.offset_y = 0
}

ui_draw_rect :: proc(rect: gui.Rect, color: gui.Color) {
	actual_rect := rect
	actual_rect.x += state.offset_x
	actual_rect.y += state.offset_y

	gui.draw_rect(actual_rect, color)
}

ui_draw_text :: proc(text: cstring, font: ^gui.Font, rect: gui.Rect, color: gui.Color) {
	actual_rect := rect
	actual_rect.x += state.offset_x
	actual_rect.y += state.offset_y

	gui.draw_text(text, font, actual_rect, color)
}
