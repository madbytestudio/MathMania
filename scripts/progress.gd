extends Control
## Skrin kemajuan: ringkasan bintang, topik dimainkan, skor terbaik dan
## senarai rekod setiap topik. Rekod boleh dipadam dengan pengesahan.

var _modal: Control


func _ready() -> void:
	_build()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _modal and _modal.visible:
			_modal.visible = false
		else:
			_go_menu()
		get_viewport().set_input_as_handled()


func _build() -> void:
	add_child(UI.background("res://assets/bg/bg_forest.png"))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 26)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	column.add_child(_build_top_bar())
	column.add_child(_build_summary())
	column.add_child(_build_list())
	column.add_child(_build_footer())
	_build_modal()


func _build_top_bar() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 116)

	var left := Control.new()
	left.custom_minimum_size = Vector2(250, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var home := UI.image_button("res://assets/ui/home.png", 96.0, "Kembali ke menu")
	home.position = Vector2(0, 6)
	home.pressed.connect(_go_menu)
	left.add_child(home)
	row.add_child(left)

	var banner := Banner.new("KEMAJUAN SAYA", Vector2(720, 108), UI.PURPLE, 44)
	row.add_child(banner)

	var right := Control.new()
	right.custom_minimum_size = Vector2(250, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var badge := UI.pill(Color(0.42, 0.33, 0.55, 0.88), Vector2(220, 62))
	var content := HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	content.add_child(UI.sprite_rect("res://assets/ui/star_gold.png", 42))
	content.add_child(UI.label("x %d" % GameState.total_stars(), 30, UI.WHITE))
	badge.add_child(content)
	badge.position = Vector2(24, 26)
	right.add_child(badge)
	row.add_child(right)
	return row


func _build_summary() -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)

	row.add_child(_summary_card("BINTANG DIKUMPUL",
		"%d / %d" % [GameState.total_stars(), GameState.max_stars()], UI.YELLOW))
	row.add_child(_summary_card("TOPIK DIMAINKAN",
		"%d / %d" % [GameState.topics_played(), QuestionBank.TOPICS.size()], UI.BLUE))
	row.add_child(_summary_card("SKOR TERTINGGI",
		str(GameState.top_score()), UI.GREEN))
	return row


func _summary_card(caption: String, value: String, accent: Color) -> Control:
	var card := UI.card(Vector2(560, 104), UI.CREAM, 30, 5, accent.lightened(0.35))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 0)
	margin.add_child(column)
	column.add_child(UI.label(caption, 19, UI.TXT_SOFT))
	column.add_child(UI.label(value, 40, accent.darkened(0.35)))
	return card


func _build_list() -> Control:
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 10)
	center.add_child(grid)

	for topic in QuestionBank.TOPICS:
		grid.add_child(_build_row(topic))

	# Bilangan topik ganjil: tambah satu sel kosong supaya grid kekal kemas.
	if QuestionBank.TOPICS.size() % 2 == 1:
		var filler := Control.new()
		filler.custom_minimum_size = Vector2(870, 88)
		grid.add_child(filler)
	return center


func _build_row(topic: Dictionary) -> Control:
	var accent := Color(topic["color"])
	var panel := UI.card(Vector2(870, 88), UI.CREAM, 26, 4, accent.lightened(0.4))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var icon := UI.sprite_rect(topic["icon"], 54)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)

	var text := VBoxContainer.new()
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 0)
	row.add_child(text)

	var name := UI.label(topic["name"], 26, accent.darkened(0.4),
		HORIZONTAL_ALIGNMENT_LEFT)
	text.add_child(name)
	var best := int(GameState.best_scores.get(topic["id"], 0))
	var subtitle := "Rekod terbaik: %d" % best if best > 0 else "Belum dimainkan"
	text.add_child(UI.label(subtitle, 18, UI.TXT_SOFT, HORIZONTAL_ALIGNMENT_LEFT))

	var stars := HBoxContainer.new()
	stars.alignment = BoxContainer.ALIGNMENT_END
	stars.add_theme_constant_override("separation", 4)
	stars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var earned := int(GameState.best_stars.get(topic["id"], 0))
	for i in 3:
		var star := UI.sprite_rect("res://assets/ui/star_gold.png", 26)
		star.modulate = Color(1, 1, 1, 1.0) if i < earned else Color(1, 1, 1, 0.30)
		stars.add_child(star)
	row.add_child(stars)
	return panel


func _build_footer() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 72)

	var note := UI.label("Rekod disimpan pada peranti ini sahaja.",
		20, UI.TXT_SOFT, HORIZONTAL_ALIGNMENT_LEFT)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(note)

	var reset := UI.pill_button("PADAM REKOD", UI.RED, Vector2(300, 66), 30)
	reset.pressed.connect(func() -> void:
		Sfx.play("click")
		_modal.visible = true
	)
	row.add_child(reset)
	return row


func _build_modal() -> void:
	_modal = Control.new()
	_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_modal.visible = false
	add_child(_modal)

	var dim := ColorRect.new()
	dim.color = Color(0.16, 0.11, 0.24, 0.62)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_modal.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(center)

	var card := UI.card(Vector2(900, 430))
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 44)
	margin.add_theme_constant_override("margin_right", 44)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)

	column.add_child(UI.label("PADAM SEMUA REKOD?", 40, UI.RED))
	var message := UI.label(
		"Semua bintang dan skor terbaik akan dipadam. Tindakan ini tidak boleh dibatalkan.",
		26, UI.TXT)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(message)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	column.add_child(spacer)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 20)
	column.add_child(buttons)

	var cancel := UI.pill_button("BATAL", UI.PURPLE, Vector2(300, 84), 32)
	cancel.pressed.connect(func() -> void:
		Sfx.play("click")
		_modal.visible = false
	)
	buttons.add_child(cancel)

	var confirm := UI.pill_button("YA, PADAM", UI.RED, Vector2(300, 84), 32)
	confirm.pressed.connect(_confirm_reset)
	buttons.add_child(confirm)


func _confirm_reset() -> void:
	GameState.reset_progress()
	Sfx.play("pop")
	get_tree().reload_current_scene()


func _go_menu() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
