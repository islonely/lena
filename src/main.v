module main

import gg
import gx
import lenaui
import mouse
import os

const default_bg_color = gx.rgb(0x22, 0x22, 0x22)

const dimensions = [
	[3840, 2160],
	[2560, 1440],
	[1920, 1080],
	[1280, 720],
	[1024, 768],
	[800, 600],
	[640, 480],
]

fn main() {
	mut lena := &Lena{}
	screen_size := mouse.screen_size()
	lena_size := get_one_size_smaller_than(screen_size) or { mouse.Size{400, 300} }
	lena.context = gg.new_context(
		window_title: 'Lena'
		width: lena_size.width
		height: lena_size.height
		user_data: lena
		frame_fn: lena.frame
		init_fn: lena.init
		event_fn: lena.event
		font_bytes_normal: $embed_file('./fonts/MapleMono/MapleMono-Regular.ttf').to_bytes()
		font_bytes_bold: $embed_file('./fonts/MapleMono/MapleMono-Bold.ttf').to_bytes()
	)
	lena.context.run()
}

// get_one_size_smaller_than returns a window size that is smaller than
// the given size. If no such size exists, it returns none.
fn get_one_size_smaller_than(size mouse.Size) ?mouse.Size {
	for dimension in dimensions {
		if dimension[0] < size.width && dimension[1] < size.height {
			return mouse.Size{
				width: dimension[0]
				height: dimension[1]
			}
		}
	}
	return none
}

// Lena is the main application struct.
[heap]
struct Lena {
pub mut:
	context      &gg.Context = unsafe { nil }
	editor_views []&lenaui.TextArea
}

fn (mut lena Lena) init(_ voidptr) {
	file_contents := os.read_file(@VMODROOT + '/src/main.v') or { panic('failed to read file') }
	lena.editor_views << lenaui.TextArea.new(
		width: lena.context.width
		height: lena.context.height
		context: lena.context
		cursor: lenaui.LineCursor.new()
		text: file_contents
	)
}

fn (mut lena Lena) event(event &gg.Event, _ voidptr) {
	lena.editor_views[0].event(event, lena.context.key_modifiers)
}

// frame does the drawing for the entire window.
fn (mut lena Lena) frame(_ voidptr) {
	lena.context.begin()
	{ // update
		lena.editor_views[0].update()
	}
	{ // draw
		lena.context.draw_rect_filled(0, 0, lena.context.width, lena.context.height, default_bg_color)
		lena.editor_views[0].draw()
	}
	lena.context.end()
}
