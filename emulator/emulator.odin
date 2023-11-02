package emulator

import "core:fmt"
import "core:math/rand"

@(private = "file")
Instruction :: struct {
	full:    u16,
	address: u16,
	nibble:  u8,
	x:       u8,
	y:       u8,
	kk:      u8,
}

emulate :: proc(program: []u8) {
	cpu := cpu_new()
	ram := ram_new()
	display, ok := display_new(5)
	if !ok {
		return
	}

	ram_copy_into(&ram, program, 0x200)

	for true {
		input_consume_events()
		if input_was_quit_requested() {
			break
		}

		if cpu.DT > 0 {cpu.DT -= 1}
		if cpu.ST > 0 {cpu.ST -= 1}

		instruction_bytes := ram_get_bytes_at(&ram, cpu.PC, 2)
		instruction := get_instruction(instruction_bytes[0], instruction_bytes[1])

		msn := (instruction_bytes[0] & 0xF0) >> 4 // Most significant nibble
		switch msn {
		case 0:
			if instruction.full == 0x00E0 {
				// CLS
				// Clear the display.
				display_clear(&display)
				cpu.PC += 2
			} else if instruction.full == 0x00EE {
				// RET
				// Return from a subroutine.
				// The interpreter sets the program counter to the address at the top of the stack, then subtracts 1 from the stack pointer.
				cpu.PC = cpu.stack[cpu.SP]
				cpu.SP -= 1
				cpu.PC += 2
			} else {
				// SYS addr
				// Jump to a machine code routine at nnn.
				// This instruction is only used on the old computers on which Chip-8 was originally implemented. It is ignored by modern interpreters.
				cpu.PC += 2
			}
		case 1:
			// JP addr
			// Jump to location nnn.
			// The interpreter sets the program counter to nnn.
			cpu.PC = instruction.address
		case 2:
			// CALL addr
			// Call subroutine at nnn.
			// The interpreter increments the stack pointer, then puts the current PC on the top of the stack. The PC is then set to nnn.
			cpu.SP += 1
			cpu.stack[cpu.SP] = cpu.PC
			cpu.PC = instruction.address
		case 3:
			// SE Vx, byte
			// Skip next instruction if Vx = kk.
			// The interpreter compares register Vx to kk, and if they are equal, increments the program counter by 2.
			if cpu.GPR[instruction.x] == instruction.kk {
				cpu.PC += 4
			} else {
				cpu.PC += 2
			}
		case 4:
			// SNE Vx, byte
			// Skip next instruction if Vx != kk.
			// The interpreter compares register Vx to kk, and if they are not equal, increments the program counter by 2.
			if cpu.GPR[instruction.x] != instruction.kk {
				cpu.PC += 4
			} else {
				cpu.PC += 2
			}
		case 5:
			// SE Vx, Vy
			// Skip next instruction if Vx = Vy.
			// The interpreter compares register Vx to register Vy, and if they are equal, increments the program counter by 2.
			if cpu.GPR[instruction.x] == cpu.GPR[instruction.y] {
				cpu.PC += 4
			} else {
				cpu.PC += 2
			}
		case 6:
			// LD Vx, byte
			// Set Vx = kk.
			// The interpreter puts the value kk into register Vx.
			cpu.GPR[instruction.x] = instruction.kk
			cpu.PC += 2
		case 7:
			// ADD Vx, byte
			// Set Vx = Vx + kk.
			// Adds the value kk to the value of register Vx, then stores the result in Vx.
			cpu.GPR[instruction.x] += instruction.kk
			cpu.PC += 2
		case 8:
			switch instruction.nibble {
			case 0:
				// LD Vx, Vy
				// Set Vx = Vy.
				// Stores the value of register Vy in register Vx.
				cpu.GPR[instruction.x] = cpu.GPR[instruction.y]
				cpu.PC += 2
			case 1:
				// OR Vx, Vy
				// Set Vx = Vx OR Vy.
				// Performs a bitwise OR on the values of Vx and Vy, then stores the result in Vx. A bitwise OR compares the corrseponding bits from two values, and if either bit is 1, then the same bit in the result is also 1. Otherwise, it is 0.
				cpu.GPR[instruction.x] |= cpu.GPR[instruction.y]
				cpu.PC += 2
			case 2:
				// AND Vx, Vy
				// Set Vx = Vx AND Vy.
				// Performs a bitwise AND on the values of Vx and Vy, then stores the result in Vx. A bitwise AND compares the corrseponding bits from two values, and if both bits are 1, then the same bit in the result is also 1. Otherwise, it is 0.
				cpu.GPR[instruction.x] &= cpu.GPR[instruction.y]
				cpu.PC += 2
			case 3:
				// XOR Vx, Vy
				// Set Vx = Vx XOR Vy.
				// Performs a bitwise exclusive OR on the values of Vx and Vy, then stores the result in Vx. An exclusive OR compares the corrseponding bits from two values, and if the bits are not both the same, then the corresponding bit in the result is set to 1. Otherwise, it is 0.
				cpu.GPR[instruction.x] ~= cpu.GPR[instruction.y]
				cpu.PC += 2
			case 4:
				// ADD Vx, Vy
				// Set Vx = Vx + Vy, set VF = carry.
				// The values of Vx and Vy are added together. If the result is greater than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0. Only the lowest 8 bits of the result are kept, and stored in Vx.
				cpu.GPR[0xF] = u16(cpu.GPR[instruction.x]) + u16(cpu.GPR[instruction.y]) > 255 ? 1 : 0
				cpu.GPR[instruction.x] += cpu.GPR[instruction.y]
				cpu.PC += 2
			case 5:
				// SUB Vx, Vy
				// Set Vx = Vx - Vy, set VF = NOT borrow.
				// If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted from Vx, and the results stored in Vx.
				cpu.GPR[0xF] = cpu.GPR[instruction.x] > cpu.GPR[instruction.y] ? 1 : 0
				cpu.GPR[instruction.x] -= cpu.GPR[instruction.y]
				cpu.PC += 2
			case 6:
				// SHR Vx {, Vy}
				// Set Vx = Vx SHR 1.
				// If the least-significant bit of Vx is 1, then VF is set to 1, otherwise 0. Then Vx is divided by 2.
				cpu.GPR[0xF] = cpu.GPR[instruction.x] & 0x1
				cpu.GPR[instruction.x] >>= 1
				cpu.PC += 2
			case 7:
				// SUBN Vx, Vy
				// Set Vx = Vy - Vx, set VF = NOT borrow.
				// If Vy > Vx, then VF is set to 1, otherwise 0. Then Vx is subtracted from Vy, and the results stored in Vx.
				cpu.GPR[0xF] = cpu.GPR[instruction.y] > cpu.GPR[instruction.x] ? 1 : 0
				cpu.GPR[instruction.x] = cpu.GPR[instruction.y] - cpu.GPR[instruction.x]
				cpu.PC += 2
			case 0xE:
				// SHL Vx {, Vy}
				// Set Vx = Vx SHL 1.
				// If the most-significant bit of Vx is 1, then VF is set to 1, otherwise to 0. Then Vx is multiplied by 2.
				cpu.GPR[0xF] = cpu.GPR[instruction.x] >> 7
				cpu.GPR[instruction.x] <<= 1
				cpu.PC += 2
			case:
				fmt.eprintf("Unknown instruction: %x\n", instruction.full)
				cpu.PC += 2
			}
		case 9:
			// SNE Vx, Vy
			// Skip next instruction if Vx != Vy.
			// The values of Vx and Vy are compared, and if they are not equal, the program counter is increased by 2.
			if cpu.GPR[instruction.x] != cpu.GPR[instruction.y] {
				cpu.PC += 4
			} else {
				cpu.PC += 2
			}
		case 0xA:
			// LD I, addr
			// Set I = nnn.
			// The value of register I is set to nnn.
			cpu.I = instruction.address
			cpu.PC += 2
		case 0xB:
			// JP V0, addr
			// Jump to location nnn + V0.
			// The program counter is set to nnn plus the value of V0.
			cpu.PC = instruction.address + u16(cpu.GPR[0])
		case 0xC:
			// RND Vx, byte
			// Set Vx = random byte AND kk.
			// The interpreter generates a random number from 0 to 255, which is then ANDed with the value kk. The results are stored in Vx. See instruction 8xy2 for more information on AND.
			value := u8(rand.uint32() % 256)
			cpu.GPR[instruction.x] = value & instruction.kk
			cpu.PC += 2
		case 0xD:
			// DRW Vx, Vy, nibble
			// Dxyn - DRW Vx, Vy, nibble
			// Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.
			// The interpreter reads n bytes from memory, starting at the address stored in I. These bytes are then displayed as sprites on screen at coordinates (Vx, Vy). Sprites are XORed onto the existing screen. If this causes any pixels to be erased, VF is set to 1, otherwise it is set to 0. If the sprite is positioned so part of it is outside the coordinates of the display, it wraps around to the opposite side of the screen. See instruction 8xy3 for more information on XOR, and section 2.4, Display, for more information on the Chip-8 screen and sprites.
			bytes := ram_get_bytes_at(&ram, cpu.I, instruction.nibble)
			display_draw_sprite(&display, cpu.GPR[instruction.x], cpu.GPR[instruction.y], bytes)
			cpu.PC += 2
		case 0xE:
			switch instruction.kk {
			case 0x9E:
				// SKP Vx
				// Skip next instruction if key with the value of Vx is pressed.
				// Checks the keyboard, and if the key corresponding to the value of Vx is currently in the down position, PC is increased by 2.
				pressed := input_is_key_pressed(Key(cpu.GPR[instruction.x]))
				if pressed {
					cpu.PC += 4
				} else {
					cpu.PC += 2
				}
			case 0xA1:
				// SKNP Vx
				// Skip next instruction if key with the value of Vx is not pressed.
				// Checks the keyboard, and if the key corresponding to the value of Vx is currently in the up position, PC is increased by 2.
				pressed := input_is_key_pressed(Key(cpu.GPR[instruction.x]))
				if pressed {
					cpu.PC += 2
				} else {
					cpu.PC += 4
				}
				cpu.PC += 2
			case:
				fmt.eprintf("Unknown instruction: %x\n", instruction.full)
				cpu.PC += 2
			}
		case 0xF:
			switch instruction.kk {
			case 0x07:
				// LD Vx, DT
				// Set Vx = delay timer value.
				// The value of DT is placed into Vx.
				cpu.GPR[instruction.x] = cpu.DT
				cpu.PC += 2
			case 0x0A:
				// LD Vx, K
				// Wait for a key press, store the value of the key in Vx.
				// All execution stops until a key is pressed, then the value of that key is stored in Vx.
				last_key := input_get_last_key_pressed()
				if last_key != ._NONE {
					cpu.GPR[instruction.x] = u8(last_key)
					cpu.PC += 2
				} else {
					cpu.PC -= 2
				}
			case 0x15:
				// LD DT, Vx
				// Set delay timer = Vx.
				// DT is set equal to the value of Vx.
				cpu.DT = cpu.GPR[instruction.x]
				cpu.PC += 2
			case 0x18:
				// LD ST, Vx
				// Set sound timer = Vx.
				// ST is set equal to the value of Vx.
				cpu.ST = cpu.GPR[instruction.x]
				cpu.PC += 2
			case 0x1E:
				// ADD I, Vx
				// Set I = I + Vx.
				// The values of I and Vx are added, and the results are stored in I.
				cpu.I += u16(cpu.GPR[instruction.x])
				cpu.PC += 2
			case 0x29:
				// LD F, Vx
				// Set I = location of sprite for digit Vx.
				// The value of I is set to the location for the hexadecimal sprite corresponding to the value of Vx. See section 2.4, Display, for more information on the Chip-8 hexadecimal font.
				cpu.I = u16(cpu.GPR[instruction.x]) * 5
				cpu.PC += 2
			case 0x33:
				// LD B, Vx
				// Store BCD representation of Vx in memory locations I, I+1, and I+2.
				// The interpreter takes the decimal value of Vx, and places the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.
				hundreds := cpu.GPR[instruction.x] / 100
				tens := (cpu.GPR[instruction.x] % 100) / 10
				ones := cpu.GPR[instruction.x] % 10

				data := []u8{hundreds, tens, ones}
				ram_copy_into(&ram, data, cpu.I)

				cpu.PC += 2
			case 0x55:
				// LD [I], Vx
				// Store registers V0 through Vx in memory starting at location I.
				// The interpreter copies the values of registers V0 through Vx into memory, starting at the address in I.
				data := make([]u8, instruction.x + 1)
				defer delete(data)
				for i: u8 = 0; i <= instruction.x; i += 1 {
					data[i] = cpu.GPR[i]
				}

				ram_copy_into(&ram, data, cpu.I)

				cpu.PC += 2
			case 0x65:
				// LD Vx, [I]
				// Read registers V0 through Vx from memory starting at location I.
				// The interpreter reads values from memory starting at location I into registers V0 through Vx.
				bytes := ram_get_bytes_at(&ram, cpu.I, instruction.x + 1)
				for i: u8 = 0; i <= instruction.x; i += 1 {
					cpu.GPR[i] = bytes[i]
				}

				cpu.PC += 2
			case:
				fmt.eprintf("Unknown instruction: %x\n", instruction.full)
				cpu.PC += 2
			}
		}

		display_render(&display)
	}

	display_kill(&display)
}

@(private = "file")
get_instruction :: proc(byte1: u8, byte2: u8) -> Instruction {
	full := (0x00FF & u16(byte1)) << 8 | 0x00FF & u16(byte2)
	return Instruction{full = full, address = full & 0x0FFF, nibble = u8(full & 0x000F), x = byte1 & 0x0F, y = byte2 & 0xF0 >> 4, kk = byte2}
}
