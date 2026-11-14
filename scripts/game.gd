extends Control
## Skrin permainan MathMania: satu pusingan = 8 soalan.
## Kesukaran meningkat secara automatik (soalan 1-3 mudah, 4-6 sederhana, 7-8 susah).

const QUESTIONS_PER_ROUND := 8

const OP_KIND := {
	"+": OpGlyph.Kind.PLUS,
	"-": OpGlyph.Kind.MINUS,
	"=": OpGlyph.Kind.EQUALS,
	"x": OpGlyph.Kind.TIMES,
	"/": OpGlyph.Kind.DIVIDE,
	"<": OpGlyph.Kind.LESS,
	">": OpGlyph.Kind.GREATER,
}

var topic: Dictionary
var questions: Array = []
var q_index: int = 0
var streak: int = 0
var locked: bool = true
var answers_log: Array = []

# Rujukan nod
var _mascot: AnimatedSprite2D
var _banner: Banner
var _score_label: Label
var _counter_label: Label
var _prompt: Label
var _card: PanelContainer
var _card_box: VBoxContainer
var _visual_holder: CenterContainer
var _expr_row: HBoxContainer
var _choices_row: HBoxContainer
var _feedback_box: CenterContainer
var _feedback_panel: PanelContainer
var _feedback_label: Label
var _dots_row: HBoxContainer
var _confetti: TextureRect
var _advance_timer: Timer

var _choice_buttons: Array[Button] = []
var _choice_contents: Array[CenterContainer] = []
var _choice_borders: Array[DashedBox] = []
var _question: Dictionary = {}


func _ready() -> void:
	topic = QuestionBank.topic(GameState.topic_id)
	_build_questions()
	_build_ui()
	_show_question(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_home()
		return
	if locked:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int = event.keycode
		if key >= KEY_1 and key <= KEY_3:
			_on_choice_selected(key - KEY_1)


# ---------------------------------------------------------------- persediaan
func _build_questions() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	questions.clear()
	for i in QUESTIONS_PER_ROUND:
		questions.append(
			QuestionBank.make_question(topic["id"], QuestionBank.difficulty_for(i), rng)
		)


func _build_ui() -> void:
	add_child(UI.background("res://assets/bg/bg_room.png"))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	column.add_child(_build_top_bar())
	column.add_child(_build_prompt())
	column.add_child(_build_card())
	column.add_child(_build_feedback())
	column.add_child(_build_choices())
	column.add_child(_build_dots())

	_add_mascot()
	_add_confetti()
	_add_key_hint()
	_build_timer()
	_update_dots()


func _build_top_bar() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 108)
	row.add_theme_constant_override("separation", 14)

	var home := UI.image_button("res://assets/ui/home.png", 92.0, "Kembali")
	home.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	home.pressed.connect(_go_home)
	row.add_child(home)

	var counter_pill := UI.pill(Color(1, 1, 1, 0.75), Vector2(170, 62))
	_counter_label = UI.label("1 / %d" % QUESTIONS_PER_ROUND, 30, UI.TXT)
	counter_pill.add_child(_counter_label)
	counter_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(counter_pill)

	var spacer_left := Control.new()
	spacer_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer_left)

	_banner = Banner.new(topic["name"], Vector2(700, 104), Color(topic["color"]), 44)
	_banner.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_banner)

	var spacer_right := Control.new()
	spacer_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer_right)

	var score_pill := UI.pill(UI.PURPLE_DK, Vector2(230, 68))
	score_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var score_content := HBoxContainer.new()
	score_content.alignment = BoxContainer.ALIGNMENT_CENTER
	score_content.add_theme_constant_override("separation", 10)
	score_content.add_child(UI.sprite_rect("res://assets/ui/star_gold.png", 50))
	_score_label = UI.label("0", 38, UI.WHITE)
	score_content.add_child(_score_label)
	score_pill.add_child(score_content)
	row.add_child(score_pill)
	return row


func _build_prompt() -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 62)

	_prompt = UI.label_outline("", 40, UI.TXT, 10)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_prompt)
	return center


