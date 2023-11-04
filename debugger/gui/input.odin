package gui

import sdl "vendor:sdl2"

input_consume_events :: proc() -> bool {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			return false
		}
	}

	return true
}
