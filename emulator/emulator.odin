package emulator

SCREEN_SCALE :: 5

import "../computer"
import "../gui"

emulate :: proc(program: []u8) {
	com := computer.new()

	ok := gui.init(computer.DISPLAY_WIDTH * SCREEN_SCALE, computer.DISPLAY_HEIGHT * SCREEN_SCALE, "Chip8")
	if !ok {return}
	defer gui.kill()

	computer.load_program(&com, program)
	com.display.scale = SCREEN_SCALE

	for gui.input_consume_events() {
		computer.set_key_pressed(&com, computer.Key.Key0, gui.input_is_key_pressed(.H))
		computer.set_key_pressed(&com, computer.Key.Key1, gui.input_is_key_pressed(.U))
		computer.set_key_pressed(&com, computer.Key.Key2, gui.input_is_key_pressed(.I))
		computer.set_key_pressed(&com, computer.Key.Key3, gui.input_is_key_pressed(.O))
		computer.set_key_pressed(&com, computer.Key.Key4, gui.input_is_key_pressed(.J))
		computer.set_key_pressed(&com, computer.Key.Key5, gui.input_is_key_pressed(.K))
		computer.set_key_pressed(&com, computer.Key.Key6, gui.input_is_key_pressed(.L))
		computer.set_key_pressed(&com, computer.Key.Key7, gui.input_is_key_pressed(.M))
		computer.set_key_pressed(&com, computer.Key.Key8, gui.input_is_key_pressed(.COMMA))
		computer.set_key_pressed(&com, computer.Key.Key9, gui.input_is_key_pressed(.PERIOD))
		computer.set_key_pressed(&com, computer.Key.KeyA, gui.input_is_key_pressed(.Q))
		computer.set_key_pressed(&com, computer.Key.KeyB, gui.input_is_key_pressed(.W))
		computer.set_key_pressed(&com, computer.Key.KeyC, gui.input_is_key_pressed(.E))
		computer.set_key_pressed(&com, computer.Key.KeyD, gui.input_is_key_pressed(.A))
		computer.set_key_pressed(&com, computer.Key.KeyE, gui.input_is_key_pressed(.S))
		computer.set_key_pressed(&com, computer.Key.KeyF, gui.input_is_key_pressed(.D))

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