func _build_card() -> Control:
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_card = UI.card(Vector2(1520, 494), UI.CREAM, 44, 7, UI.CREAM_EDGE)
	center.add_child(_card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 44)
	margin.add_theme_constant_override("margin_right", 44)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	_card.add_child(margin)

	_card_box = VBoxContainer.new()
	_card_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_box.add_theme_constant_override("separation", 12)
	margin.add_child(_card_box)

	_visual_holder = CenterContainer.new()
	_visual_holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_card_box.add_child(_visual_holder)

	_expr_row = HBoxContainer.new()
	_expr_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_expr_row.add_theme_constant_override("separation", 12)
	_expr_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_card_box.add_child(_expr_row)
	return center


func _build_feedback() -> Control:
	_feedback_box = CenterContainer.new()
	_feedback_box.custom_minimum_size = Vector2(0, 76)

	_feedback_panel = PanelContainer.new()
	_feedback_panel.custom_minimum_size = Vector2(620, 72)
	_feedback_panel.add_theme_stylebox_override("panel",
		UI.style_box(UI.GREEN_DK, 36, 4, UI.WHITE, true))
	_feedback_panel.visible = false

	_feedback_label = UI.label("", 38, UI.WHITE)
	_feedback_panel.add_child(_feedback_label)
	_feedback_box.add_child(_feedback_panel)
	return _feedback_box


func _build_choices() -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 230)

	_choices_row = HBoxContainer.new()
	_choices_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices_row.add_theme_constant_override("separation", 36)
	center.add_child(_choices_row)

	for i in 3:
		var button := _make_choice_button()
		button.pressed.connect(_on_choice_selected.bind(i))
		_choices_row.add_child(button)
		_choice_buttons.append(button)
	return center


func _make_choice_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(340, 226)
	button.focus_mode = Control.FOCUS_NONE
	_reset_choice_style(button, UI.CREAM)
	UI.hover_pop(button, 0.04)

	var border := DashedBox.new(Color("c3a9de"), 7.0, Color(0, 0, 0, 0))
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(border)
	_choice_borders.append(border)

	var content := CenterContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)
	_choice_contents.append(content)
	return button


func _reset_choice_style(button: Button, bg: Color) -> void:
	var radius := 40
	button.add_theme_stylebox_override("normal", UI.style_box(bg, radius, 0, UI.WHITE, true))
	button.add_theme_stylebox_override("hover", UI.style_box(bg.lightened(0.35), radius, 0, UI.WHITE, true))
	button.add_theme_stylebox_override("pressed", UI.style_box(bg.darkened(0.05), radius, 0, UI.WHITE, false))
	button.add_theme_stylebox_override("focus", UI.style_box(Color(0, 0, 0, 0), radius, 0, UI.WHITE, false))


func _build_timer() -> void:
	_advance_timer = Timer.new()
	_advance_timer.one_shot = true
	add_child(_advance_timer)


func _build_dots() -> Control:
	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(0, 34)

	_dots_row = HBoxContainer.new()
	_dots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_dots_row.add_theme_constant_override("separation", 12)
	center.add_child(_dots_row)
	return center


func _add_mascot() -> void:
	_mascot = UI.mascot_sprite("idle", 0.68)
	add_child(_mascot)
	_mascot.position = Vector2(200, 892)
	var tween := _mascot.create_tween()
	tween.set_loops()
	tween.tween_property(_mascot, "position:y", 872.0, 1.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_mascot, "position:y", 892.0, 1.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Petunjuk kecil untuk pemain yang menggunakan papan kekunci.
func _add_key_hint() -> void:
	var hint := UI.label_outline("Tekan 1 / 2 / 3 untuk menjawab", 21, UI.TXT_SOFT, 6)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.position = Vector2(1330, 1036)
	hint.size = Vector2(540, 30)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)


func _add_confetti() -> void:
	_confetti = TextureRect.new()
	_confetti.texture = UI.tex("res://assets/ui/confetti.png")
	_confetti.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_confetti.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_confetti.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_confetti.custom_minimum_size = Vector2(420, 420)
	_confetti.size = Vector2(420, 420)
	_confetti.position = Vector2(750, 260)
	_confetti.pivot_offset = Vector2(210, 210)
	_confetti.visible = false
	add_child(_confetti)


