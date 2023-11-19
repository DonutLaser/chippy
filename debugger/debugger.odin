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
	stack_init()
	defer stack_kill()
	keys_init()
	defer keys_kill()

	ui_init(WINDOW_WIDTH, WINDOW_HEIGHT)

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
		stack_update(com.CPU.stack)
		stack_set_stack_top(com.CPU.SP)
		keys_update(
			[16]bool {
				gui.input_is_key_pressed(.H),
				gui.input_is_key_pressed(.U),
				gui.input_is_key_pressed(.I),
				gui.input_is_key_pressed(.O),
				gui.input_is_key_pressed(.J),
				gui.input_is_key_pressed(.K),
				gui.input_is_key_pressed(.L),
				gui.input_is_key_pressed(.M),
				gui.input_is_key_pressed(.COMMA),
				gui.input_is_key_pressed(.PERIOD),
				gui.input_is_key_pressed(.Q),
				gui.input_is_key_pressed(.W),
				gui.input_is_key_pressed(.E),
				gui.input_is_key_pressed(.A),
				gui.input_is_key_pressed(.S),
				gui.input_is_key_pressed(.D),
			},
		)

		instructions_tick()

		ui_reset(WINDOW_WIDTH, WINDOW_HEIGHT)

		instructions_render()
		display_render(com.display.pixels[:], computer.DISPLAY_WIDTH, computer.DISPLAY_HEIGHT, DISPLAY_SCALE)

		ui_begin_group_vertical(178) // @magic_number
		gprs_render()
		keys_render()
		ui_end_group_vertical()

		ui_begin_group_vertical(178) // @magic_number
		other_registers_render()
		timers_render()
		ui_end_group_vertical()

		ui_begin_group_vertical(105) // @magic_number
		stack_render()
		ui_end_group_vertical()

		gui.draw()
	}
}
