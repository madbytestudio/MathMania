class_name NumView
extends HBoxContainer
## Memaparkan nombor menggunakan sprite digit berwarna daripada kit CraftPix.
## Teks bukan angka (contoh "RM5.70") dipaparkan dengan fon biasa.

const DIGIT_TEXTURE := "res://assets/numbers/d%d.png"

var digit_height: float = 150.0
var text_color: Color = UI.TXT


func _init(height: float = 150.0) -> void:
	digit_height = height
	alignment = BoxContainer.ALIGNMENT_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Rapatkan sedikit supaya digit kelihatan bersambung seperti tulisan.
	add_theme_constant_override("separation", int(-height * 0.055))


## Papar nilai integer.
func set_value(value: int) -> void:
	show_text(str(value))


## Papar teks (angka = sprite digit, selain itu fon).
func show_text(text: String) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	if _is_plain_number(text):
		for ch in text:
			add_child(_digit_node(ch.to_int()))
	else:
		var lbl := UI.label(text, int(digit_height * 0.68), text_color)
		lbl.custom_minimum_size = Vector2(0, digit_height)
		add_child(lbl)


func _is_plain_number(text: String) -> bool:
	if text.is_empty():
		return false
	for ch in text:
		if not ch.is_valid_int():
			return false
	return true


func _digit_node(digit: int) -> TextureRect:
	var texture: Texture2D = load(DIGIT_TEXTURE % digit)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var width := digit_height
	if texture.get_height() > 0:
		width = digit_height * float(texture.get_width()) / float(texture.get_height())
	rect.custom_minimum_size = Vector2(ceil(width), digit_height)
	return rect
