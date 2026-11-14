extends SceneTree
## Ujian pantas bank soalan sahaja (tanpa skrin / autoload).
## Jalankan:
##   godot --path MathMania --headless --script res://tests/run_tests.gd
##
## Untuk ujian penuh (termasuk setiap skrin), guna:
##   godot --path MathMania --headless res://tests/test_runner.tscn

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20240501

	_expect(QuestionBank.TOPICS.size() == 13, "bank: perlu 13 topik")

	for topic in QuestionBank.TOPICS:
		for difficulty in [1, 2, 3]:
			for i in 300:
				var q := QuestionBank.make_question(topic["id"], difficulty, rng)
				var label := "%s (tahap %d) #%d" % [topic["id"], difficulty, i]
				var choices: Array = q["choices"]
				var answer: Dictionary = q["answer_token"]

				_expect(choices.size() == 3, label + ": perlu 3 pilihan")
				_expect(int(q["answer_index"]) >= 0 and int(q["answer_index"]) < 3,
					label + ": answer_index di luar julat")
				_expect(choices[int(q["answer_index"])]["value"] == answer["value"],
					label + ": answer_index tidak menunjuk jawapan betul")
				_expect(_check_semantics(q), label + ": data semantik tidak konsisten")

				var tokens: Array = q["expr"]
				if not tokens.is_empty():
					_expect(_verify(tokens, answer), label + ": matematik tidak konsisten")

	print("Semakan dijalankan: %d" % checks)
	print("SEMUA UJIAN LULUS" if failures == 0 else "UJIAN GAGAL: %d" % failures)
	quit(0 if failures == 0 else 1)


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
			return str(answer["value"]) == "%d/%d" % [int(check["num"]), int(check["den"])]
		"time":
			return str(answer["value"]) == \
				"%d:%02d" % [int(check["hour"]), int(check["minute"])]
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


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("GAGAL: " + message)


func _verify(tokens: Array, answer: Dictionary) -> bool:
	var answer_token := {"t": str(answer.get("type", "num")), "v": answer["value"]}
	var seq: Array = []
	for token in tokens:
		if token["t"] == "unknown" or token["t"] == "unknown_glyph":
			seq.append(answer_token)
		else:
			seq.append(token)

	if seq.size() == 3 and seq[1]["t"] == "glyph":
		var left := _value_of(seq[0])
		var right := _value_of(seq[2])
		match seq[1]["v"]:
			"<":
				return left < right
			">":
				return left > right
		return is_equal_approx(left, right)

	if seq.size() == 5:
		var left := _value_of(seq[0])
		var right := _value_of(seq[2])
		var result := _value_of(seq[4])
		var expected := 0.0
		match seq[1]["v"]:
			"+":
				expected = left + right
			"-":
				expected = left - right
			"x":
				expected = left * right
			"/":
				expected = left / right
			_:
				return false
		return absf(expected - result) < 0.011
	return false


func _value_of(token: Dictionary) -> float:
	match token["t"]:
		"num":
			return float(token["v"])
		"text":
			return float(str(token["v"]).replace("RM", ""))
	return 0.0
