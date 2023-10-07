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
		font_bytes_italic: $embed_file('./fonts/MapleMono/MapleMono-Italic.ttf').to_bytes()
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
	context &gg.Context  = unsafe { nil }
	root    &lenaui.View = unsafe { nil }
}

fn (mut lena Lena) init(_ voidptr) {
	file_contents := os.read_file(@VMODROOT + '/src/main.v') or { panic('failed to read file') }
	file_contents_2 := os.read_file(@VMODROOT + '/v.mod') or { panic('failed to read file') }
	tab_view_width := lena.context.width
	tab_view_height := lena.context.height
	lena.root = &lenaui.TabView{
		context: lena.context
		width: tab_view_width
		height: tab_view_height
		tabs: [
			&lenaui.Tab{
				short_name: 'main.v'
				full_name: os.abs_path(@VMODROOT + '/src/main.v')
				view: &lenaui.View(&lenaui.StandardView{
					context: lena.context
					width: tab_view_width
					height: tab_view_height
					children: [
						lenaui.TextArea.new(
							context: lena.context
							width: tab_view_width
							height: tab_view_height
							text: file_contents
							cursor: lenaui.LineCursor.new()
						),
					]
				})
			},
			&lenaui.Tab{
				short_name: 'v.mod'
				full_name: os.abs_path(@VMODROOT + '/v.mod')
				view: &lenaui.View(&lenaui.StandardView{
					context: lena.context
					width: tab_view_width
					height: tab_view_height
					children: [
						lenaui.TextArea.new(
							context: lena.context
							width: tab_view_width
							height: tab_view_height
							text: file_contents_2
							cursor: lenaui.LineCursor.new()
						),
					]
				})
			},
		]
	}
	mut root_view := unsafe { &lenaui.Component(lena.root as lenaui.TabView) }
	root_view.establish_parent()
}

fn (mut lena Lena) event(event &gg.Event, _ voidptr) {
	lena.root.event(event)
}

// frame does the drawing for the entire window.
fn (mut lena Lena) frame(_ voidptr) {
	lena.context.begin()
	{ // update
		lena.root.update()
	}
	{ // draw
		lena.context.draw_rect_filled(0, 0, lena.context.width, lena.context.height, default_bg_color)
		lena.root.draw()
	}
	lena.context.end()
}
