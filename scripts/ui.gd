class_name UI
extends RefCounted
## Koleksi pembantu UI untuk MathMania.
## Semua skrin dibina secara kod menggunakan fungsi-fungsi di sini supaya
## gaya (warna, sudut bulat, bayang) kekal konsisten.

# ---------------------------------------------------------------- palet warna
const TXT := Color("5a4a5e")
const TXT_SOFT := Color("8d7a92")
const WHITE := Color("ffffff")
const CREAM := Color("fffdf7")
const CREAM_EDGE := Color("efe3f0")

const PURPLE := Color("b184d6")
const PURPLE_DK := Color("8d63b5")
const PINK := Color("f28ba8")
const PINK_DK := Color("e06d8e")
const ORANGE := Color("f6a95a")
const ORANGE_DK := Color("e08e3c")
const GREEN := Color("7ec850")
const GREEN_DK := Color("62a838")
const BLUE := Color("63b7ea")
const BLUE_DK := Color("3f96cc")
const RED := Color("ef6f6c")
const YELLOW := Color("f8c93f")
const SHADOW := Color(0.34, 0.26, 0.40, 0.20)

const FONT_BOLD := "res://assets/fonts/AlteHaasGroteskBold.ttf"
const FONT_REGULAR := "res://assets/fonts/AlteHaasGroteskRegular.ttf"

static var _texture_cache: Dictionary = {}


# ------------------------------------------------------------------ utiliti
## Muat tekstur dengan cache (elak load berulang).
static func tex(path_or_texture) -> Texture2D:
	if path_or_texture is Texture2D:
		return path_or_texture
	if path_or_texture is String and not _texture_cache.has(path_or_texture):
		_texture_cache[path_or_texture] = load(path_or_texture)
	return _texture_cache.get(path_or_texture)


## StyleBoxFlat asas dengan bayang lembut.
static func style_box(bg: Color, radius: int = 28, border_width: int = 0,
		border_color: Color = WHITE, shadow: bool = true) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.anti_aliasing = true
	sb.set_corner_radius_all(radius)
	if border_width > 0:
		sb.set_border_width_all(border_width)
		sb.border_color = border_color
	if shadow:
		sb.shadow_color = SHADOW
		sb.shadow_size = 12
		sb.shadow_offset = Vector2(0, 8)
	return sb


## Kad putih bulat dengan bayang (untuk soalan, keputusan, topik).
static func card(min_size: Vector2, bg: Color = CREAM, radius: int = 44,
		border_width: int = 6, border_color: Color = CREAM_EDGE) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.add_theme_stylebox_override("panel",
		style_box(bg, radius, border_width, border_color, true))
	return panel


## Label dengan saiz dan warna tersuai.
static func label(text: String, font_size: int = 32, color: Color = TXT,
		align_h: int = HORIZONTAL_ALIGNMENT_CENTER,
		align_v: int = VERTICAL_ALIGNMENT_CENTER) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = align_h
	lbl.vertical_alignment = align_v
	return lbl


## Label dengan garis luar putih (mudah dibaca atas latar gambar).
static func label_outline(text: String, font_size: int = 32,
		color: Color = TXT, outline_size: int = 10) -> Label:
	var lbl := label(text, font_size, color)
	lbl.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.92))
	lbl.add_theme_constant_override("outline_size", outline_size)
	return lbl


## Butang pil berwarna dengan teks putih.
static func pill_button(text: String, bg: Color, size: Vector2 = Vector2(430, 100),
		font_size: int = 46) -> Button:
	var radius := int(size.y * 0.5)
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = size
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", WHITE)
	btn.add_theme_color_override("font_hover_color", WHITE)
	btn.add_theme_color_override("font_pressed_color", WHITE)
	btn.add_theme_stylebox_override("normal", style_box(bg, radius, 5, Color(1, 1, 1, 0.85), true))
	btn.add_theme_stylebox_override("hover", style_box(bg.lightened(0.10), radius, 5, WHITE, true))
	btn.add_theme_stylebox_override("pressed", style_box(bg.darkened(0.10), radius, 5, WHITE, false))
	btn.add_theme_stylebox_override("focus", style_box(Color(0, 0, 0, 0), radius, 0, WHITE, false))
	hover_pop(btn, 0.04)
	return btn


