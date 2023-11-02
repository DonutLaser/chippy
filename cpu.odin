package main

CPU :: struct {
	GPR:   [16]u8, // general purpose registers
	I:     u16, // address register
	DT:    u8, // delay timer
	ST:    u8, // sound timer
	PC:    u16, // program counter
	SP:    u8, // stack pointer
	stack: [16]u16,
}

cpu_new :: proc() -> CPU {
	return CPU{PC = 0x200}
}
