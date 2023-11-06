package disassembler

import "core:fmt"

disassemble :: proc(data: []byte) -> [dynamic]cstring {
	result := make([dynamic]cstring, 0)

	index := 1
	start := 0x200

	for index < len(data) {
		full_instruction := 0x00FF & u16(data[index - 1]) << 8 | 0x00FF & u16(data[index])
		address := full_instruction & 0x0FFF
		nibble := full_instruction & 0x000F
		x := data[index - 1] & 0x0F
		y := data[index] & 0xF0 >> 4
		kk := data[index]

		msn := (data[index - 1] & 0xF0) >> 4
		switch msn {
		case 0:
			if full_instruction == 0x00E0 {
				append(&result, fmt.caprintf("0x%x  %2x %2x    CLS", start, data[index - 1], data[index]))
			} else if full_instruction == 0x00EE {
				append(&result, fmt.caprintf("0x%x  %2x %2x    RET", start, data[index - 1], data[index]))
			} else {
				append(&result, fmt.caprintf("0x%x  %2x %2x    SYS   %x", start, data[index - 1], data[index], address))
			}
		case 1:
			append(&result, fmt.caprintf("0x%x  %2x %2x    JP    %x", start, data[index - 1], data[index], address))
		case 2:
			append(&result, fmt.caprintf("0x%x  %2x %2x    CALL  %x", start, data[index - 1], data[index], address))
		case 3:
			append(&result, fmt.caprintf("0x%x  %2x %2x    SE    V%x, %x", start, data[index - 1], data[index], x, kk))
		case 4:
			append(&result, fmt.caprintf("0x%x  %2x %2x    SNE   V%x, %x", start, data[index - 1], data[index], x, kk))
		case 5:
			append(&result, fmt.caprintf("0x%x  %2x %2x    SE    V%x, V%x", start, data[index - 1], data[index], x, y))
		case 6:
			append(&result, fmt.caprintf("0x%x  %2x %2x    LD    V%x, %x", start, data[index - 1], data[index], x, kk))
		case 7:
			append(&result, fmt.caprintf("0x%x  %2x %2x    ADD   V%x, %x", start, data[index - 1], data[index], x, kk))
		case 8:
			switch nibble {
			case 0:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    V%x, V%x", start, data[index - 1], data[index], x, y))
			case 1:
				append(&result, fmt.caprintf("0x%x  %2x %2x    OR    V%x, V%x", start, data[index - 1], data[index], x, y))
			case 2:
				append(&result, fmt.caprintf("0x%x  %2x %2x    AND   V%x, V%x", start, data[index - 1], data[index], x, y))
			case 3:
				append(&result, fmt.caprintf("0x%x  %2x %2x    XOR   V%x, V%x", start, data[index - 1], data[index], x, y))
			case 4:
				append(&result, fmt.caprintf("0x%x  %2x %2x    ADD   V%x, V%x", start, data[index - 1], data[index], x, y))
			case 5:
				append(&result, fmt.caprintf("0x%x  %2x %2x    SUB   V%x, V%x", start, data[index - 1], data[index], x, y))
			case 6:
				append(&result, fmt.caprintf("0x%x  %2x %2x    SHR   V%x", start, data[index - 1], data[index], x))
			case 7:
				append(&result, fmt.caprintf("0x%x  %2x %2x    SUBN  V%x, V%x", start, data[index - 1], data[index], x, y))
			case 0xE:
				append(&result, fmt.caprintf("0x%x  %2x %2x    SHL   V%x", start, data[index - 1], data[index], x))
			}
		case 9:
			append(&result, fmt.caprintf("0x%x  %2x %2x    SNE   V%x, V%x", start, data[index - 1], data[index], x, y))
		case 0xA:
			append(&result, fmt.caprintf("0x%x  %2x %2x    LD    I, %x", start, data[index - 1], data[index], address))
		case 0xB:
			append(&result, fmt.caprintf("0x%x  %2x %2x    JP    V0, %x", start, data[index - 1], data[index], address))
		case 0xC:
			append(&result, fmt.caprintf("0x%x  %2x %2x    RND   V%x, %x", start, data[index - 1], data[index], x, kk))
		case 0xD:
			append(&result, fmt.caprintf("0x%x  %2x %2x    DRW   V%x, V%x, %x", start, data[index - 1], data[index], x, y, nibble))
		case 0xE:
			switch kk {
			case 0x9E:
				append(&result, fmt.caprintf("0x%x  %2x %2x    SKP   V%x", start, data[index - 1], data[index], x))
			case 0xA1:
				append(&result, fmt.caprintf("0x%x  %2x %2x    SKNP  V%x", start, data[index - 1], data[index], x))
			case:
				append(&result, fmt.caprintf("0x%x  %2x %2x    UNKN", start, data[index - 1], data[index]))
			}
		case 0xF:
			switch kk {
			case 0x07:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    V%x, DT", start, data[index - 1], data[index], x))
			case 0x0A:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    V%x, K", start, data[index - 1], data[index], x))
			case 0x15:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    DT, V%x", start, data[index - 1], data[index], x))
			case 0x18:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    ST, V%x", start, data[index - 1], data[index], x))
			case 0x1E:
				append(&result, fmt.caprintf("0x%x  %2x %2x    ADD   I, V%x", start, data[index - 1], data[index], x))
			case 0x29:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    F, V%x", start, data[index - 1], data[index], x))
			case 0x33:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    B, V%x", start, data[index - 1], data[index], x))
			case 0x55:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    [I], V%x", start, data[index - 1], data[index], x))
			case 0x65:
				append(&result, fmt.caprintf("0x%x  %2x %2x    LD    V%x, [I]", start, data[index - 1], data[index], x))
			case:
				append(&result, fmt.caprintf("0x%x  %2x %2x    UNKN", start, data[index - 1], data[index]))
			}
		case:
			append(&result, fmt.caprintf("0x%x  %2x %2x    UNKN", start, data[index - 1], data[index]))
		}

		start += 2
		index += 2
	}

	return result
}

free_instructions :: proc(instructions: [dynamic]cstring) {
	for i in instructions {
		delete(i)
	}

	delete(instructions)
}
