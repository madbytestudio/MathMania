extends Control
## Skrin pilih topik. Senarai topik diambil daripada QuestionBank.TOPICS.

var _cards: Array[Button] = []


func _ready() -> void:
	_build()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back()
		get_viewport().set_input_as_handled()


func _build() -> void:
	add_child(UI.background("res://assets/bg/bg_mountain.png"))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 26)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	column.add_child(_build_top_bar())
	column.add_child(_build_grid())


func _build_top_bar() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 116)

	var left := Control.new()
	left.custom_minimum_size = Vector2(250, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var home := UI.image_button("res://assets/ui/home.png", 96.0, "Kembali ke menu")
	home.position = Vector2(0, 6)
	home.pressed.connect(_go_back)
	left.add_child(home)
	row.add_child(left)

	var banner := Banner.new("PILIH TOPIK", Vector2(660, 108), UI.PURPLE, 46)
	row.add_child(banner)

	var right := Control.new()
	right.custom_minimum_size = Vector2(250, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var badge := UI.pill(Color(0.42, 0.33, 0.55, 0.88), Vector2(210, 62))
	var content := HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	content.add_child(UI.sprite_rect("res://assets/ui/star_gold.png", 42))
	content.add_child(UI.label("x %d" % GameState.total_stars(), 30, UI.WHITE))
	badge.add_child(content)
	badge.position = Vector2(34, 26)
	right.add_child(badge)
	row.add_child(right)
	return row


func _build_grid() -> Control:
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# 11 topik perlu tiga baris; kad dikecilkan sedikit supaya semuanya muat.
	var compact := QuestionBank.TOPICS.size() > 8
	var flow := HFlowContainer.new()
	flow.alignment = FlowContainer.ALIGNMENT_CENTER
	flow.add_theme_constant_override("h_separation", 20 if compact else 26)
	flow.add_theme_constant_override("v_separation", 18 if compact else 26)
	flow.custom_minimum_size = Vector2(1790, 0)
	center.add_child(flow)

	for topic in QuestionBank.TOPICS:
		flow.add_child(_build_topic_card(topic, compact))
	return center


func _build_topic_card(topic: Dictionary, compact: bool = false) -> Button:
	var accent := Color(topic["color"])
	var card := Button.new()
	card.custom_minimum_size = Vector2(400, 280) if compact else Vector2(424, 336)
	card.focus_mode = Control.FOCUS_NONE
	var radius := 40
	var normal := UI.style_box(UI.CREAM, radius, 7, accent.lightened(0.35), true)
	var hover := UI.style_box(UI.WHITE, radius, 8, accent, true)
	var pressed := UI.style_box(UI.CREAM.darkened(0.04), radius, 8, accent.darkened(0.1), false)
	card.add_theme_stylebox_override("normal", normal)
	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", pressed)
	card.add_theme_stylebox_override("focus", UI.style_box(Color(0, 0, 0, 0), radius, 0, UI.WHITE, false))
	UI.hover_pop(card, 0.035)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var side := 18 if compact else 26
	margin.add_theme_constant_override("margin_left", side)
	margin.add_theme_constant_override("margin_right", side)
	margin.add_theme_constant_override("margin_top", 12 if compact else 18)
	margin.add_theme_constant_override("margin_bottom", 12 if compact else 18)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2 if compact else 4)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)

	# Ikon topik
	var icon_center := CenterContainer.new()
	icon_center.custom_minimum_size = Vector2(0, 90 if compact else 122)
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := UI.sprite_rect(topic["icon"], 84 if compact else 112)
	icon_center.add_child(icon)
	column.add_child(icon_center)

	# Nama dan penerangan
	var name_label := UI.label(topic["name"], 31 if compact else 38,
		accent.darkened(0.35))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(name_label)

	var desc_label := UI.label(topic["desc"], 20 if compact else 24, UI.TXT_SOFT)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(desc_label)

	# Bintang + rekod
	var stars_row := HBoxContainer.new()
	stars_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stars_row.add_theme_constant_override("separation", 6)
	stars_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var earned := int(GameState.best_stars.get(topic["id"], 0))
	for i in 3:
		var star := UI.sprite_rect("res://assets/ui/star_gold.png", 27 if compact else 34)
		star.modulate = Color(1, 1, 1, 1.0) if i < earned else Color(1, 1, 1, 0.32)
		stars_row.add_child(star)
	column.add_child(stars_row)

	var best := int(GameState.best_scores.get(topic["id"], 0))
	var record_text := "Rekod: %d" % best if best > 0 else "Belum dimainkan"
	var record := UI.label(record_text, 19 if compact else 21, UI.TXT_SOFT)
	record.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(record)

	card.pressed.connect(func() -> void: _start_topic(topic["id"]))
	return card


func _start_topic(topic_id: String) -> void:
	Sfx.play("click")
	GameState.start_round(topic_id)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _go_back() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
