package debugger

WINDOW_WIDTH :: 934
WINDOW_HEIGHT :: 712
DISPLAY_SCALE :: 9

import "../computer"
import "../disassembler"
import "../gui"

debug :: proc(program: []u8) {
	com := computer.new()

	ok := gui.init(WINDOW_WIDTH, WINDOW_HEIGHT, "Chip8 Debugger")
	if !ok {return}
	defer gui.kill()

	ok = assets_init()
	if !ok {return}

	instructions := disassembler.disassemble(program)
	defer disassembler.free_instructions(instructions)

	instructions_init(instructions)
	defer instructions_kill()

	gprs_init()
	defer gprs_kill()

	other_registers_init()
	defer other_registers_kill()

	timers_init()
	defer timers_kill()

	computer.load_program(&com, program)
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

		computer.tick(&com)

		instructions_set_current_instruction((com.CPU.PC - computer.PROGRAM_OFFSET) / 2)
		gprs_update(com.CPU.GPR)
		other_registers_update(com.CPU.I, u16(com.CPU.SP), com.CPU.PC)
		timers_update(com.CPU.DT, com.CPU.ST)

		gui.draw_background(gui.Color{60, 60, 60, 255})

		display_render(com.display.pixels[:], computer.DISPLAY_WIDTH, computer.DISPLAY_HEIGHT, DISPLAY_SCALE)
		instructions_render()
		gprs_render()
		other_registers_render()
		timers_render()

		gui.draw()
	}
}
