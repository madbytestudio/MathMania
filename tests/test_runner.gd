extends Node
## Ujian automatik MathMania (bank soalan + setiap skrin).
##
## Jalankan:
##   godot --path MathMania --headless res://tests/test_runner.tscn

var failures: int = 0
var checks: int = 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_question_bank()
	_test_answer_math()
	_test_scoring()
	_test_settings()
	await _test_scenes()

	print("")
	print("Semakan dijalankan: %d" % checks)
	if failures == 0:
		print("SEMUA UJIAN LULUS")
	else:
		print("UJIAN GAGAL: %d" % failures)
	get_tree().quit(0 if failures == 0 else 1)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("GAGAL: " + message)


func _test_question_bank() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20240501

	_expect(QuestionBank.TOPICS.size() == 11, "bank: perlu 11 topik KSSR")
	var seen_ids: Array = []
	for topic in QuestionBank.TOPICS:
		var id := str(topic["id"])
		_expect(not seen_ids.has(id), "bank: id topik berulang " + id)
		seen_ids.append(id)
		_expect(not str(topic["name"]).is_empty(), "bank: nama topik kosong")
		_expect(ResourceLoader.exists(str(topic["icon"])),
			"bank: ikon topik tidak wujud " + str(topic["icon"]))

	for topic in QuestionBank.TOPICS:
		var topic_id: String = topic["id"]
		for difficulty in [1, 2, 3]:
			for i in 200:
				var q := QuestionBank.make_question(topic_id, difficulty, rng)
				var label := "%s (tahap %d) #%d" % [topic_id, difficulty, i]

				_expect(not str(q["prompt"]).is_empty(), label + ": prompt kosong")
				var choices: Array = q["choices"]
				_expect(choices.size() == 3, label + ": perlu 3 pilihan")

				var seen: Array = []
				for choice in choices:
					var key := str(choice["value"])
					_expect(not seen.has(key), label + ": pilihan berulang " + key)
					seen.append(key)

				var answer_index: int = int(q["answer_index"])
				_expect(answer_index >= 0 and answer_index < 3,
					label + ": answer_index di luar julat")

				var answer_token: Dictionary = q["answer_token"]
				_expect(choices[answer_index]["value"] == answer_token["value"],
					label + ": answer_index tidak menunjuk jawapan betul")

				var matching := 0
				for value in seen:
					if value == str(answer_token["value"]):
						matching += 1
				_expect(matching == 1, label + ": jawapan betul tiada dalam pilihan")
				_expect(_check_semantics(q), label + ": data semantik tidak konsisten")


## Semak data semantik yang tidak boleh diuji melalui token persamaan
## (mengira objek, pecahan, jam, bentuk).
func _check_semantics(q: Dictionary) -> bool:
	var check: Dictionary = q.get("check", {})
	if check.is_empty():
		return true
	var answer: Dictionary = q["answer_token"]
	var visual: Dictionary = q["visual"]
	match str(check["kind"]):
		"count":
			return int(answer["value"]) == int(check["value"]) \
				and int(visual["count"]) == int(check["value"])
		"fraction":
			var expected := "%d/%d" % [int(check["num"]), int(check["den"])]
			return str(answer["value"]) == expected \
				and int(visual["num"]) == int(check["num"]) \
				and int(visual["den"]) == int(check["den"])
		"time":
			var expected := "%d:%02d" % [int(check["hour"]), int(check["minute"])]
			return str(answer["value"]) == expected \
				and int(visual["hour"]) == int(check["hour"]) \
				and int(visual["minute"]) == int(check["minute"])
		"shape":
			for item in QuestionBank.SHAPES_2D + QuestionBank.SHAPES_3D:
				if item["shape"] == visual["shape"]:
					return str(answer["value"]) == str(item["name"]) \
						and str(item["name"]) == str(check["value"])
			return false
		"sides":
			for item in QuestionBank.SHAPES_2D:
				if item["shape"] == visual["shape"]:
					return int(answer["value"]) == int(item["sides"]) \
						and int(item["sides"]) == int(check["value"])
			return false
	return false


func _test_answer_math() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 98765

	for topic in QuestionBank.TOPICS:
		for difficulty in [1, 2, 3]:
			for i in 300:
				var q := QuestionBank.make_question(topic["id"], difficulty, rng)
				var tokens: Array = q["expr"]
				var answer: Dictionary = q["answer_token"]
				if tokens.is_empty():
					continue
				_expect(_verify(tokens, answer),
					"%s (tahap %d) #%d: matematik tidak konsisten"
					% [topic["id"], difficulty, i])

				# Tahap mudah mesti kekal dalam lingkungan nombor kecil.
				if difficulty == 1:
					var value := float(str(answer["value"]).replace("RM", ""))
					_expect(value <= 220.0,
						"%s (tahap 1): nilai terlalu besar (%s)" % [topic["id"], str(value)])


