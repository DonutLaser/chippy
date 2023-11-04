package gui

WHITE :: Color{255, 255, 255, 255}
BLACK :: Color{0, 0, 0, 255}
RED :: Color{255, 0, 0, 255}
GREEN :: Color{0, 255, 0, 255}
BLUE :: Color{0, 0, 255, 255}

Color :: struct {
	r, g, b, a: u8,
}
