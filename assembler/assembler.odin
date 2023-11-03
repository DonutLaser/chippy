package assembler

import "core:fmt"
import "core:os"
import "core:strings"

assemble :: proc(data: string, dest_name: string) {
	instructions := parse(data)
	defer delete(instructions)

	bytes, ok := generate(instructions)
	if !ok {
		return
	}

	output_path := fmt.aprintf("%s.ch8", dest_name)
	defer delete(output_path)

	ok = os.write_entire_file(output_path, bytes)
	if !ok {
		fmt.eprintf("Error: cannot write file program.ch8")
		return
	}
}
