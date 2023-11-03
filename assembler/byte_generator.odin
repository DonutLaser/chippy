package assembler

import "core:bytes"
import "core:fmt"
import "core:strconv"
import "core:strings"

generate :: proc(instructions: []Instruction) -> ([]byte, bool) {
	buffer := bytes.Buffer{}

	// Collect the labels to know where jumps should jump to
	jump_table := make(map[string]u16)
	defer delete(jump_table)

	for i := 0; i < len(instructions); i += 1 {
		if instructions[i].kind == .INSTRUCTION {
			continue
		}

		// @error_handling index out of bounds
		jump_table[instructions[i].name] = instructions[i + 1].address
	}


	// Generate the bytes from the commands
	for instruction in instructions {
		if instruction.kind == .LABEL {
			continue
		}

		ibytes, ok := generate_bytes_from_instruction(instruction, jump_table)
		if !ok {return []byte{}, false}

		bytes.buffer_write(&buffer, ibytes[:])
	}

	return bytes.buffer_to_bytes(&buffer), true
}

@(private = "file")
generate_bytes_from_instruction :: proc(instruction: Instruction, jump_table: map[string]u16) -> ([2]u8, bool) {
	switch instruction.name {
	case "LD":
		return generate_LD_bytes(instruction)
	case "CLS":
		return generate_CLS_bytes(instruction)
	case "DRW":
		return generate_DRW_bytes(instruction)
	case "JP":
		return generate_JP_bytes(instruction, jump_table)
	case:
		fmt.eprintf("Assembly error: unknown instruction: %s\n", instruction.name)
		return [2]u8{}, false
	}
}

@(private = "file")
generate_LD_bytes :: proc(instruction: Instruction) -> ([2]u8, bool) {
	assert(instruction.name == "LD")
	if !expect_arg_count(instruction, 2) {return [2]u8{}, false}

	result := [2]u8{}

	if strings.has_prefix(instruction.args[0], "V") {
		reg1 := get_register_number(instruction.args[0])
		if !expect_valid_register(reg1) {return result, false}

		if strings.has_prefix(instruction.args[1], "V") {
			reg2 := get_register_number(instruction.args[1])
			if !expect_valid_register(reg2) {return result, false}

			// 8xy0
			result[0] = 0x80 | reg1
			result[1] = (reg2 << 4) | 0xF0
		} else if instruction.args[1] == "DT" {
			// Fx07
			result[0] = 0xF0 | reg1
			result[1] = 0x07
		} else if instruction.args[1] == "K" {
			// Fx0A
			result[0] = 0xF0 | reg1
			result[1] = 0x0A
		} else if instruction.args[1] == "I" {
			// Fx65
			result[0] = 0xF0 | reg1
			result[1] = 0x65
		} else {
			b := get_byte(instruction.args[1])
			// @error_handling overflow

			// 6xkk
			result[0] = 0x60 | reg1
			result[1] = b
		}
	} else if instruction.args[0] == "I" {
		if strings.has_prefix(instruction.args[1], "V") {
			reg2 := get_register_number(instruction.args[1])
			if !expect_valid_register(reg2) {return result, false}

			// Fx55
			result[0] = 0xF0 | reg2
			result[1] = 0x55
		} else {
			addr := get_address(instruction.args[1])
			if !expect_valid_address(addr) {return result, false}

			// Annn
			result[0] = 0xA0 | u8((addr & 0xF00) >> 8)
			result[1] = 0x00 | u8(addr & 0x0FF)
		}
	} else if instruction.args[0] == "DT" {
		reg2 := get_register_number(instruction.args[1])
		if !expect_valid_register(reg2) {return result, false}

		// Fx15
		result[0] = 0xF0 | reg2
		result[1] = 0x15
	} else if instruction.args[0] == "ST" {
		reg2 := get_register_number(instruction.args[1])
		if !expect_valid_register(reg2) {return result, false}

		// Fx18
		result[0] = 0xF0 | reg2
		result[1] = 0x18
	} else if instruction.args[0] == "F" {
		reg2 := get_register_number(instruction.args[1])
		if !expect_valid_register(reg2) {return result, false}

		// Fx29
		result[0] = 0xF0 | reg2
		result[1] = 0x29
	} else if instruction.args[0] == "B" {
		reg2 := get_register_number(instruction.args[1])
		if !expect_valid_register(reg2) {return result, false}

		// Fx33
		result[0] = 0xF0 | reg2
		result[1] = 0x33
	}

	return result, true
}

