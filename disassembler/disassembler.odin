package disassembler

import "core:fmt"

disassemble :: proc(data: []byte) {
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
				fmt.printf("0x%x    %2x %2x    CLS\n", start, data[index - 1], data[index])
			} else if full_instruction == 0x00EE {
				fmt.printf("0x%x    %2x %2x    RET\n", start, data[index - 1], data[index])
			} else {
				fmt.printf("0x%x    %2x %2x    SYS   %x\n", start, data[index - 1], data[index], address)
			}
		case 1:
			fmt.printf("0x%x    %2x %2x    JP    %x\n", start, data[index - 1], data[index], address)
		case 2:
			fmt.printf("0x%x    %2x %2x    CALL  %x\n", start, data[index - 1], data[index], address)
		case 3:
			fmt.printf("0x%x    %2x %2x    SE    V%x, %x\n", start, data[index - 1], data[index], x, kk)
		case 4:
			fmt.printf("0x%x    %2x %2x    SNE   V%x, %x\n", start, data[index - 1], data[index], x, kk)
		case 5:
			fmt.printf("0x%x    %2x %2x    SE    V%x, V%x\n", start, data[index - 1], data[index], x, y)
		case 6:
			fmt.printf("0x%x    %2x %2x    LD    V%x, %x\n", start, data[index - 1], data[index], x, kk)
		case 7:
			fmt.printf("0x%x    %2x %2x    ADD   V%x, %x\n", start, data[index - 1], data[index], x, kk)
		case 8:
			switch nibble {
			case 0:
				fmt.printf("0x%x    %2x %2x    LD    V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 1:
				fmt.printf("0x%x    %2x %2x    OR    V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 2:
				fmt.printf("0x%x    %2x %2x    AND   V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 3:
				fmt.printf("0x%x    %2x %2x    XOR   V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 4:
				fmt.printf("0x%x    %2x %2x    ADD   V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 5:
				fmt.printf("0x%x    %2x %2x    SUB   V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 6:
				fmt.printf("0x%x    %2x %2x    SHR   V%x\n", start, data[index - 1], data[index], x)
			case 7:
				fmt.printf("0x%x    %2x %2x    SUBN  V%x, V%x\n", start, data[index - 1], data[index], x, y)
			case 0xE:
				fmt.printf("0x%x    %2x %2x    SHL   V%x\n", start, data[index - 1], data[index], x)
			}
		case 9:
			fmt.printf("0x%x    %2x %2x    SNE   V%x, V%x\n", start, data[index - 1], data[index], x, y)
		case 0xA:
			fmt.printf("0x%x    %2x %2x    LD    I, %x\n", start, data[index - 1], data[index], address)
		case 0xB:
			fmt.printf("0x%x    %2x %2x    JP    V0, %x\n", start, data[index - 1], data[index], address)
		case 0xC:
			fmt.printf("0x%x    %2x %2x    RND   V%x, %x\n", start, data[index - 1], data[index], x, kk)
		case 0xD:
			fmt.printf("0x%x    %2x %2x    DRW   V%x, V%x, %x\n", start, data[index - 1], data[index], x, y, nibble)
		case 0xE:
			switch kk {
			case 0x9E:
				fmt.printf("0x%x    %2x %2x    SKP   V%x\n", start, data[index - 1], data[index], x)
			case 0xA1:
				fmt.printf("0x%x    %2x %2x    SKNP  V%x\n", start, data[index - 1], data[index], x)
			case:
				fmt.printf("0x%x    %2x %2x    UNKN\n", start, data[index - 1], data[index])
			}
		case 0xF:
			switch kk {
			case 0x07:
				fmt.printf("0x%x    %2x %2x    LD    V%x, DT\n", start, data[index - 1], data[index], x)
			case 0x0A:
				fmt.printf("0x%x    %2x %2x    LD    V%x, K\n", start, data[index - 1], data[index], x)
			case 0x15:
				fmt.printf("0x%x    %2x %2x    LD    DT, V%x\n", start, data[index - 1], data[index], x)
			case 0x18:
				fmt.printf("0x%x    %2x %2x    LD    ST, V%x\n", start, data[index - 1], data[index], x)
			case 0x1E:
				fmt.printf("0x%x    %2x %2x    ADD   I, V%x\n", start, data[index - 1], data[index], x)
			case 0x29:
				fmt.printf("0x%x    %2x %2x    LD    F, V%x\n", start, data[index - 1], data[index], x)
			case 0x33:
				fmt.printf("0x%x    %2x %2x    LD    B, V%x\n", start, data[index - 1], data[index], x)
			case 0x55:
				fmt.printf("0x%x    %2x %2x    LD    [I], V%x\n", start, data[index - 1], data[index], x)
			case 0x65:
				fmt.printf("0x%x    %2x %2x    LD    V%x, [I]\n", start, data[index - 1], data[index], x)
			case:
				fmt.printf("0x%x    %2x %2x    UNKN\n", start, data[index - 1], data[index])
			}
		case:
			fmt.printf("0x%x    %2x %2x    UNKN\n", start, data[index - 1], data[index])
		}

		start += 2
		index += 2
	}
}
