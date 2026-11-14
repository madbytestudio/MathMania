extends Control
## Skrin keputusan selepas satu pusingan tamat.

var _score_view: NumView
var _stars: Array[TextureRect] = []
var _review: Control


func _ready() -> void:
	_build()
	_animate_stars()
	_count_up_score()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _review and _review.visible:
			_review.visible = false
		else:
			_go_menu()
		get_viewport().set_input_as_handled()


func _build() -> void:
	# bg_forest.png = latar pelabuhan (Background_3 dalam kit CraftPix).
	add_child(UI.background("res://assets/bg/bg_forest.png"))

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := UI.card(Vector2(1080, 830), UI.CREAM, 52, 8, UI.CREAM_EDGE)
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var topic := QuestionBank.topic(GameState.last_topic_id)
	var passed := GameState.last_stars > 0

	column.add_child(UI.label("SYABAS!" if passed else "CUBA LAGI!",
		60, UI.GREEN_DK if passed else UI.ORANGE_DK))
	column.add_child(UI.label(topic["name"], 34, UI.TXT_SOFT))

	column.add_child(_build_stars())
	column.add_child(_build_score())
	column.add_child(UI.label("Betul %d daripada %d soalan" %
		[GameState.last_correct, GameState.last_total], 32, UI.TXT))

	var best := int(GameState.best_scores.get(GameState.last_topic_id, 0))
	var stars_best := int(GameState.best_stars.get(GameState.last_topic_id, 0))
	var record := UI.label("Rekod terbaik: %d  •  Bintang terbaik: %d/3" % [best, stars_best],
		24, UI.TXT_SOFT)
	column.add_child(record)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 18)
	column.add_child(spacer)

	column.add_child(_build_buttons())

	_add_mascot()
	_add_confetti()
	if not GameState.last_answers.is_empty():
		_build_review()


func _build_stars() -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)

	for i in 3:
		var star := UI.sprite_rect("res://assets/ui/star_gold.png", 132)
		star.pivot_offset = Vector2(66, 66)
		var earned: bool = i < GameState.last_stars
		star.modulate = Color(1, 1, 1, 1.0) if earned else Color(0.72, 0.68, 0.78, 0.42)
		row.add_child(star)
		_stars.append(star)
	return row


func _build_score() -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 150)

	_score_view = NumView.new(130.0)
	_score_view.set_value(0)
	center.add_child(_score_view)
	return center


func _build_buttons() -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)

	var has_review := not GameState.last_answers.is_empty()
	var button_width := 300.0 if has_review else 380.0
	var button_font := 32 if has_review else 40

	var again := UI.pill_button("MAIN LAGI", UI.GREEN,
		Vector2(button_width, 96), button_font)
	again.pressed.connect(_play_again)
	row.add_child(again)

	if has_review:
		var review := UI.pill_button("SEMAK JAWAPAN", UI.BLUE,
			Vector2(button_width, 96), 27)
		review.pressed.connect(_open_review)
		row.add_child(review)

	var topics := UI.pill_button("PILIH TOPIK", UI.PURPLE,
		Vector2(button_width, 96), button_font)
	topics.pressed.connect(_go_topics)
	row.add_child(topics)
	return row


