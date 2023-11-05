package gui

init :: proc(window_width: u16, window_height: u16, window_title: cstring) -> bool {
	ok := window_init(window_width, window_height, window_title)
	if !ok {return false}
	ok = renderer_init(window_instance())
	if !ok {return false}

	return true
}

kill :: proc() {
	renderer_kill()
	window_kill()
}

draw_background :: proc(color: Color) {
	renderer_set_background_color(color)
}

draw_rect :: proc(rect: Rect, color: Color) {
	renderer_draw_rect(rect, color)
}

draw_text :: proc(text: cstring, font: ^Font, rect: Rect, color: Color) {
	renderer_draw_text(text, font, rect, color)
}

draw :: proc() {
	renderer_draw()
}
