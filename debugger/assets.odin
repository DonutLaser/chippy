package debugger

DEFAULT_FONT :: "./assets/fonts/consola.ttf"

import "../gui"

@(private = "file")
fonts: map[u16]gui.Font

assets_init :: proc() -> bool {
	fonts = make(map[u16]gui.Font)

	sizes_to_load := []u16{16, 28}
	for size in sizes_to_load {
		font, ok := gui.load_font(DEFAULT_FONT, size)
		if !ok {return false}

		fonts[size] = font
	}

	return true
}

assets_get_font :: proc(size: u16) -> gui.Font {
	assert(size in fonts)
	return fonts[size]
}
