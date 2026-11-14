class_name ShapeView
extends Control
## Lukisan bentuk 2D dan 3D untuk topik Bentuk. Semua bentuk dilukis dengan
## kod supaya kekal tajam pada mana-mana saiz.

const BODY := UI.BLUE
const BODY_DARK := UI.BLUE_DK
const BODY_LIGHT := Color("a8dcf7")
const LINE := Color("5a7f99")

var shape: String = "square"


func _init(p_shape: String = "square", p_size: float = 330.0) -> void:
	shape = p_shape
	custom_minimum_size = Vector2(p_size, p_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_shape(p_shape: String) -> void:
	shape = p_shape
	queue_redraw()


func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size * 0.5
	match shape:
		"triangle":
			_triangle(c, s)
		"square":
			_rounded_box(c, Vector2(s * 0.62, s * 0.62), 22.0)
		"rectangle":
			_rounded_box(c, Vector2(s * 0.78, s * 0.50), 20.0)
		"circle":
			_circle(c, s * 0.34)
		"cube":
			_cube(c, s)
		"cuboid":
			_cuboid(c, s)
		"cylinder":
			_cylinder(c, s)
		"cone":
			_cone(c, s)
		"sphere":
			_sphere(c, s)
		"pyramid":
			_pyramid(c, s)


func _outline(points: PackedVector2Array, width: float = 7.0) -> void:
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, LINE, width, true)


func _triangle(c: Vector2, s: float) -> void:
	var h := s * 0.60
	var half := s * 0.30
	var top := c + Vector2(0, -h * 0.62)
	var left := c + Vector2(-half, h * 0.42)
	var right := c + Vector2(half, h * 0.42)
	var points := PackedVector2Array([top, left, right])
	draw_colored_polygon(points, UI.PINK)
	_outline(points)
	# Kilauan.
	draw_colored_polygon(PackedVector2Array([
		top + Vector2(-half * 0.22, h * 0.22),
		top + Vector2(half * 0.10, h * 0.22),
		left + Vector2(half * 0.42, -h * 0.16),
	]), Color(1, 1, 1, 0.28))


func _rounded_box(c: Vector2, box: Vector2, radius: float) -> void:
	var rect := Rect2(c - box * 0.5, box)
	var sb := UI.style_box(UI.PURPLE, int(radius), 6, LINE, false)
	draw_style_box(sb, rect)
	# Kilauan lembut di sudut kiri atas (bukan jalur melintang).
	var shine := rect.position + Vector2(rect.size.x * 0.26, rect.size.y * 0.20)
	var shine_r := rect.size.y * 0.17
	draw_circle(shine, shine_r, Color(1, 1, 1, 0.07))
	draw_circle(shine, shine_r * 0.66, Color(1, 1, 1, 0.09))
	draw_circle(shine, shine_r * 0.32, Color(1, 1, 1, 0.10))


func _circle(c: Vector2, r: float) -> void:
	draw_circle(c + Vector2(0, 6), r, Color(0.34, 0.26, 0.40, 0.14))
	draw_circle(c, r, UI.YELLOW)
	draw_arc(c, r, 0.0, TAU, 64, LINE, 7.0, true)
	draw_circle(c + Vector2(-r * 0.34, -r * 0.36), r * 0.18, Color(1, 1, 1, 0.55))


func _cube(c: Vector2, s: float) -> void:
	var side := s * 0.34
	var top_shift := Vector2(side * 0.42, -side * 0.42)
	var front := Rect2(c + Vector2(-side * 0.10, -side * 0.42), Vector2(side, side))
	var front_points := PackedVector2Array([
		front.position, Vector2(front.end.x, front.position.y),
		front.end, Vector2(front.position.x, front.end.y),
	])
	var top_points := PackedVector2Array([
		front.position + top_shift * 0.0,
		Vector2(front.end.x, front.position.y),
		Vector2(front.end.x, front.position.y) + top_shift,
		front.position + top_shift,
	])
	var side_points := PackedVector2Array([
		Vector2(front.end.x, front.position.y),
		front.end,
		front.end + top_shift,
		Vector2(front.end.x, front.position.y) + top_shift,
	])
	draw_colored_polygon(front_points, BODY)
	draw_colored_polygon(top_points, BODY_LIGHT)
	draw_colored_polygon(side_points, BODY_DARK)
	_outline(front_points)
	_outline(top_points)
	_outline(side_points)


