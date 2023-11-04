package gui

import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

@(private = "file")
instance: Renderer

@(private)
Renderer :: struct {
	internal: ^sdl.Renderer,
	queue:    [dynamic]Render_Instruction,
}

@(private)
Render_Instruction_Kind :: enum {
	RECT,
	TEXT,
}

@(private)
Render_Instruction :: struct {
	kind: Render_Instruction_Kind,
	data: union {
		Render_Instruction_Rect,
		Render_Instruction_Text,
	},
}

@(private)
Render_Instruction_Rect :: struct {
	rect:  Rect,
	color: Color,
}

@(private)
Render_Instruction_Text :: struct {
	rect:    Rect,
	texture: ^sdl.Texture,
}

@(private)
renderer_init :: proc(wnd: ^Window) -> bool {
	renderer := sdl.CreateRenderer(wnd.internal, -1, {.ACCELERATED, .PRESENTVSYNC})
	if renderer == nil {
		print_sdl_error()
		return false
	}

	instance = Renderer {
		internal = renderer,
		queue    = make([dynamic]Render_Instruction, 0),
	}

	return true
}

@(private)
renderer_kill :: proc() {
	sdl.DestroyRenderer(instance.internal)
}

@(private)
renderer_draw_rect :: proc(rect: Rect, color: Color) {
	append(&instance.queue, Render_Instruction{kind = .RECT, data = Render_Instruction_Rect{rect = rect, color = color}})
}

@(private)
renderer_draw_text :: proc(text: cstring, font: ^Font, rect: Rect, color: Color) {
	surface := ttf.RenderUTF8_Blended(font.instance, text, sdl.Color{color.r, color.g, color.b, color.a})
	defer sdl.FreeSurface(surface)

	texture := sdl.CreateTextureFromSurface(instance.internal, surface)

	append(&instance.queue, Render_Instruction{kind = .TEXT, data = Render_Instruction_Text{rect = rect, texture = texture}})
}

@(private)
renderer_draw :: proc() {
	sdl.SetRenderDrawColor(instance.internal, 0, 0, 0, 255)
	sdl.RenderClear(instance.internal)

	for ins in instance.queue {
		switch ins.kind {
		case .RECT:
			draw_rect(ins.data.(Render_Instruction_Rect))
		case .TEXT:
			draw_text(ins.data.(Render_Instruction_Text))
		}
	}

	sdl.RenderPresent(instance.internal)
	clear_dynamic_array(&instance.queue)
}

@(private = "file")
draw_rect :: proc(instruction: Render_Instruction_Rect) {
	sdl.SetRenderDrawBlendMode(instance.internal, sdl.BlendMode.BLEND)
	sdl.SetRenderDrawColor(instance.internal, instruction.color.r, instruction.color.g, instruction.color.b, instruction.color.a)

	rect := rect_to_sdl_rect(instruction.rect)
	sdl.RenderFillRect(instance.internal, &rect)
}

@(private = "file")
draw_text :: proc(instruction: Render_Instruction_Text) {
	rect := rect_to_sdl_rect(instruction.rect)
	sdl.RenderCopy(instance.internal, instruction.texture, nil, &rect)

	sdl.DestroyTexture(instruction.texture)
}
