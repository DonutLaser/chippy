package gui

import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

@(private)
print_sdl_error :: proc() {
	err := sdl.GetError()
	fmt.eprintf("Error: %s\n", err)
}

@(private)
print_ttf_error :: proc() {
	err := ttf.GetError()
	fmt.eprintf("Error: %s\n", err)
}
