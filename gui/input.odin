package gui

import sdl "vendor:sdl2"

@(private = "file")
state: Input

// @incomplete
Key :: enum {
	Q = 0,
	W,
	E,
	A,
	S,
	D,
	U,
	I,
	O,
	J,
	K,
	L,
	M,
	COMMA,
	PERIOD,
	H,
	_COUNT,
}

Input :: struct {
	keys: [Key._COUNT]bool,
}

input_consume_events :: proc() -> bool {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			return false
		case .KEYDOWN, .KEYUP:
			pressed := event.type == .KEYDOWN
			#partial switch event.key.keysym.sym {
			case .Q:
				state.keys[Key.Q] = pressed
			case .W:
				state.keys[Key.W] = pressed
			case .E:
				state.keys[Key.E] = pressed
			case .A:
				state.keys[Key.A] = pressed
			case .S:
				state.keys[Key.S] = pressed
			case .D:
				state.keys[Key.D] = pressed
			case .U:
				state.keys[Key.U] = pressed
			case .I:
				state.keys[Key.I] = pressed
			case .O:
				state.keys[Key.O] = pressed
			case .J:
				state.keys[Key.J] = pressed
			case .K:
				state.keys[Key.K] = pressed
			case .L:
				state.keys[Key.L] = pressed
			case .M:
				state.keys[Key.M] = pressed
			case .COMMA:
				state.keys[Key.COMMA] = pressed
			case .PERIOD:
				state.keys[Key.PERIOD] = pressed
			case .H:
				state.keys[Key.H] = pressed
			}
		}
	}

	return true
}

input_is_key_pressed :: proc(key: Key) -> bool {
	return state.keys[key]
}