## Butang bulat berasaskan gambar PNG (play, next, home, replay ...).
static func image_button(path_or_texture, size: float = 96.0, tooltip: String = "") -> TextureButton:
	var btn := TextureButton.new()
	btn.texture_normal = tex(path_or_texture)
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.custom_minimum_size = Vector2(size, size)
	btn.focus_mode = Control.FOCUS_NONE
	btn.tooltip_text = tooltip
	hover_pop(btn, 0.09)
	return btn


## Kesan "pop" kecil bila tetikus/hover masuk.
static func hover_pop(control: Control, strength: float = 0.05) -> void:
	control.mouse_entered.connect(func() -> void:
		control.pivot_offset = control.size * 0.5
		control.create_tween().tween_property(control, "scale",
				Vector2.ONE * (1.0 + strength), 0.12)
	)
	control.mouse_exited.connect(func() -> void:
		control.create_tween().tween_property(control, "scale", Vector2.ONE, 0.12)
	)


## Gambar latar yang memenuhi skrin (mengekalkan nisbah 16:9).
static func background(path: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = tex(path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


## TextureRect untuk objek/sprite dengan tinggi tertentu (nisbah dikekalkan).
static func sprite_rect(path_or_texture, height: float) -> TextureRect:
	var t := tex(path_or_texture)
	var rect := TextureRect.new()
	rect.texture = t
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w := height
	if t and t.get_height() > 0:
		w = height * float(t.get_width()) / float(t.get_height())
	rect.custom_minimum_size = Vector2(ceil(w), height)
	return rect


## Kapsul separuh lutsinar (untuk skor, label kecil).
static func pill(bg: Color, size: Vector2, radius: int = -1) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = size
	var r := radius if radius >= 0 else int(size.y * 0.5)
	panel.add_theme_stylebox_override("panel", style_box(bg, r, 3, Color(1, 1, 1, 0.55), true))
	return panel


## Lingkaran kecil (untuk penunjuk kemajuan soalan).
static func dot(active: bool) -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(22, 22)
	var color := PURPLE if active else Color(1, 1, 1, 0.65)
	panel.add_theme_stylebox_override("panel", style_box(color, 11, 3, Color(1, 1, 1, 0.9), false))
	return panel


## Animasi maskot arnab yang tersedia dalam kit.
const MASCOT_ANIMS := {
	"idle": "Idle", "thinking": "Thinking", "celebrate": "Celebrating",
	"happy": "Happy", "pointing": "Pointing", "counting": "Counting",
}


## Cipta AnimatedSprite2D maskot dengan semua animasi dimuatkan.
static func mascot_sprite(initial: String = "idle", scale_factor: float = 1.0) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	for key in MASCOT_ANIMS:
		frames.add_animation(key)
		frames.set_animation_speed(key, 10.0)
		frames.set_animation_loop(key, true)
		for i in 8:
			frames.add_frame(key, load("res://assets/mascot/%s_%d.png" % [key, i]))
	sprite.sprite_frames = frames
	sprite.animation = initial
	sprite.scale = Vector2.ONE * scale_factor
	sprite.play(initial)
	return sprite


## Gerakkan node masuk dengan lembut (skala + pudar).
static func pop_in(control: Control, delay: float = 0.0) -> void:
	control.pivot_offset = control.size * 0.5
	control.scale = Vector2.ONE * 0.92
	control.modulate.a = 0.0
	var tween := control.create_tween()
	tween.set_parallel(true)
	tween.tween_interval(delay)
	tween.tween_property(control, "scale", Vector2.ONE, 0.28) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "modulate:a", 1.0, 0.22)
