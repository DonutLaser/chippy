package assembler

import "core:fmt"
import "core:os"
import "core:strings"

assemble :: proc(data: string) {
	instructions := parse(data)
	defer delete(instructions)

	bytes, ok := generate(instructions)
	if !ok {
		return
	}

	ok = os.write_entire_file("program.ch8", bytes)
	if !ok {
		fmt.eprintf("Error: cannot write file program.ch8")
		return
	}
}
