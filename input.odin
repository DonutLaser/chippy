package main

import sdl "vendor:sdl2"

Key :: enum {
	Key0 = 0,
	Key1,
	Key2,
	Key3,
	Key4,
	Key5,
	Key6,
	Key7,
	Key8,
	Key9,
	KeyA,
	KeyB,
	KeyC,
	KeyD,
	KeyE,
	KeyF,
	_NONE,
}

@(private = "file")
instance: Input

Input :: struct {
	quit:             bool,
	last_key_pressed: Key,
	keys:             [16]u8, // @wasted_memory
}

input_init :: proc() {
	instance = Input {
		quit = false,
		keys = [16]u8{},
	}
}

input_consume_events :: proc() {
	instance.last_key_pressed = ._NONE

	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			instance.quit = true
		case .KEYDOWN, .KEYUP:
			state: u8 = event.type == .KEYDOWN ? 1 : 0
			#partial switch event.key.keysym.sym {
			case .U:
				instance.keys[Key.Key1] = state
				if state == 1 {instance.last_key_pressed = Key.Key1}
			case .I:
				instance.keys[Key.Key2] = state
				if state == 1 {instance.last_key_pressed = Key.Key2}
			case .O:
				instance.keys[Key.Key3] = state
				if state == 1 {instance.last_key_pressed = Key.Key3}
			case .J:
				instance.keys[Key.Key4] = state
				if state == 1 {instance.last_key_pressed = Key.Key4}
			case .K:
				instance.keys[Key.Key5] = state
				if state == 1 {instance.last_key_pressed = Key.Key5}
			case .L:
				instance.keys[Key.Key6] = state
				if state == 1 {instance.last_key_pressed = Key.Key6}
			case .M:
				instance.keys[Key.Key7] = state
				if state == 1 {instance.last_key_pressed = Key.Key7}
			case .LESS:
				instance.keys[Key.Key8] = state
				if state == 1 {instance.last_key_pressed = Key.Key8}
			case .GREATER:
				instance.keys[Key.Key9] = state
				if state == 1 {instance.last_key_pressed = Key.Key9}
			case .H:
				instance.keys[Key.Key0] = state
				if state == 1 {instance.last_key_pressed = Key.Key0}
			case .Q:
				instance.keys[Key.KeyA] = state
				if state == 1 {instance.last_key_pressed = Key.KeyA}
			case .W:
				instance.keys[Key.KeyB] = state
				if state == 1 {instance.last_key_pressed = Key.KeyB}
			case .E:
				instance.keys[Key.KeyC] = state
				if state == 1 {instance.last_key_pressed = Key.KeyC}
			case .A:
				instance.keys[Key.KeyD] = state
				if state == 1 {instance.last_key_pressed = Key.KeyD}
			case .S:
				instance.keys[Key.KeyE] = state
				if state == 1 {instance.last_key_pressed = Key.KeyE}
			case .D:
				instance.keys[Key.KeyF] = state
				if state == 1 {instance.last_key_pressed = Key.KeyF}
			}
		}
	}
}

input_was_quit_requested :: proc() -> bool {
	return instance.quit
}

input_is_key_pressed :: proc(key: Key) -> bool {
	return instance.keys[key] == 1
}

input_get_last_key_pressed :: proc() -> Key {
	return instance.last_key_pressed
}
