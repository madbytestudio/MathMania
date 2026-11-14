extends Node
## Rakam tangkapan skrin setiap skrin untuk semakan visual.
## Jalankan: godot --path MathMania res://tests/screenshot.tscn --resolution 1920x1080

## Folder output: _shots di sebelah folder projek (boleh dipindahkan bersama projek).
var OUT_DIR: String = ProjectSettings.globalize_path("res://").path_join("../_shots").simplify_path()


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	await get_tree().process_frame

	await _capture("res://scenes/main_menu.tscn", "01_main_menu", "tambah")
	await _capture("res://scenes/topic_select.tscn", "02_topic_select", "tambah")
	await _capture("res://scenes/game.tscn", "03_game_tambah", "tambah")
	await _capture("res://scenes/game.tscn", "04_game_tambah_salah", "tambah",
		func(scene: Node) -> void:
			var wrong := (int(scene._question["answer_index"]) + 1) % 3
			scene._on_choice_selected(wrong)
	)
	await _capture("res://scenes/game.tscn", "05_game_kira", "kira")
	await _capture("res://scenes/game.tscn", "06_game_tolak_groups", "tolak")
	await _capture("res://scenes/game.tscn", "07_game_darab", "darab")
	await _capture("res://scenes/game.tscn", "08_game_banding", "banding")
	await _capture("res://scenes/game.tscn", "09_game_wang", "wang")
	await _capture("res://scenes/game.tscn", "11_game_pecahan", "pecahan")
	await _capture("res://scenes/game.tscn", "12_game_masa", "masa")
	await _capture("res://scenes/game.tscn", "13_game_bentuk", "bentuk")
	await _capture("res://scenes/game.tscn", "14_game_ukur", "ukur")
	await _capture("res://scenes/game.tscn", "15_game_nilai_tempat", "nilai_tempat")
	await _capture("res://scenes/game.tscn", "16_game_pola_nombor", "pola_nombor")
	await _capture("res://scenes/result.tscn", "10_result", "tambah")
	await _capture("res://scenes/result.tscn", "16_result_semakan", "tambah",
		func(scene: Node) -> void:
			scene._open_review()
	)
	await _capture("res://scenes/progress.tscn", "15_progress", "tambah")

	get_tree().quit()


func _capture(scene_path: String, name: String, topic_id: String,
		action: Callable = Callable()) -> void:
	GameState.start_round(topic_id)
	GameState.last_topic_id = topic_id
	GameState.last_score = 96
	GameState.last_correct = 8
	GameState.last_total = 8
	GameState.last_stars = 3
	GameState.best_scores[topic_id] = 96
	GameState.best_stars[topic_id] = 3
	GameState.last_answers = []
	for i in 8:
		GameState.last_answers.append({
			"ok": i % 3 != 0,
			"prompt": "Soalan contoh %d" % (i + 1),
			"chosen": str(12 + i),
			"correct": str(13 + i),
		})

	var scene: Node = load(scene_path).instantiate()
	get_tree().root.add_child(scene)
	await get_tree().process_frame
	await get_tree().create_timer(0.45).timeout

	if action.is_valid():
		await action.call(scene)
		await get_tree().create_timer(0.55).timeout

	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [OUT_DIR, name])
	print("disimpan: ", name, " ", image.get_size())

	scene.queue_free()
	await get_tree().process_frame
