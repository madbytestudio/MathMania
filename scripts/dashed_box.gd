class_name DashedBox
extends Control
## Kotak putih dengan sempadan putus-putus — digunakan sebagai tempat letak
## jawapan yang belum diisi (gaya sama seperti kit CraftPix).

var line_color: Color = Color("c8a6e2")
var line_width: float = 6.0
var corner_radius: float = 22.0
var dash_length: float = 16.0
var fill_color: Color = Color(1, 1, 1, 0.55)


func _init(p_color: Color = Color("c8a6e2"), p_width: float = 6.0,
		p_fill: Color = Color(1, 1, 1, 0.55)) -> void:
	line_color = p_color
	line_width = p_width
	fill_color = p_fill
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := line_width
	var rect := Rect2(Vector2(w, w) * 0.5, size - Vector2(w, w))
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	if fill_color.a > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), fill_color, true)

	var r := minf(corner_radius, minf(rect.size.x, rect.size.y) * 0.45)
	var left := rect.position.x + r
	var right := rect.end.x - r
	var top := rect.position.y + r
	var bottom := rect.end.y - r

	draw_dashed_line(Vector2(left, rect.position.y), Vector2(right, rect.position.y),
		line_color, w, dash_length, true, true)
	draw_dashed_line(Vector2(left, rect.end.y), Vector2(right, rect.end.y),
		line_color, w, dash_length, true, true)
	draw_dashed_line(Vector2(rect.position.x, top), Vector2(rect.position.x, bottom),
		line_color, w, dash_length, true, true)
	draw_dashed_line(Vector2(rect.end.x, top), Vector2(rect.end.x, bottom),
		line_color, w, dash_length, true, true)

	# Sudut dilukis sebagai lengkok supaya bentuk kekal bulat.
	draw_arc(Vector2(left, top), r, PI, PI * 1.5, 12, line_color, w, true)
	draw_arc(Vector2(right, top), r, PI * 1.5, TAU, 12, line_color, w, true)
	draw_arc(Vector2(right, bottom), r, 0.0, PI * 0.5, 12, line_color, w, true)
	draw_arc(Vector2(left, bottom), r, PI * 0.5, PI, 12, line_color, w, true)
