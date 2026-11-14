class_name PlaceValueView
extends Control
## Blok asas sepuluh untuk topik Nilai Tempat.
## Digit yang ditanya ditanda pada nombor, manakala blok ratus/puluh/sa
## dilukis di bawah supaya murid dapat mengaitkan nilai dengan kuantiti.

const FLAT := Color("f7b8cb")
const FLAT_EDGE := Color("c76a89")
const ROD := Color("a8dcf7")
const ROD_EDGE := Color("3f96cc")
const CUBE := Color("fde08a")
const CUBE_EDGE := Color("d9a520")

var number: int = 352
var highlight: int = -1
var _font: Font = load("res://assets/fonts/AlteHaasGroteskBold.ttf")


func _init(p_number: int = 352, p_highlight: int = -1,
		p_size: Vector2 = Vector2(880, 330)) -> void:
	number = p_number
	highlight = p_highlight
	custom_minimum_size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_value(p_number: int, p_highlight: int = -1) -> void:
	number = p_number
	highlight = p_highlight
	queue_redraw()


func _draw() -> void:
	var text := str(absi(number))
	var digits := text.length()
	var digit_w := 56.0
	var font_size := 62
	var total_w := digit_w * float(digits)
	var start_x := (size.x - total_w) * 0.5
	var digit_y := 10.0

	for i in digits:
		var box := Rect2(start_x + digit_w * float(i) + 2.0, digit_y,
			digit_w - 4.0, 84.0)
		var is_target := i == highlight
		if is_target:
			draw_style_box(UI.style_box(Color("fff4c9"), 18, 4, UI.YELLOW, true), box)

		var ch := text.substr(i, 1)
		var glyph_size := _font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT,
			-1, font_size)
		var glyph_pos := Vector2(
			box.position.x + (box.size.x - glyph_size.x) * 0.5,
			box.position.y + (box.size.y + glyph_size.y * 0.62) * 0.5)
		draw_string(_font, glyph_pos, ch, HORIZONTAL_ALIGNMENT_LEFT, -1,
			font_size, UI.PURPLE_DK if is_target else UI.TXT)

	_draw_blocks()


## Lukis blok ratus (petak), puluh (rod) dan sa (kubus) di bawah nombor.
func _draw_blocks() -> void:
	var hundreds := number / 100
	var tens := (number / 10) % 10
	var ones := number % 10

	var flat := 58.0
	var flat_gap := 6.0
	var rod_w := 12.0
	var rod_gap := 4.0
	var cube := 15.0
	var cube_gap := 4.0
	var group_gap := 34.0

	var flat_cols := mini(hundreds, 3)
	var flat_rows := ceili(float(hundreds) / 3.0) if hundreds > 0 else 0
	var flat_w := 0.0
	if hundreds > 0:
		flat_w = float(flat_cols) * flat + float(flat_cols - 1) * flat_gap
	var rod_w_total := 0.0
	if tens > 0:
		rod_w_total = float(tens) * rod_w + float(tens - 1) * rod_gap
	var cube_w_total := 0.0
	if ones > 0:
		cube_w_total = float(ones) * cube + float(ones - 1) * cube_gap

	var groups := 0
	for value in [hundreds, tens, ones]:
		if int(value) > 0:
			groups += 1
	var content_w := flat_w + rod_w_total + cube_w_total
	content_w += group_gap * float(maxi(groups - 1, 0))

	var top := 116.0
	var area_h := size.y - top - 8.0
	var total_h := maxf(float(flat_rows) * flat + float(maxi(flat_rows - 1, 0)) * flat_gap, flat)
	var y := top + (area_h - total_h) * 0.5
	var x := (size.x - content_w) * 0.5

	if hundreds > 0:
		for i in hundreds:
			var col := i % flat_cols
			var row := i / flat_cols
			var pos := Vector2(x + float(col) * (flat + flat_gap),
				y + float(row) * (flat + flat_gap))
			_draw_flat(pos, flat)
		x += flat_w + group_gap

	if tens > 0:
		for i in tens:
			_draw_rod(Vector2(x + float(i) * (rod_w + rod_gap), y), rod_w, flat)
		x += rod_w_total + group_gap

	if ones > 0:
		for i in ones:
			_draw_cube(Vector2(x + float(i) * (cube + cube_gap), y + (flat - cube) * 0.5), cube)


func _draw_flat(pos: Vector2, side: float) -> void:
	var rect := Rect2(pos, Vector2(side, side))
	draw_rect(rect, FLAT, true)
	# Grid 10 x 10 mewakili 100 unit.
	var step := side / 10.0
	var line := Color(FLAT_EDGE, 0.38)
	for i in range(1, 10):
		draw_line(pos + Vector2(step * float(i), 0),
			pos + Vector2(step * float(i), side), line, 1.0, true)
		draw_line(pos + Vector2(0, step * float(i)),
			pos + Vector2(side, step * float(i)), line, 1.0, true)
	draw_rect(rect, FLAT_EDGE, false, 3.0)


func _draw_rod(pos: Vector2, width: float, height: float) -> void:
	var rect := Rect2(pos, Vector2(width, height))
	draw_rect(rect, ROD, true)
	var step := height / 10.0
	var line := Color(ROD_EDGE, 0.4)
	for i in range(1, 10):
		draw_line(pos + Vector2(0, step * float(i)),
			pos + Vector2(width, step * float(i)), line, 1.0, true)
	draw_rect(rect, ROD_EDGE, false, 2.5)


func _draw_cube(pos: Vector2, side: float) -> void:
	var rect := Rect2(pos, Vector2(side, side))
	draw_rect(rect, CUBE, true)
	draw_rect(rect, CUBE_EDGE, false, 2.5)
	draw_circle(pos + Vector2(side * 0.32, side * 0.30), side * 0.11,
		Color(1, 1, 1, 0.35))
