class_name PictographView
extends Control
## Piktograf untuk topik Pengurusan Data. Setiap kategori dipaparkan sebagai
## satu baris: nama kategori, ikon objek mengikut bilangan, dan bilangan di hujung.

var categories: Array = []
var _font: Font = load("res://assets/fonts/AlteHaasGroteskBold.ttf")


func _init(p_categories: Array = [], p_size: Vector2 = Vector2(880, 260)) -> void:
	categories = p_categories.duplicate()
	custom_minimum_size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_categories(p_categories: Array) -> void:
	categories = p_categories.duplicate()
	queue_redraw()


func _draw() -> void:
	if categories.is_empty():
		return

	var row_h := size.y / float(categories.size())
	var obj_size := 30.0
	var obj_gap := 6.0
	var obj_start_x := 160.0
	var count_x := size.x - 120.0

	for i in categories.size():
		var cat: Dictionary = categories[i]
		var cy := row_h * float(i) + row_h * 0.5

		# Nama kategori di kiri.
		var name := str(cat["name"])
		var name_size := _font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
		draw_string(_font, Vector2(16.0, cy + name_size.y * 0.3), name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 26, UI.TXT)

		# Ikon objek mengikut bilangan.
		var count := int(cat["count"])
		var sprite := str(cat["sprite"])
		var tex := UI.tex(sprite)
		var x := obj_start_x
		for j in count:
			if tex:
				draw_texture_rect(tex, Rect2(x, cy - obj_size * 0.5, obj_size, obj_size),
					false, Color(1, 1, 1, 0.9))
			x += obj_size + obj_gap

		# Bilangan di kanan.
		var count_text := str(count)
		var count_size := _font.get_string_size(count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
		draw_string(_font, Vector2(count_x, cy + count_size.y * 0.3), count_text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("c76a89"))
