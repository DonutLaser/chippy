package emulator

RAM :: struct {
	data: [4096]u8,
}

ram_new :: proc() -> RAM {
	result := RAM{}

	// Inisitalize the memory reserved for interpreter from 0x000 to 0x1FF..
	// The memory reserved for interpreter also contains the sprites representing hexadecimal digits, which we do need, but the remaining
	// interpreter memory is not used in the emulation.

	// Sprite "0"
	result.data[0] = 0b11110000
	result.data[1] = 0b10010000
	result.data[2] = 0b10010000
	result.data[3] = 0b10010000
	result.data[4] = 0b11110000

	// Sprite "1"
	result.data[5] = 0b00100000
	result.data[6] = 0b01100000
	result.data[7] = 0b00100000
	result.data[8] = 0b00100000
	result.data[9] = 0b01110000

	// Sprite "2"
	result.data[10] = 0b11110000
	result.data[11] = 0b00010000
	result.data[12] = 0b11110000
	result.data[13] = 0b10000000
	result.data[14] = 0b11110000

	// Sprite "3"
	result.data[15] = 0b11110000
	result.data[16] = 0b00010000
	result.data[17] = 0b11110000
	result.data[18] = 0b00010000
	result.data[19] = 0b11110000

	// Sprite "4"
	result.data[20] = 0b10010000
	result.data[21] = 0b10010000
	result.data[22] = 0b11110000
	result.data[23] = 0b00010000
	result.data[24] = 0b00010000

	// Sprite "5"
	result.data[25] = 0b11110000
	result.data[26] = 0b10000000
	result.data[27] = 0b11110000
	result.data[28] = 0b00010000
	result.data[29] = 0b11110000

	// Sprite "6"
	result.data[30] = 0b11110000
	result.data[31] = 0b10000000
	result.data[32] = 0b11110000
	result.data[33] = 0b10010000
	result.data[34] = 0b11110000

	// Sprite "7"
	result.data[35] = 0b11110000
	result.data[36] = 0b00010000
	result.data[37] = 0b00100000
	result.data[38] = 0b01000000
	result.data[39] = 0b01000000

	// Sprite "8"
	result.data[40] = 0b11110000
	result.data[41] = 0b10010000
	result.data[42] = 0b11110000
	result.data[43] = 0b10010000
	result.data[44] = 0b11110000

	// Sprite "9"
	result.data[45] = 0b11110000
	result.data[46] = 0b10010000
	result.data[47] = 0b11110000
	result.data[48] = 0b00010000
	result.data[49] = 0b11110000

	// Sprite "A"
	result.data[50] = 0b11110000
	result.data[51] = 0b10010000
	result.data[52] = 0b11110000
	result.data[53] = 0b10010000
	result.data[54] = 0b10010000

	// Sprite "B"
	result.data[55] = 0b11100000
	result.data[56] = 0b10010000
	result.data[57] = 0b11100000
	result.data[58] = 0b10010000
	result.data[59] = 0b11100000

	// Sprite "C"
	result.data[60] = 0b11110000
	result.data[61] = 0b10000000
	result.data[62] = 0b10000000
	result.data[63] = 0b10000000
	result.data[64] = 0b11110000

	// Sprite "D"
	result.data[65] = 0b11100000
	result.data[66] = 0b10010000
	result.data[67] = 0b10010000
	result.data[68] = 0b10010000
	result.data[69] = 0b11100000

	// Sprite "E"
	result.data[70] = 0b11110000
	result.data[71] = 0b10000000
	result.data[72] = 0b11110000
	result.data[73] = 0b10000000
	result.data[74] = 0b11110000

	// Sprite "F"
	result.data[75] = 0b11110000
	result.data[76] = 0b10000000
	result.data[77] = 0b11110000
	result.data[78] = 0b10000000
	result.data[79] = 0b10000000

	return result
}

ram_copy_into :: proc(ram: ^RAM, data: []u8, offset: u16) {
	for b, index in data {
		ram.data[u16(index) + offset] = b
	}
}

ram_get_bytes_at :: proc(ram: ^RAM, offset: u16, count: u8) -> []u8 {
	return ram.data[offset:offset + u16(count)]
}
