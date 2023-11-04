package debugger

import "gui"

debug :: proc(program: []u8) {
	ok := gui.init()
	if !ok {return}
	defer gui.kill()

	for gui.input_consume_events() {
		gui.draw()
	}
}
