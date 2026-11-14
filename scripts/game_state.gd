extends Node
## Autoload `GameState`
## Menyimpan topik yang dipilih, skor sesi semasa, dan rekod terbaik.
## Data disimpan dalam fail simpanan di user:// supaya kekal antara sesi.

const SAVE_PATH := "user://mathmania_save.cfg"

## Topik yang sedang dimainkan.
var topic_id: String = "tambah"

## Statistik sesi semasa.
var score: int = 0
var correct: int = 0
var total: int = 0

## Statistik pusingan terakhir (untuk skrin keputusan).
var last_topic_id: String = ""
var last_score: int = 0
var last_correct: int = 0
var last_total: int = 0
var last_stars: int = 0

## Log jawapan pusingan terakhir (untuk semakan di skrin keputusan).
## Setiap entri: {"ok": bool, "prompt": String, "chosen": String, "correct": String}
var last_answers: Array = []

## Rekod terbaik: topic_id -> skor terbaik, dan topic_id -> bintang (1-3).
var best_scores: Dictionary = {}
var best_stars: Dictionary = {}

## Tetapan bunyi.
var music_on: bool = true
var sfx_on: bool = true


func _ready() -> void:
	load_game()
	apply_audio.call_deferred()


## Mula pusingan baru untuk satu topik.
func start_round(p_topic_id: String) -> void:
	topic_id = p_topic_id
	score = 0
	correct = 0
	total = 0
	last_answers = []


## Catat jawapan murid. Pulangkan skor yang ditambah.
func record_answer(is_correct: bool, streak: int) -> int:
	total += 1
	if not is_correct:
		return 0
	correct += 1
	var bonus: int = mini(streak, 4) * 2
	var gained: int = 10 + bonus
	score += gained
	return gained


## Simpan keputusan pusingan dan kemas kini rekod terbaik.
func finish_round(stars_earned: int, answers: Array = []) -> void:
	last_topic_id = topic_id
	last_score = score
	last_correct = correct
	last_total = total
	last_stars = stars_earned
	last_answers = answers.duplicate(true)

	best_scores[topic_id] = maxi(int(best_scores.get(topic_id, 0)), score)
	best_stars[topic_id] = maxi(int(best_stars.get(topic_id, 0)), stars_earned)
	save_game()


## Bilangan bintang (0-3) untuk sesuatu ketepatan jawapan (0.0 - 1.0).
func stars_for_accuracy(accuracy: float) -> int:
	if accuracy >= 0.85:
		return 3
	if accuracy >= 0.6:
		return 2
	if accuracy >= 0.3:
		return 1
	return 0


## Jumlah bintang yang pernah dikumpul (semua topik).
func total_stars() -> int:
	var sum := 0
	for value in best_stars.values():
		sum += int(value)
	return sum


## Bilangan topik yang sudah dimainkan.
func topics_played() -> int:
	return best_stars.size()


func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	best_scores = cfg.get_value("rekod", "skor", {})
	best_stars = cfg.get_value("rekod", "bintang", {})
	if typeof(best_scores) != TYPE_DICTIONARY:
		best_scores = {}
	if typeof(best_stars) != TYPE_DICTIONARY:
		best_stars = {}
	music_on = bool(cfg.get_value("tetapan", "muzik", true))
	sfx_on = bool(cfg.get_value("tetapan", "bunyi", true))


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("rekod", "skor", best_scores)
	cfg.set_value("rekod", "bintang", best_stars)
	cfg.set_value("tetapan", "muzik", music_on)
	cfg.set_value("tetapan", "bunyi", sfx_on)
	cfg.save(SAVE_PATH)


## Padam semua rekod (digunakan oleh butang "Padam Rekod").
func reset_progress() -> void:
	best_scores.clear()
	best_stars.clear()
	save_game()


## Hidupkan/matikan muzik latar dan simpan tetapan.
func set_music_on(value: bool) -> void:
	music_on = value
	apply_audio()
	save_game()


## Hidupkan/matikan kesan bunyi dan simpan tetapan.
func set_sfx_on(value: bool) -> void:
	sfx_on = value
	apply_audio()
	save_game()


## Selaraskan autoload audio dengan tetapan semasa.
func apply_audio() -> void:
	Sfx.set_muted(not sfx_on)
	var music := get_node_or_null("/root/Music")
	if music:
		music.set_enabled(music_on)


## Jumlah bintang maksimum yang mungkin (3 setiap topik).
func max_stars() -> int:
	return QuestionBank.TOPICS.size() * 3


## Skor terbaik tertinggi dalam semua topik.
func top_score() -> int:
	var best := 0
	for value in best_scores.values():
		best = maxi(best, int(value))
	return best
