class_name FractionView
extends Control
## Bar pecahan: keseluruhan dibahagi kepada beberapa bahagian sama besar,
## bahagian berwarna menunjukkan pengangka.

var numerator: int = 1
var denominator: int = 2
var tint: Color = UI.PINK


func _init(p_denominator: int = 2, p_numerator: int = 1,
		p_size: Vector2 = Vector2(760, 210)) -> void:
	numerator = p_numerator
	denominator = p_denominator
	custom_minimum_size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_fraction(p_numerator: int, p_denominator: int) -> void:
	numerator = p_numerator
	denominator = maxi(1, p_denominator)
	queue_redraw()


func _draw() -> void:
	var den := maxi(denominator, 1)
	var num := clampi(numerator, 0, den)
	var outer := Rect2(Vector2.ZERO, size)
	draw_style_box(UI.style_box(UI.WHITE, 30, 7, Color("c3a9de"), true), outer)

	var inner := outer.grow(-12)
	var slice_width := inner.size.x / float(den)
	var radius := 20.0

	# Bahagian berwarna (dari kiri).
	if num > 0:
		var shade := StyleBoxFlat.new()
		shade.bg_color = tint
		shade.anti_aliasing = true
		shade.corner_radius_top_left = int(radius)
		shade.corner_radius_bottom_left = int(radius)
		shade.corner_radius_top_right = int(radius) if num == den else 0
		shade.corner_radius_bottom_right = int(radius) if num == den else 0
		draw_style_box(shade, Rect2(inner.position,
			Vector2(slice_width * float(num), inner.size.y)))

	# Garis pemisah antara bahagian (kekal kelihatan pada bahagian putih).
	var line_color := Color(0.62, 0.47, 0.76, 0.55)
	for i in range(1, den):
		var x := inner.position.x + slice_width * float(i)
		draw_line(Vector2(x, inner.position.y + 4.0),
			Vector2(x, inner.end.y - 4.0), line_color, 5.0, true)