func _cuboid(c: Vector2, s: float) -> void:
	var w := s * 0.48
	var h := s * 0.30
	var depth := Vector2(s * 0.14, -s * 0.14)
	var front := Rect2(c + Vector2(-w * 0.42, -h * 0.30), Vector2(w, h))
	var top_points := PackedVector2Array([
		front.position, Vector2(front.end.x, front.position.y),
		Vector2(front.end.x, front.position.y) + depth, front.position + depth,
	])
	var side_points := PackedVector2Array([
		Vector2(front.end.x, front.position.y), front.end,
		front.end + depth, Vector2(front.end.x, front.position.y) + depth,
	])
	draw_rect(front, BODY, true)
	draw_colored_polygon(top_points, BODY_LIGHT)
	draw_colored_polygon(side_points, BODY_DARK)
	_outline(PackedVector2Array([
		front.position, Vector2(front.end.x, front.position.y),
		front.end, Vector2(front.position.x, front.end.y)]))
	_outline(top_points)
	_outline(side_points)


func _cylinder(c: Vector2, s: float) -> void:
	var r := s * 0.20
	var h := s * 0.52
	var top_y := c.y - h * 0.5
	var bottom_y := c.y + h * 0.5
	draw_rect(Rect2(c.x - r, top_y, r * 2.0, h), BODY, true)
	draw_circle(Vector2(c.x, bottom_y), r, BODY_DARK)
	draw_circle(Vector2(c.x, top_y), r, BODY_LIGHT)
	draw_arc(Vector2(c.x, top_y), r, 0.0, TAU, 48, LINE, 6.0, true)
	draw_line(Vector2(c.x - r, top_y), Vector2(c.x - r, bottom_y), LINE, 6.0, true)
	draw_line(Vector2(c.x + r, top_y), Vector2(c.x + r, bottom_y), LINE, 6.0, true)
	draw_arc(Vector2(c.x, bottom_y), r, 0.0, PI, 32, LINE, 6.0, true)


func _cone(c: Vector2, s: float) -> void:
	var r := s * 0.21
	var top := c + Vector2(0, -s * 0.30)
	var base_y := c.y + s * 0.27
	var points := PackedVector2Array([
		top, Vector2(c.x + r, base_y), Vector2(c.x - r, base_y)])
	draw_circle(Vector2(c.x, base_y), r, BODY_DARK)
	draw_colored_polygon(points, BODY)
	_outline(points)
	draw_arc(Vector2(c.x, base_y), r, 0.0, PI, 32, LINE, 6.0, true)
	draw_colored_polygon(PackedVector2Array([
		top, top + Vector2(-r * 0.30, s * 0.18), top + Vector2(r * 0.20, s * 0.18)]),
		Color(1, 1, 1, 0.20))


func _sphere(c: Vector2, s: float) -> void:
	var r := s * 0.31
	draw_circle(c + Vector2(0, 6), r, Color(0.34, 0.26, 0.40, 0.16))
	draw_circle(c, r, UI.PINK)
	draw_arc(c, r, 0.0, TAU, 64, LINE, 7.0, true)
	draw_circle(c + Vector2(-r * 0.32, -r * 0.34), r * 0.20, Color(1, 1, 1, 0.55))
	# Bayang sfera.
	draw_arc(c + Vector2(r * 0.12, r * 0.16), r * 0.68, deg_to_rad(10.0),
		deg_to_rad(150.0), 32, Color(1, 1, 1, 0.18), 10.0, true)


func _pyramid(c: Vector2, s: float) -> void:
	var half := s * 0.26
	var top := c + Vector2(0, -s * 0.30)
	var left := c + Vector2(-half, s * 0.18)
	var right := c + Vector2(half, s * 0.18)
	var back := Vector2(c.x + half * 0.55, c.y + s * 0.02)
	# Tapak.
	draw_colored_polygon(PackedVector2Array([left, right, back]), BODY_DARK)
	# Permukaan hadapan.
	draw_colored_polygon(PackedVector2Array([top, left, right]), BODY)
	_outline(PackedVector2Array([top, left, right]))
	draw_line(left, back, LINE, 6.0, true)
	draw_line(right, back, LINE, 6.0, true)
