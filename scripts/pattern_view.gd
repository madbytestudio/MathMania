class_name PatternView
extends Control
## Deretan kad nombor untuk topik Pola Nombor. Satu kad (indeks `hidden`)
## diganti dengan "?" supaya murid mencari nombor yang tertinggal.

const CARD_COLORS := [
	Color("f7b8cb"), Color("a8dcf7"), Color("fde08a"), Color("cbb3e6"),
	Color("b7e4a8"),
]
const CARD_EDGES := [
	Color("c76a89"), Color("3f96cc"), Color("d9a520"), Color("8d63b5"),
	Color("62a838"),
]

var seq: Array = [2, 4, 6, 8]
var missing_index: int = 3
var _font: Font = load("res://assets/fonts/AlteHaasGroteskBold.ttf")


func _init(p_seq: Array = [2, 4, 6, 8], p_missing_index: int = 3,
		p_size: Vector2 = Vector2(880, 250)) -> void:
	seq = p_seq.duplicate()
	missing_index = p_missing_index
	custom_minimum_size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_pattern(p_seq: Array, p_missing_index: int) -> void:
	seq = p_seq.duplicate()
	missing_index = p_missing_index
	queue_redraw()


func _draw() -> void:
	var count := seq.size()
	if count == 0:
		return

	var gap := 22.0
	var card_w := clampf((size.x - gap * float(count - 1)) / float(count),
		92.0, 150.0)
	var card_h := 132.0
	var total_w := card_w * float(count) + gap * float(count - 1)
	var x := (size.x - total_w) * 0.5
	var y := (size.y - card_h) * 0.5

	for i in count:
		var rect := Rect2(Vector2(x + float(i) * (card_w + gap), y),
			Vector2(card_w, card_h))
		var is_hidden := i == missing_index
		var fill: Color = Color("fff4c9") if is_hidden else UI.WHITE
		var edge: Color = UI.YELLOW if is_hidden else CARD_EDGES[i % CARD_EDGES.size()]

		draw_style_box(UI.style_box(fill, 22, 5, edge, true), rect)
		if not is_hidden:
			# Jalur warna kecil di atas kad.
			draw_style_box(UI.style_box(CARD_COLORS[i % CARD_COLORS.size()],
				10, 0, edge, false),
				Rect2(rect.position + Vector2(16, 12),
					Vector2(rect.size.x - 32, 12)))

		var label := "?" if is_hidden else str(seq[i])
		var font_size := 54 if label.length() < 4 else 42
		var text_size := _font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT,
			-1, font_size)
		var pos := Vector2(
			rect.position.x + (rect.size.x - text_size.x) * 0.5,
			rect.position.y + (rect.size.y + text_size.y * 0.62) * 0.5 + 8.0)
		draw_string(_font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1,
			font_size, UI.PURPLE_DK if is_hidden else UI.TXT)

	if count > 1:
		for i in count - 1:
			var cx := x + float(i + 1) * (card_w + gap) - gap * 0.5
			var cy := y + card_h * 0.5
			var arrow := Color(UI.TXT_SOFT, 0.55)
			draw_line(Vector2(cx - 6, cy - 8), Vector2(cx + 3, cy), arrow, 4.0, true)
			draw_line(Vector2(cx - 6, cy + 8), Vector2(cx + 3, cy), arrow, 4.0, true)