# ------------------------------------------------------------- papar soalan
func _show_question(index: int) -> void:
	if index >= questions.size():
		_finish_round()
		return

	q_index = index
	_question = questions[index]
	locked = false

	_prompt.text = str(_question["prompt"])
	_counter_label.text = "%d / %d" % [index + 1, QUESTIONS_PER_ROUND]
	var has_visual: bool = str(_question["visual"].get("mode", "none")) != "none"
	_card.custom_minimum_size = Vector2(1520, 494 if has_visual else 366)
	_feedback_panel.visible = false
	_mascot.play("idle")

	_build_visual(_question["visual"])
	_build_expression(_question["expr"])
	_build_choices_content(_question)
	_animate_card()

	for i in 3:
		_reset_choice_style(_choice_buttons[i], UI.CREAM)
		_choice_borders[i].line_color = Color("c3a9de")

	_update_dots()


func _animate_card() -> void:
	_card.pivot_offset = _card.size * 0.5
	_card.scale = Vector2.ONE * 0.97
	_card.modulate.a = 0.55
	var tween := _card.create_tween()
	tween.set_parallel(true)
	tween.tween_property(_card, "scale", Vector2.ONE, 0.22) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_card, "modulate:a", 1.0, 0.16)


func _build_expression(tokens: Array, reveal: Dictionary = {}) -> void:
	for child in _expr_row.get_children():
		_expr_row.remove_child(child)
		child.queue_free()

	for token in tokens:
		var kind: String = token["t"]
		if kind == "unknown" or kind == "unknown_glyph":
			if reveal.is_empty():
				_expr_row.add_child(_unknown_box(kind))
			else:
				# Jawapan betul dipaparkan dalam bingkai hijau supaya jelas.
				_expr_row.add_child(_reveal_badge(_token_node(reveal, true)))
		else:
			_expr_row.add_child(_token_node(token, false))


func _token_node(token: Dictionary, highlight: bool) -> Control:
	var kind: String = token["t"]
	match kind:
		"num":
			var view := NumView.new(176.0)
			view.set_value(int(token["v"]))
			if highlight:
				view.text_color = UI.GREEN_DK
			return view
		"text":
			var lbl := UI.label(str(token["v"]), 92, UI.GREEN_DK if highlight else UI.TXT)
			lbl.custom_minimum_size = Vector2(0, 176)
			return lbl
		"op":
			var symbol: String = token["v"]
			var glyph := OpGlyph.new(OP_KIND.get(symbol, OpGlyph.Kind.PLUS), 150.0,
				UI.PINK if symbol == "=" else UI.ORANGE)
			return glyph
		"glyph":
			var sign: String = token["v"]
			return OpGlyph.new(OP_KIND.get(sign, OpGlyph.Kind.EQUALS), 150.0,
				UI.GREEN_DK if highlight else UI.PURPLE)
	return Control.new()


func _reveal_badge(content: Control) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",
		UI.style_box(Color("eaf7dd"), 30, 6, UI.GREEN, false))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.add_child(content)
	panel.add_child(margin)
	return panel


func _unknown_box(kind: String) -> Control:
	var side := 176.0 if kind == "unknown" else 168.0
	var box := DashedBox.new(Color("c3a9de"), 7.0, Color(1, 1, 1, 0.7))
	box.custom_minimum_size = Vector2(side, side)

	var mark := UI.label("?", 108, UI.PURPLE)
	mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(mark)
	return box


func _build_visual(visual: Dictionary) -> void:
	for child in _visual_holder.get_children():
		_visual_holder.remove_child(child)
		child.queue_free()

	var mode: String = visual.get("mode", "none")
	_visual_holder.visible = mode != "none"
	if mode == "none":
		return

	match mode:
		"objects":
			_visual_holder.add_child(
				_objects_tray(str(visual["sprite"]), int(visual["count"])))
		"groups":
			_visual_holder.add_child(_groups_row(visual))
		"fraction":
			_visual_holder.add_child(FractionView.new(int(visual["den"]),
				int(visual["num"]), Vector2(880, 240)))
		"clock":
			_visual_holder.add_child(
				ClockView.new(int(visual["hour"]), int(visual["minute"]), 370.0))
		"shape":
			_visual_holder.add_child(ShapeView.new(str(visual["shape"]), 380.0))
		"place_value":
			_visual_holder.add_child(
				PlaceValueView.new(int(visual["number"]), int(visual["highlight"]),
					Vector2(880, 330)))
		"pattern":
			_visual_holder.add_child(
				PatternView.new(visual["seq"], int(visual["missing_index"]),
					Vector2(880, 250)))
		"number_line":
			_visual_holder.add_child(
				NumberLineView.new(int(visual["number"]), int(visual["low"]),
					int(visual["high"]), int(visual["midpoint"]),
					Vector2(880, 180)))
		"pictograph":
			_visual_holder.add_child(
				PictographView.new(visual["categories"],
					Vector2(880, 260)))


