package emulator

import "core:fmt"
import "core:math/rand"

INSTRUCTIONS_PER_STEP :: 10

emulate :: proc(program: []u8) {
	// cpu := cpu_new()
	// ram := ram_new()
	// display, ok := display_new(5)
	// if !ok {
	// 	return
	// }

	// ram_copy_into(&ram, program, 0x200)

	// for true {
	// 	input_consume_events()
	// 	if input_was_quit_requested() {
	// 		break
	// 	}

	// 	if cpu.DT > 0 {cpu.DT -= 1}
	// 	if cpu.ST > 0 {cpu.ST -= 1}

	// 	instructions_executed := 0


	// 	display_render(&display)
	// }

	// display_kill(&display)
}