# ------------------------------------------------------------ semakan jawapan
func _build_review() -> void:
	_review = Control.new()
	_review.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_review.visible = false
	add_child(_review)

	var dim := ColorRect.new()
	dim.color = Color(0.16, 0.11, 0.24, 0.62)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_review.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_review.add_child(center)

	var card := UI.card(Vector2(1520, 910), UI.CREAM, 46, 8, UI.CREAM_EDGE)
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 44)
	margin.add_theme_constant_override("margin_right", 44)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 26)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	var title := UI.label("SEMAK JAWAPAN", 40, UI.PURPLE_DK,
		HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var correct_count := 0
	for entry in GameState.last_answers:
		if bool(entry.get("ok", false)):
			correct_count += 1
	header.add_child(UI.label("Betul %d / %d" % [
		correct_count, GameState.last_answers.size()], 28, UI.TXT_SOFT))
	column.add_child(header)

	var divider := HSeparator.new()
	divider.add_theme_constant_override("separation", 4)
	column.add_child(divider)

	for i in GameState.last_answers.size():
		column.add_child(_build_review_row(i + 1, GameState.last_answers[i]))

	var footer := CenterContainer.new()
	var close := UI.pill_button("TUTUP", UI.GREEN, Vector2(300, 76), 34)
	close.pressed.connect(func() -> void:
		Sfx.play("click")
		_review.visible = false
	)
	footer.add_child(close)
	column.add_child(footer)


func _build_review_row(number: int, entry: Dictionary) -> Control:
	var ok: bool = bool(entry.get("ok", false))
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 74)
	row.add_theme_constant_override("separation", 14)

	var index := UI.label("%d." % number, 24, UI.TXT_SOFT)
	index.custom_minimum_size = Vector2(42, 0)
	row.add_child(index)

	var prompt := UI.label(str(entry.get("prompt", "")), 22, UI.TXT,
		HORIZONTAL_ALIGNMENT_LEFT)
	prompt.custom_minimum_size = Vector2(620, 0)
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(prompt)

	var chosen := UI.label("Jawapan: %s" % str(entry.get("chosen", "-")),
		22, UI.TXT_SOFT, HORIZONTAL_ALIGNMENT_LEFT)
	chosen.custom_minimum_size = Vector2(230, 0)
	row.add_child(chosen)

	var correct := UI.label("Betul: %s" % str(entry.get("correct", "-")),
		22, UI.GREEN_DK, HORIZONTAL_ALIGNMENT_LEFT)
	correct.custom_minimum_size = Vector2(230, 0)
	row.add_child(correct)

	var badge := UI.pill(UI.GREEN if ok else UI.RED, Vector2(118, 44))
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_child(UI.label("BETUL" if ok else "SALAH", 18, UI.WHITE))
	row.add_child(badge)
	return row


func _open_review() -> void:
	Sfx.play("click")
	_review.visible = true
	_review.modulate.a = 0.0
	_review.create_tween().tween_property(_review, "modulate:a", 1.0, 0.16)


func _add_mascot() -> void:
	var mascot := UI.mascot_sprite("celebrate", 0.72)
	add_child(mascot)
	mascot.position = Vector2(230, 900)
	var tween := mascot.create_tween()
	tween.set_loops()
	tween.tween_property(mascot, "position:y", 878.0, 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(mascot, "position:y", 900.0, 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _add_confetti() -> void:
	if GameState.last_stars < 2:
		return
	var confetti := TextureRect.new()
	confetti.texture = UI.tex("res://assets/ui/confetti.png")
	confetti.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	confetti.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	confetti.mouse_filter = Control.MOUSE_FILTER_IGNORE
	confetti.size = Vector2(420, 420)
	confetti.custom_minimum_size = confetti.size
	confetti.position = Vector2(1470, 30)
	confetti.pivot_offset = Vector2(210, 210)
	add_child(confetti)

	var tween := confetti.create_tween()
	tween.set_loops()
	tween.tween_property(confetti, "rotation", 0.18, 1.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(confetti, "rotation", -0.18, 1.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _animate_stars() -> void:
	for i in _stars.size():
		var star := _stars[i]
		var earned: bool = i < GameState.last_stars
		star.scale = Vector2.ONE * (0.2 if earned else 0.9)
		if not earned:
			continue
		var tween := star.create_tween()
		tween.tween_interval(0.25 + 0.22 * float(i))
		tween.tween_property(star, "scale", Vector2.ONE * 1.12, 0.20) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(star, "scale", Vector2.ONE, 0.14)
		tween.tween_callback(func() -> void: Sfx.play("pop"))


func _count_up_score() -> void:
	var target := GameState.last_score
	var update := func(value: float) -> void:
		_score_view.set_value(int(value))
	var tween := create_tween()
	tween.tween_method(update, 0.0, float(target), 0.9)
	tween.tween_callback(func() -> void: Sfx.play("win"))


func _play_again() -> void:
	Sfx.play("click")
	GameState.start_round(GameState.last_topic_id)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _go_topics() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/topic_select.tscn")


func _go_menu() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
