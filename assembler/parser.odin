package assembler

import "core:strings"

Instruction_Kind :: enum {
	INSTRUCTION,
	LABEL,
}

Instruction :: struct {
	kind:      Instruction_Kind,
	name:      string,
	args:      [3]string,
	arg_count: u8,
	address:   u16,
}

parse :: proc(data: string) -> []Instruction {
	result := make([dynamic]Instruction, 0)

	mem_offset: u16 = 0x200

	lines := strings.split(data, "\n")
	for line in lines {
		trimmed := strings.trim_space(line)
		if len(trimmed) == 0 {
			continue
		}

		if strings.has_prefix(trimmed, "--") {
			// Comment, ignore
			continue
		}

		if strings.has_prefix(trimmed, ":") {
			// Label 
			append(&result, Instruction{kind = .LABEL, name = trimmed[1:], arg_count = 0})
		} else {
			// Command
			parts := strings.split(trimmed, " ")
			instruction := Instruction {
				kind      = .INSTRUCTION,
				name      = parts[0],
				arg_count = 0,
				address   = mem_offset,
			}
			if len(parts) > 1 {
				instruction.arg_count = u8(len(parts) - 1)
				for i := 1; i < len(parts); i += 1 {
					instruction.args[i - 1] = parts[i]
				}
			}

			mem_offset += 2

			append(&result, instruction)
		}
	}

	return result[:]
}