## Semak jawapan betul menepati operasi dalam token.
func _verify(tokens: Array, answer: Dictionary) -> bool:
	var answer_token := {"t": str(answer.get("type", "num")), "v": answer["value"]}
	var seq: Array = []
	for token in tokens:
		if token["t"] == "unknown" or token["t"] == "unknown_glyph":
			seq.append(answer_token)
		else:
			seq.append(token)

	# Perbandingan: [kiri] [tanda] [kanan]
	if seq.size() == 3 and seq[1]["t"] == "glyph":
		var left := _value_of(seq[0])
		var right := _value_of(seq[2])
		var sign: String = seq[1]["v"]
		if sign == "<":
			return left < right
		if sign == ">":
			return left > right
		return is_equal_approx(left, right)

	# Persamaan: [kiri] [op] [kanan] [=] [hasil]
	if seq.size() == 5:
		var left := _value_of(seq[0])
		var right := _value_of(seq[2])
		var result := _value_of(seq[4])
		var symbol: String = seq[1]["v"]
		var expected := 0.0
		match symbol:
			"+":
				expected = left + right
			"-":
				expected = left - right
			"x":
				expected = left * right
			"/":
				if is_zero_approx(right):
					return false
				expected = left / right
			_:
				return false
		return absf(expected - result) < 0.011
	return false


## Tukar token kepada nilai berangka (wang ditukar kepada ringgit).
func _value_of(token: Dictionary) -> float:
	match token["t"]:
		"num":
			return float(token["v"])
		"text":
			var text: String = str(token["v"])
			return float(text.replace("RM", ""))
	return 0.0


func _test_scoring() -> void:
	_expect(GameState.stars_for_accuracy(1.0) == 3, "bintang: ketepatan 100%")
	_expect(GameState.stars_for_accuracy(0.75) == 2, "bintang: ketepatan 75%")
	_expect(GameState.stars_for_accuracy(0.5) == 1, "bintang: ketepatan 50%")
	_expect(GameState.stars_for_accuracy(0.1) == 0, "bintang: ketepatan 10%")

	GameState.start_round("ujian")
	var gained := 0
	for i in 8:
		gained += GameState.record_answer(true, i)
	_expect(GameState.correct == 8 and GameState.total == 8, "skor: kiraan jawapan betul")
	_expect(gained == 10 + 12 + 14 + 16 + 18 * 4, "skor: bonus berturut-turut")

	GameState.record_answer(false, 0)
	_expect(GameState.correct == 8 and GameState.total == 9, "skor: jawapan salah")

	GameState.finish_round(3)
	_expect(int(GameState.best_stars.get("ujian", 0)) == 3, "rekod: bintang disimpan")
	GameState.best_stars.erase("ujian")
	GameState.best_scores.erase("ujian")
	GameState.save_game()

	_expect(GameState.max_stars() == QuestionBank.TOPICS.size() * 3,
		"rekod: jumlah bintang maksimum")
	_expect(GameState.stars_for_accuracy(0.0) == 0, "bintang: ketepatan 0%")


func _test_settings() -> void:
	GameState.set_music_on(false)
	_expect(not Music.is_enabled(), "tetapan: muzik boleh dimatikan")
	GameState.set_sfx_on(false)
	_expect(Sfx.is_muted(), "tetapan: kesan bunyi boleh dimatikan")

	GameState.set_music_on(true)
	GameState.set_sfx_on(true)
	_expect(Music.is_enabled(), "tetapan: muzik boleh dihidupkan")
	_expect(not Sfx.is_muted(), "tetapan: kesan bunyi boleh dihidupkan")


func _test_scenes() -> void:
	GameState.start_round("tambah")
	GameState.last_topic_id = "tambah"
	GameState.last_score = 80
	GameState.last_correct = 7
	GameState.last_total = 8
	GameState.last_stars = 3
	GameState.last_answers = []
	for i in 8:
		GameState.last_answers.append({
			"ok": i % 3 != 0,
			"prompt": "Soalan ujian %d" % (i + 1),
			"chosen": str(10 + i),
			"correct": str(11 + i),
		})

	for path in [
		"res://scenes/main_menu.tscn",
		"res://scenes/topic_select.tscn",
		"res://scenes/game.tscn",
		"res://scenes/result.tscn",
		"res://scenes/progress.tscn",
	]:
		var scene: Node = load(path).instantiate()
		get_tree().root.add_child(scene)
		for i in 6:
			await get_tree().process_frame
		_expect(scene.get_child_count() >= 2, path + ": UI tidak dibina")
		if path.ends_with("result.tscn"):
			_expect(scene._review != null, "keputusan: modal semakan jawapan dibina")
			_expect(scene._review.get_child_count() >= 2,
				"keputusan: kandungan semakan jawapan kosong")
		if path.ends_with("progress.tscn"):
			_expect(scene._modal != null, "kemajuan: modal padam rekod dibina")
		scene.queue_free()
		await get_tree().process_frame

	# Semakan jawapan tidak wujud jika tiada log jawapan.
	GameState.last_answers = []
	var plain: Node = load("res://scenes/result.tscn").instantiate()
	get_tree().root.add_child(plain)
	for i in 4:
		await get_tree().process_frame
	_expect(plain._review == null, "keputusan: modal tidak dibina tanpa log")
	plain.queue_free()
	await get_tree().process_frame
