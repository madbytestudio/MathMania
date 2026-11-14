extends Control
## Skrin menu utama MathMania.

const TITLE_TEXT := "MATHMANIA"

var _letters: Array[TextureRect] = []
var _time: float = 0.0
var _modal: Control
var _mascot: AnimatedSprite2D
var _music_btn: Button
var _sfx_btn: Button


func _ready() -> void:
	_build()


func _process(delta: float) -> void:
	_time += delta
	for i in _letters.size():
		var letter := _letters[i]
		letter.pivot_offset = letter.size * 0.5
		letter.rotation = sin(_time * 1.7 + float(i) * 0.42) * 0.05
		var s := 1.0 + sin(_time * 2.3 + float(i) * 0.42) * 0.035
		letter.scale = Vector2(s, s)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _modal and _modal.visible:
		_show_modal(false)
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- pembinaan
func _build() -> void:
	# bg_meadow.png = latar malam berbintang (Background_1 dalam kit CraftPix).
	add_child(UI.background("res://assets/bg/bg_meadow.png"))
	_add_floating_objects()
	# Maskot di belakang UI supaya teks footer tidak terlindung.
	_add_mascot()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)

	column.add_child(_build_title())
	column.add_child(_build_subtitle())
	column.add_child(_build_buttons())
	column.add_child(_build_footer())

	_build_modal()
	_refresh_audio_buttons()


func _refresh_audio_buttons() -> void:
	if _music_btn:
		_music_btn.text = "MUZIK: " + ("ON" if GameState.music_on else "OFF")
	if _sfx_btn:
		_sfx_btn.text = "BUNYI: " + ("ON" if GameState.sfx_on else "OFF")


func _toggle_sfx() -> void:
	if GameState.sfx_on:
		Sfx.play("click")
		GameState.set_sfx_on(false)
	else:
		GameState.set_sfx_on(true)
		Sfx.play("click")
	_refresh_audio_buttons()


func _go_progress() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/progress.tscn")


func _build_title() -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 300)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", -18)
	center.add_child(row)

	for ch in TITLE_TEXT:
		var letter := UI.sprite_rect("res://assets/letters/%s.png" % ch, 215)
		row.add_child(letter)
		_letters.append(letter)
	return center


func _build_subtitle() -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 96)

	var badge := UI.pill(UI.PINK, Vector2(760, 74))
	badge.add_child(UI.label("Matematik Darjah 2  •  KSSR", 34, UI.WHITE))
	center.add_child(badge)
	return center


func _build_buttons() -> Control:
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 20)
	center.add_child(column)

	var play := UI.pill_button("MULA MAIN", UI.GREEN, Vector2(600, 118), 56)
	play.pressed.connect(_on_play_pressed)
	column.add_child(play)

	var how := UI.pill_button("CARA MAIN", UI.PURPLE, Vector2(600, 94), 42)
	how.pressed.connect(func() -> void:
		Sfx.play("click")
		_show_modal(true)
	)
	column.add_child(how)

	var progress := UI.pill_button("KEMAJUAN", UI.BLUE, Vector2(600, 94), 42)
	progress.pressed.connect(_go_progress)
	column.add_child(progress)

	var quit := UI.pill_button("KELUAR", UI.RED, Vector2(600, 84), 36)
	quit.pressed.connect(func() -> void:
		Sfx.play("click")
		get_tree().quit()
	)
	column.add_child(quit)
	return center


func _build_footer() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 84)

	var credit := UI.pill(Color(0.24, 0.18, 0.34, 0.42), Vector2(560, 54))
	credit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	credit.add_child(UI.label("Aset grafik: CraftPix.net  •  Lesen penggunaan bebas",
		21, Color(1, 1, 1, 0.92)))
	row.add_child(credit)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	_music_btn = UI.pill_button("", Color(0.42, 0.33, 0.55, 0.88),
		Vector2(190, 54), 22)
	_music_btn.pressed.connect(func() -> void:
		Sfx.play("click")
		GameState.set_music_on(not GameState.music_on)
		_refresh_audio_buttons()
	)
	_music_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_music_btn)

	_sfx_btn = UI.pill_button("", Color(0.42, 0.33, 0.55, 0.88),
		Vector2(180, 54), 22)
	_sfx_btn.pressed.connect(_toggle_sfx)
	_sfx_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_sfx_btn)

	var badge := UI.pill(Color(0.42, 0.33, 0.55, 0.88), Vector2(250, 66))
	var content := HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 10)
	var star := UI.sprite_rect("res://assets/ui/star_gold.png", 46)
	content.add_child(star)
	content.add_child(UI.label("x %d" % GameState.total_stars(), 34, UI.WHITE))
	badge.add_child(content)
	row.add_child(badge)
	return row


func _add_mascot() -> void:
	_mascot = UI.mascot_sprite("happy", 0.78)
	add_child(_mascot)

	var rest := Vector2(250, 900)
	_mascot.position = rest
	var tween := _mascot.create_tween()
	tween.set_loops()
	tween.tween_property(_mascot, "position:y", rest.y - 20.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_mascot, "position:y", rest.y, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _add_floating_objects() -> void:
	var items := [
		["res://assets/objects/strawberry.png", Vector2(1780, 250), 100.0, 1.4],
		["res://assets/objects/cherry.png", Vector2(130, 300), 92.0, 1.0],
		["res://assets/objects/toy_plane.png", Vector2(1800, 760), 104.0, 1.7],
	]
	for item in items:
		var sprite := UI.sprite_rect(item[0], item[2])
		sprite.size = sprite.custom_minimum_size
		sprite.position = item[1]
		sprite.modulate = Color(1, 1, 1, 0.92)
		add_child(sprite)

		var base_y: float = item[1].y
		var tween := sprite.create_tween()
		tween.set_loops()
		tween.tween_property(sprite, "position:y", base_y - 24.0, item[3]) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite, "position:y", base_y, item[3]) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _build_modal() -> void:
	_modal = Control.new()
	_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_modal.visible = false
	add_child(_modal)

	var dim := ColorRect.new()
	dim.color = Color(0.16, 0.11, 0.24, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(center)

	var card := UI.card(Vector2(1020, 700))
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 40)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	margin.add_child(column)

	column.add_child(UI.label("CARA MAIN", 52, UI.PURPLE_DK))

	var steps := [
		"1.  Pilih topik matematik yang kamu mahu.",
		"2.  Baca soalan di dalam kad dengan teliti.",
		"3.  Tekan satu daripada tiga pilihan jawapan.",
		"4.  Jawab betul berturut-turut untuk skor bonus!",
		"5.  Kumpul bintang dan pecahkan rekod sendiri.",
		"6.  Di komputer, tekan 1, 2 atau 3 untuk menjawab.",
	]
	for step in steps:
		column.add_child(UI.label(step, 34, UI.TXT, HORIZONTAL_ALIGNMENT_LEFT))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	var close := UI.pill_button("FAHAM", UI.GREEN, Vector2(320, 88), 40)
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close.pressed.connect(func() -> void:
		Sfx.play("click")
		_show_modal(false)
	)
	column.add_child(close)


func _show_modal(value: bool) -> void:
	_modal.visible = value
	if value:
		_modal.modulate.a = 0.0
		_modal.create_tween().tween_property(_modal, "modulate:a", 1.0, 0.18)


func _on_play_pressed() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/topic_select.tscn")