@(private = "file")
generate_CLS_bytes :: proc(instruction: Instruction) -> ([2]u8, bool) {
	assert(instruction.name == "CLS")
	if !expect_arg_count(instruction, 0) {return [2]u8{}, false}

	result := [2]u8{}
	result[0] = 0x00
	result[1] = 0xE0

	return result, true
}

@(private = "file")
generate_DRW_bytes :: proc(instruction: Instruction) -> ([2]u8, bool) {
	assert(instruction.name == "DRW")
	if !expect_arg_count(instruction, 3) {return [2]u8{}, false}

	result := [2]u8{}

	reg1 := get_register_number(instruction.args[0])
	if !expect_valid_register(reg1) {return result, false}
	reg2 := get_register_number(instruction.args[1])
	if !expect_valid_register(reg2) {return result, false}

	b := get_byte(instruction.args[2])
	if !expect_valid_sprite_size(b) {return result, false}

	// Dxyn
	result[0] = 0xD0 | reg1
	result[1] = (0x00 | reg2) << 4 | b

	return result, true
}

@(private = "file")
generate_JP_bytes :: proc(instruction: Instruction, jump_table: map[string]u16) -> ([2]u8, bool) {
	assert(instruction.name == "JP")
	if !expect_arg_count_range(instruction, 1, 2) {return [2]u8{}, false}

	result := [2]u8{}

	if instruction.arg_count == 1 {
		address := jump_table[instruction.args[0]]
		if !expect_valid_address(address) {return [2]u8{}, false}

		// 1nnn
		result[0] = 0x10 | u8((address & 0xF00) >> 8)
		result[1] = 0x00 | u8(address & 0x0FF)
	} else if instruction.arg_count == 2 {
		address := jump_table[instruction.args[1]]
		if !expect_valid_address(address) {return [2]u8{}, false}

		// Bnnn
		result[0] = 0xB0 | u8((address & 0xF00) >> 8)
		result[1] = 0x00 | u8(address & 0x0FF)
	}

	return result, true
}

@(private = "file")
get_register_number :: proc(register: string) -> u8 {
	result := strconv.atoi(register[1:])
	return u8(result)
}

@(private = "file")
get_byte :: proc(arg: string) -> u8 {
	result := strconv.atoi(arg)
	return u8(result)
}

@(private = "file")
get_address :: proc(arg: string) -> u16 {
	result := strconv.atoi(arg)
	return u16(result)
}

@(private = "file")
expect_arg_count :: proc(instruction: Instruction, arg_count: u8) -> bool {
	if instruction.arg_count != arg_count {
		fmt.eprintf("Assembly error: %s instruction requires %d arguments, got %d\n", instruction.name, instruction.arg_count, arg_count)
		return false
	}

	return true
}

@(private = "file")
expect_arg_count_range :: proc(instruction: Instruction, min_arg_count: u8, max_arg_count: u8) -> bool {
	if instruction.arg_count < min_arg_count || instruction.arg_count > max_arg_count {
		fmt.eprintf(
			"Assembly error: %s instruction requires between %d and %d arguments, got %d\n",
			instruction.name,
			min_arg_count,
			max_arg_count,
			instruction.arg_count,
		)
		return false
	}

	return true
}

@(private = "file")
expect_valid_register :: proc(register: u8) -> bool {
	if register == 0xF {
		fmt.eprintf("Assembly error: register VF is not supposed to be used by user.\n")
		return false
	}

	if register > 0xF {
		fmt.eprintf("Assembly error: register V%d is not supported. Only V0 - VE are allowed.\n")
		return false
	}

	return true
}

@(private = "file")
expect_valid_address :: proc(address: u16) -> bool {
	if address > 0xFFF {
		fmt.eprintf("Assembly error: address must be in range 0x000 - 0xFFF.\n")
		return false
	}

	return true
}

@(private = "file")
expect_valid_sprite_size :: proc(size: u8) -> bool {
	if size > 0xF {
		fmt.eprintf("Assembly error: maximum sprite size is 0xF.\n")
		return false
	}

	return true
}
