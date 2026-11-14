class_name Banner
extends Control
## Reben (ribbon) berwarna dengan teks putih — tajuk topik / skrin.

var text: String = ""
var banner_color: Color = UI.PURPLE
var font_size: int = 44
var _label: Label


func _init(p_text: String = "", p_size: Vector2 = Vector2(560, 104),
		p_color: Color = UI.PURPLE, p_font_size: int = 44) -> void:
	text = p_text
	banner_color = p_color
	font_size = p_font_size
	custom_minimum_size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

	_label = UI.label(text, font_size, _text_color())
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_label)


## Tukar teks reben.
func set_text(value: String) -> void:
	text = value
	_label.text = value


## Tukar warna reben.
func set_color(value: Color) -> void:
	banner_color = value
	_label.add_theme_color_override("font_color", _text_color())
	queue_redraw()


## Teks putih untuk reben gelap, teks gelap untuk reben cerah.
func _text_color() -> Color:
	return UI.WHITE if banner_color.get_luminance() < 0.70 else UI.TXT


func _draw() -> void:
	var h := size.y
	var band_h := h * 0.78
	var top := (h - band_h) * 0.5 - h * 0.02
	var band := Rect2(Vector2(0.0, top), Vector2(size.x, band_h))
	var radius := int(band_h * 0.26)

	# Hujung reben yang berlipat di bawah badan.
	var fold := banner_color.darkened(0.22)
	var fold_w := minf(size.x * 0.10, band_h * 0.55)
	var fold_depth := h * 0.20
	draw_colored_polygon(PackedVector2Array([
		Vector2(2.0, top + band_h * 0.45),
		Vector2(fold_w, top + band_h * 0.45),
		Vector2(fold_w, top + band_h + fold_depth),
		Vector2(2.0, top + band_h + fold_depth * 0.35),
	]), fold)
	draw_colored_polygon(PackedVector2Array([
		Vector2(size.x - 2.0, top + band_h * 0.45),
		Vector2(size.x - fold_w, top + band_h * 0.45),
		Vector2(size.x - fold_w, top + band_h + fold_depth),
		Vector2(size.x - 2.0, top + band_h + fold_depth * 0.35),
	]), fold)

	# Badan reben.
	draw_style_box(UI.style_box(banner_color, radius, 5, Color(1, 1, 1, 0.75), true), band)

	# Garis putus-putus dalaman.
	var inner := band.grow(-band_h * 0.14)
	var inner_radius := maxf(radius - band_h * 0.14, 4.0)
	var inner_color := Color(1, 1, 1, 0.35)
	if banner_color.get_luminance() >= 0.70:
		inner_color = Color(0.36, 0.28, 0.42, 0.22)
	_dashed_round_rect(inner, inner_radius, inner_color, 4.0, 14.0)


func _dashed_round_rect(rect: Rect2, radius: float, color: Color, width: float,
		dash: float) -> void:
	var left := rect.position.x + radius
	var right := rect.end.x - radius
	var top := rect.position.y + radius
	var bottom := rect.end.y - radius
	draw_dashed_line(Vector2(left, rect.position.y), Vector2(right, rect.position.y),
		color, width, dash, true, true)
	draw_dashed_line(Vector2(left, rect.end.y), Vector2(right, rect.end.y),
		color, width, dash, true, true)
	draw_dashed_line(Vector2(rect.position.x, top), Vector2(rect.position.x, bottom),
		color, width, dash, true, true)
	draw_dashed_line(Vector2(rect.end.x, top), Vector2(rect.end.x, bottom),
		color, width, dash, true, true)
	draw_arc(Vector2(left, top), radius, PI, PI * 1.5, 12, color, width, true)
	draw_arc(Vector2(right, top), radius, PI * 1.5, TAU, 12, color, width, true)
	draw_arc(Vector2(right, bottom), radius, 0.0, PI * 0.5, 12, color, width, true)
	draw_arc(Vector2(left, bottom), radius, PI * 0.5, PI, 12, color, width, true)
