class_name ClockView
extends Control
## Jam analog ringkas untuk soalan masa. Jarum pendek = jam, jarum panjang
## = minit. Lukisan dibuat dengan kod supaya sepadan dengan palet projek.

var hour: int = 3
var minute: int = 30
var _font: Font = load("res://assets/fonts/AlteHaasGroteskBold.ttf")


func _init(p_hour: int = 3, p_minute: int = 30,
		p_size: float = 320.0) -> void:
	hour = p_hour
	minute = p_minute
	custom_minimum_size = Vector2(p_size, p_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_time(p_hour: int, p_minute: int) -> void:
	hour = p_hour
	minute = p_minute
	queue_redraw()


func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size * 0.5
	var r := s * 0.46

	# Bayang dan badan jam.
	draw_circle(c + Vector2(0, s * 0.02), r, Color(0.34, 0.26, 0.40, 0.16))
	draw_circle(c, r, UI.WHITE)
	draw_arc(c, r, 0.0, TAU, 72, UI.PURPLE_DK, s * 0.045, true)
	draw_arc(c, r * 0.86, 0.0, TAU, 72, UI.PINK, s * 0.014, true)

	# Penanda minit.
	for i in 60:
		var angle := deg_to_rad(float(i) * 6.0 - 90.0)
		var major := i % 5 == 0
		var inner := r * (0.74 if major else 0.79)
		var outer := r * 0.84
		var width := s * (0.012 if major else 0.005)
		draw_line(c + Vector2(cos(angle), sin(angle)) * inner,
			c + Vector2(cos(angle), sin(angle)) * outer,
			UI.PURPLE_DK if major else Color("c8b3dd"), width, true)

	# Angka 12, 3, 6, 9.
	var font_size := int(s * 0.105)
	for item in [[12, 0], [3, 90], [6, 180], [9, 270]]:
		var angle := deg_to_rad(float(item[1]) - 90.0)
		var pos := c + Vector2(cos(angle), sin(angle)) * (r * 0.60)
		var text := str(item[0])
		var text_size := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		draw_string(_font, pos + Vector2(-text_size.x * 0.5, text_size.y * 0.34),
			text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, UI.TXT_SOFT)

	# Jarum jam (pendek) dan minit (panjang).
	var hour_angle := deg_to_rad((float(hour % 12) + float(minute) / 60.0) * 30.0 - 90.0)
	var minute_angle := deg_to_rad(float(minute) * 6.0 - 90.0)
	_draw_hand(c, hour_angle, r * 0.48, s * 0.045, UI.PINK_DK)
	_draw_hand(c, minute_angle, r * 0.68, s * 0.032, UI.ORANGE_DK)

	# Pusat jam.
	draw_circle(c, s * 0.038, UI.PURPLE_DK)
	draw_circle(c, s * 0.017, UI.WHITE)


func _draw_hand(center: Vector2, angle: float, length: float, width: float,
		color: Color) -> void:
	var tip := center + Vector2(cos(angle), sin(angle)) * length
	draw_line(center, tip, color, width, true)
	draw_circle(tip, width * 0.5, color)
	draw_circle(center, width * 0.5, color)
