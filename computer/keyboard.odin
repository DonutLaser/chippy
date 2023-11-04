package computer

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

@(private)
Keyboard :: struct {
	last_key_pressed: Key,
	keys:             [16]u8, // @wasted_memory
}

@(private)
keyboard_new :: proc() -> Keyboard {
	return Keyboard{last_key_pressed = ._NONE, keys = [16]u8{}}
}

@(private)
keyboard_set_key_pressed :: proc(keyboard: ^Keyboard, key: Key, pressed: bool) {
	keyboard.keys[key] = pressed ? 1 : 0
	if pressed {keyboard.last_key_pressed = key}
}

@(private)
keyboard_is_key_pressed :: proc(keyboard: ^Keyboard, key: Key) -> bool {
	value := keyboard.keys[key]
	return value == 1
}
