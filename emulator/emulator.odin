package emulator

import "../computer"
import "../gui"

emulate :: proc(program: []u8) {
	com := computer.new()

	ok := gui.init()
	if !ok {return}
	defer gui.kill()

	computer.load_program(&com, program)
	com.display.scale = 5

	for gui.input_consume_events() {
		gui.draw_background(gui.Color{0, 0, 0, 255})

		computer.tick(&com)

		for y: i32 = 0; y < computer.DISPLAY_HEIGHT; y += 1 {
			for x: i32 = 0; x < computer.DISPLAY_WIDTH; x += 1 {
				pixel := com.display.pixels[y * computer.DISPLAY_WIDTH + x]
				if pixel == 1 {
					gui.draw_rect(gui.Rect{x * i32(com.display.scale), y * i32(com.display.scale), i32(com.display.scale), i32(com.display.scale)}, gui.WHITE)
				}
			}
		}

		gui.draw()
	}
}