## Pilih bilangan lajur yang seimbang (elak baris terakhir yang terlalu kosong).
func _best_columns(count: int) -> int:
	var best := 3
	var best_score := 99.0
	for candidate in range(2, 7):
		var rows := ceili(float(count) / float(candidate))
		var ratio := float(candidate) / float(rows)
		var score := absf(ratio - 1.8)
		if count % candidate != 0:
			score += 0.6
		if score < best_score:
			best_score = score
			best = candidate
	return best


## Susunan objek untuk soalan mengira: grid kemas di dalam dulang putih.
func _objects_tray(sprite_path: String, count: int) -> Control:
	var columns := count if count <= 5 else _best_columns(count)
	var rows := ceili(float(count) / float(columns))
	var height := clampf(400.0 / float(rows) - 16.0, 62.0, 172.0)

	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 6)
	for i in count:
		grid.add_child(UI.sprite_rect(sprite_path, height))

	var tray := PanelContainer.new()
	tray.add_theme_stylebox_override("panel",
		UI.style_box(Color(1, 1, 1, 0.6), 32, 5, Color("e3d5ef"), false))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_child(grid)
	tray.add_child(margin)
	return tray


## Baris kumpulan objek (untuk tambah, tolak, darab, bahagi).
func _groups_row(visual: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)

	var sprite_path: String = visual["sprite"]
	var groups: Array = visual["groups"]
	var total := 0
	for group in groups:
		total += int(group["count"])

	# Lebih banyak objek -> lukis lebih kecil supaya masih muat dalam kad.
	var max_columns := 4
	if groups.size() <= 2:
		max_columns = 8
	elif groups.size() == 3:
		max_columns = 5

	var object_height := 66.0
	if total > 20:
		object_height = 46.0
	elif total > 12 or groups.size() > 3:
		object_height = 58.0

	for group in groups:
		var count: int = int(group["count"])
		var dim: bool = bool(group["dim"])
		if count <= 0:
			continue

		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel",
			UI.style_box(Color(1, 1, 1, 0.9), 18, 4, Color("e3d5ef"), false))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		panel.add_child(margin)

		var grid := GridContainer.new()
		grid.columns = mini(count, max_columns)
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 4)
		margin.add_child(grid)

		for i in count:
			var sprite := UI.sprite_rect(sprite_path, object_height)
			if dim:
				sprite.modulate = Color(0.74, 0.70, 0.80, 0.34)
			grid.add_child(sprite)

		row.add_child(panel)
	return row


func _build_choices_content(question: Dictionary) -> void:
	var choices: Array = question["choices"]
	for i in _choice_contents.size():
		var content := _choice_contents[i]
		for child in content.get_children():
			content.remove_child(child)
			child.queue_free()

		if i >= choices.size():
			continue
		var choice: Dictionary = choices[i]
		var type: String = choice.get("type", "num")
		var text_value := str(choice["value"])

		match type:
			"num":
				var value := int(choice["value"])
				var height := 118.0 if text_value.length() <= 3 else 100.0
				var view := NumView.new(height)
				view.set_value(value)
				content.add_child(view)
			"text":
				# Nama bentuk panjang perlu fon lebih kecil supaya tidak terpotong.
				var size := 58
				if text_value.length() > 9:
					size = 34
				elif text_value.length() > 6:
					size = 44
				content.add_child(UI.label(text_value, size, UI.TXT))
			"glyph":
				var glyph := OpGlyph.new(OP_KIND.get(text_value, OpGlyph.Kind.EQUALS),
					120.0, UI.PURPLE)
				content.add_child(glyph)


