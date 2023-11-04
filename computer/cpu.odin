package computer

@(private)
CPU :: struct {
	GPR:   [16]u8, // general purpose registers
	I:     u16, // address register
	DT:    u8, // delay timer
	ST:    u8, // sound timer
	PC:    u16, // program counter
	SP:    u8, // stack pointer
	stack: [16]u16,
}

@(private)
cpu_new :: proc() -> CPU {
	return CPU{PC = 0x200}
}

cpu_goto_next_instruction :: proc(cpu: ^CPU) {
	cpu.PC += 2
}

cpu_skip_next_instruction :: proc(cpu: ^CPU) {
	cpu.PC += 4
}

cpu_repeat_instruction :: proc(cpu: ^CPU) {
	cpu.PC -= 2
}
