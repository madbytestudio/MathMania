class_name NumberLineView
extends Control
## Garis nombor untuk topik Bundar Nombor. Tunjuk titik tengah dan kedudukan
## nombor yang dikekalkan supaya murid dapat melihat bundaran ke puluh/ratus
## terdekat.

var number: int = 45
var low: int = 40
var high: int = 50
var midpoint: int = 45
var _font: Font = load("res://assets/fonts/AlteHaasGroteskBold.ttf")


func _init(p_number: int = 45, p_low: int = 40, p_high: int = 50,
		p_midpoint: int = 45, p_size: Vector2 = Vector2(880, 180)) -> void:
	number = p_number
	low = p_low
	high = p_high
	midpoint = p_midpoint
	custom_minimum_size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_values(p_number: int, p_low: int, p_high: int, p_midpoint: int) -> void:
	number = p_number
	low = p_low
	high = p_high
	midpoint = p_midpoint
	queue_redraw()


func _map_value(v: int) -> float:
	var start_x := 120.0
	var end_x := size.x - 120.0
	var range := high - low
	if range <= 0:
		return start_x
	return start_x + float(v - low) / float(range) * (end_x - start_x)


func _draw() -> void:
	var line_y := size.y * 0.5
	var start_x := 120.0
	var end_x := size.x - 120.0

	# Garis nombor.
	draw_line(Vector2(start_x, line_y), Vector2(end_x, line_y),
		Color(0.5, 0.5, 0.5, 0.4), 3.0, true)

	# Tandai titik-titik penting: low, midpoint, high.
	var tick_h := 30.0
	for v in [low, midpoint, high]:
		var x := _map_value(v)
		var color := Color(0.35, 0.3, 0.45, 0.8)
		if v == midpoint:
			color = UI.YELLOW
		draw_line(Vector2(x, line_y - tick_h * 0.5), Vector2(x, line_y + tick_h * 0.5),
			color, 3.0, true)

	# Penanda nombor yang dikekarkan.
	var nx := _map_value(number)
	draw_circle(Vector2(nx, line_y), 14.0, Color("f7b8cb"))
	draw_circle(Vector2(nx, line_y), 14.0, Color("c76a89"), false, 3.0)

	# Label.
	var label_size := 30
	var low_text := str(low)
	var low_size := _font.get_string_size(low_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size)
	draw_string(_font, Vector2(_map_value(low) - low_size.x * 0.5, line_y + tick_h + 10),
		low_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, UI.TXT)

	var high_text := str(high)
	var high_size := _font.get_string_size(high_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size)
	draw_string(_font, Vector2(_map_value(high) - high_size.x * 0.5, line_y + tick_h + 10),
		high_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, UI.TXT)

	var num_text := str(number)
	var num_size := _font.get_string_size(num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size)
	draw_string(_font, Vector2(nx - num_size.x * 0.5, line_y - tick_h - 40),
		num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, Color("c76a89"))