func _update_dots() -> void:
	for child in _dots_row.get_children():
		_dots_row.remove_child(child)
		child.queue_free()

	for i in QUESTIONS_PER_ROUND:
		var state := 0
		if i < answers_log.size():
			state = 1 if bool(answers_log[i].get("ok", false)) else 2
		var color := Color(1, 1, 1, 0.62)
		if state == 1:
			color = UI.GREEN
		elif state == 2:
			color = UI.RED
		elif i == q_index and answers_log.size() == i:
			color = UI.PURPLE
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(22, 22) if i == q_index else Vector2(16, 16)
		dot.add_theme_stylebox_override("panel", UI.style_box(color, 11, 3, UI.WHITE, false))
		_dots_row.add_child(dot)


# ---------------------------------------------------------------- jawapan
func _on_choice_selected(index: int) -> void:
	if locked or index >= _choice_buttons.size():
		return
	locked = true

	var is_correct: bool = index == int(_question["answer_index"])
	var gained: int = GameState.record_answer(is_correct, streak)
	var answer_token: Dictionary = _question["answer_token"]
	var chosen: Dictionary = _question["choices"][index]
	answers_log.append({
		"ok": is_correct,
		"prompt": str(_question["prompt"]),
		"chosen": str(chosen["value"]),
		"correct": str(answer_token["value"]),
	})

	if is_correct:
		streak += 1
		Sfx.play("correct")
		_paint_choice(index, UI.GREEN)
		_burst_confetti()
		_feedback("BETUL!  +%d" % gained, UI.GREEN_DK)
		_mascot.play("celebrate")
	else:
		streak = 0
		Sfx.play("wrong")
		_paint_choice(index, UI.RED)
		_paint_choice(int(_question["answer_index"]), UI.GREEN)
		_build_expression(_question["expr"], _reveal_token(answer_token))
		var answer_text := str(answer_token["value"])
		var label := "JAWAPAN BETUL: %s" % answer_text
		if answer_token.get("type", "") == "glyph":
			label = "TANDA BETUL: %s" % answer_text
		_feedback(label, UI.RED)
		_mascot.play("thinking")

	_score_label.text = str(GameState.score)
	_update_dots()

	_advance_timer.start(1.35)
	await _advance_timer.timeout
	_show_question(q_index + 1)


## Tukar pilihan jawapan ({"type", "value"}) kepada token paparan ({"t", "v"}).
func _reveal_token(choice: Dictionary) -> Dictionary:
	return {"t": str(choice.get("type", "num")), "v": choice["value"]}


func _paint_choice(index: int, color: Color) -> void:
	if index < 0 or index >= _choice_buttons.size():
		return
	_reset_choice_style(_choice_buttons[index], color.lightened(0.78))
	_choice_borders[index].line_color = color
	_choice_borders[index].queue_redraw()

	var button := _choice_buttons[index]
	button.pivot_offset = button.size * 0.5
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE * 1.06, 0.10) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.14)


func _feedback(text: String, color: Color) -> void:
	_feedback_label.text = text
	_feedback_panel.add_theme_stylebox_override("panel", UI.style_box(color, 36, 4, UI.WHITE, true))
	_feedback_panel.visible = true
	_feedback_panel.pivot_offset = _feedback_panel.size * 0.5
	_feedback_panel.scale = Vector2.ONE * 0.85
	_feedback_panel.modulate.a = 0.0
	var tween := _feedback_panel.create_tween()
	tween.set_parallel(true)
	tween.tween_property(_feedback_panel, "scale", Vector2.ONE, 0.22) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_feedback_panel, "modulate:a", 1.0, 0.16)


func _burst_confetti() -> void:
	_confetti.visible = true
	_confetti.scale = Vector2.ONE * 0.35
	_confetti.modulate.a = 0.0
	var tween := _confetti.create_tween()
	tween.set_parallel(true)
	tween.tween_property(_confetti, "scale", Vector2.ONE * 1.25, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_confetti, "modulate:a", 1.0, 0.18)
	tween.chain().tween_property(_confetti, "modulate:a", 0.0, 0.45)
	tween.chain().tween_callback(func() -> void: _confetti.visible = false)


func _finish_round() -> void:
	locked = true
	var accuracy := 0.0
	if GameState.total > 0:
		accuracy = float(GameState.correct) / float(GameState.total)
	GameState.finish_round(GameState.stars_for_accuracy(accuracy), answers_log)
	Sfx.play("win")
	get_tree().change_scene_to_file("res://scenes/result.tscn")


func _go_home() -> void:
	Sfx.play("click")
	get_tree().change_scene_to_file("res://scenes/topic_select.tscn")
