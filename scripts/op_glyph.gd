class_name OpGlyph
extends Control
## Melukis simbol operasi (+, -, =, x, /, <, >) dalam gaya "pil berkilat"
## supaya sepadan dengan aset CraftPix.

enum Kind { PLUS, MINUS, EQUALS, TIMES, DIVIDE, LESS, GREATER }

var kind: int = Kind.PLUS:
	set(value):
		kind = value
		queue_redraw()
var tint: Color = UI.ORANGE:
	set(value):
		tint = value
		queue_redraw()


func _init(p_kind: int = Kind.PLUS, p_size: float = 120.0, p_tint: Color = UI.ORANGE) -> void:
	kind = p_kind
	tint = p_tint
	custom_minimum_size = Vector2(p_size, p_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var s := minf(size.x, size.y)
	var t := s * 0.21
	var c := size * 0.5
	match kind:
		Kind.PLUS:
			_bar(c, s * 0.74, t, 0.0)
			_bar(c, s * 0.74, t, PI * 0.5)
		Kind.MINUS:
			_bar(c, s * 0.70, t, 0.0)
		Kind.EQUALS:
			_bar(c + Vector2(0, -s * 0.13), s * 0.62, t * 0.78, 0.0)
			_bar(c + Vector2(0, s * 0.13), s * 0.62, t * 0.78, 0.0)
		Kind.TIMES:
			_bar(c, s * 0.70, t * 0.9, PI * 0.25)
			_bar(c, s * 0.70, t * 0.9, -PI * 0.25)
		Kind.DIVIDE:
			_bar(c, s * 0.60, t * 0.75, 0.0)
			draw_circle(c + Vector2(0, -s * 0.22), t * 0.40, tint)
			draw_circle(c + Vector2(0, s * 0.22), t * 0.40, tint)
		Kind.LESS:
			_chevron(c, s, false)
		Kind.GREATER:
			_chevron(c, s, true)


## Satu bar bulat (pil) dengan kilauan di bahagian atas.
func _bar(center: Vector2, length: float, thickness: float, angle: float) -> void:
	if not is_zero_approx(angle):
		draw_set_transform(center, angle, Vector2.ONE)
		_bar(Vector2.ZERO, length, thickness, 0.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return

	var radius := thickness * 0.5
	var half := maxf(length * 0.5 - radius, 0.0)
	draw_rect(Rect2(center.x - half, center.y - radius, half * 2.0, thickness), tint, true)
	draw_circle(center + Vector2(-half, 0.0), radius, tint)
	draw_circle(center + Vector2(half, 0.0), radius, tint)

	var gloss := Color(1, 1, 1, 0.28)
	var gr := maxf(thickness * 0.16, 1.0)
	var ghalf := maxf(length * 0.28, 0.0)
	var gy := center.y - radius * 0.40
	draw_rect(Rect2(center.x - ghalf, gy - gr, ghalf * 2.0, gr * 2.0), gloss, true)
	draw_circle(Vector2(center.x - ghalf, gy), gr, gloss)
	draw_circle(Vector2(center.x + ghalf, gy), gr, gloss)


## Anak panah < atau > untuk perbandingan nombor.
func _chevron(center: Vector2, s: float, mirrored: bool) -> void:
	var thickness := s * 0.20
	var end_x := center.x + (s * 0.20 if mirrored else -s * 0.20)
	var apex_x := center.x + (-s * 0.22 if mirrored else s * 0.22)
	var top := Vector2(end_x, center.y - s * 0.26)
	var apex := Vector2(apex_x, center.y)
	var bottom := Vector2(end_x, center.y + s * 0.26)
	draw_polyline(PackedVector2Array([top, apex, bottom]), tint, thickness, true)
	draw_circle(top, thickness * 0.5, tint)
	draw_circle(apex, thickness * 0.5, tint)
	draw_circle(bottom, thickness * 0.5, tint)
