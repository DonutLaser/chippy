package main

import "core:fmt"
import "core:strings"

assemble :: proc(data: string) -> ([]byte, bool) {
	lines := strings.split(data, "\n")
	for line in lines {
		fmt.println(line)
	}

	return []byte{}, true
}
