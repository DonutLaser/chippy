package main

import "core:fmt"
import "core:os"
import "core:path/filepath"

import "assembler"
import "debugger"
import "disassembler"
import "emulator"

Subcommand :: enum {
	BUILD,
	RUN,
	DEBUG,
}

Args :: struct {
	subcommand: Subcommand,
	filename:   string,
}

read_file :: proc(filename: string) -> ([]u8, bool) {
	data, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.eprintf("ERROR: cannot read file: %s\n", filename)
		return []u8{}, false
	}

	return data, true
}

parse_args :: proc() -> (Args, bool) {
	result := Args{}

	args := os.args[1:]

	if len(args) == 0 {
		fmt.eprintf("ERROR: not enough parameters supplied\n")
		return Args{}, false
	}

	for arg in args {
		if arg == "debug" {
			result.subcommand = .DEBUG
		} else if arg == "build" {
			result.subcommand = .BUILD
		} else if arg == "run" {
			result.subcommand = .RUN
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

	data, file_ok := read_file(args.filename)
	if !file_ok {return}

	filename := filepath.stem(args.filename)

	switch args.subcommand {
	case .BUILD:
		assembler.assemble(string(data), filename)
	case .RUN:
		emulator.emulate(data)
	case .DEBUG:
		debugger.debug(data)
	}
}
