package assembler

import "core:fmt"
import "core:strings"

assemble :: proc(data: string) {
	lines := strings.split(data, "\n")
	for line in lines {
		fmt.println(line)
	}
}
