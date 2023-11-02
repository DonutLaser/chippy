package main

import "core:fmt"
import "core:os"

Args :: struct {
	dump_instructions: bool,
	assemble:          bool,
	filename:          string,
}

parse_args :: proc() -> (Args, bool) {
	result := Args{}

	args := os.args[1:]

	if len(args) == 0 {
		fmt.eprintf("ERROR: not enough parameters supplied\n")
		return Args{}, false
	}

	for arg in args {
		if arg == "-d" {
			result.dump_instructions = true
		} else if arg == "-a" {
			result.assemble = true
		} else {
			result.filename = arg
		}
	}

	if result.filename == "" {
		fmt.eprintf("ERROR: filename is required\n")
		return Args{}, false
	}

	return result, true
}

main :: proc() {
	args, args_ok := parse_args()
	if !args_ok {return}

	data, file_ok := os.read_entire_file_from_filename(args.filename)
	if !file_ok {return}

	if args.dump_instructions {
		disassemble(data)
	} else if args.assemble {
		assemble(string(data))
	} else {
		emulate(data)
	}
}
