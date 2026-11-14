class_name QuestionBank
extends RefCounted
## Penjana soalan matematik Darjah 2 (KSSR).
##
## Setiap topik ada 3 tahap kesukaran (1 = mudah, 2 = sederhana, 3 = susah).
## Soalan dipulangkan sebagai Dictionary:
##   prompt        : arahan soalan (Bahasa Melayu)
##   expr          : senarai token untuk baris operasi
##   visual        : penerangan bantuan visual (objek/kumpulan)
##   choices       : 3 pilihan jawapan
##   answer_index  : indeks jawapan betul dalam choices
##   answer_token  : token jawapan betul (untuk dipaparkan bila salah)
##   hint          : petunjuk ringkas

const OBJECT_POOL := [
	"duck", "snail", "bird", "rabbit", "turtle", "pig", "sheep", "cow", "fox", "monkey",
	"banana", "cherry", "coconut", "kiwi", "lemon", "peach", "pear", "pineapple", "plum", "strawberry",
	"cookie", "cupcake", "candy", "lollipop", "macaron", "marshmallow", "waffle", "cake_slice", "caramel",
	"block", "doll", "drum", "jump_rope", "puzzle_piece", "robot", "spinning_top", "toy_plane",
	"book", "crayon", "eraser", "ruler", "scissors", "pen",
]

const TOPICS := [
	{
		"id": "kira", "name": "Kira Objek", "short": "Kira",
		"desc": "Kira bilangan objek",
		"syllabus": "Nombor bulat 1 - 20",
		"icon": "res://assets/objects/duck.png", "color": "63b7ea",
	},
	{
		"id": "tambah", "name": "Tambah", "short": "Tambah",
		"desc": "Jumlah dalam lingkungan 1000",
		"syllabus": "Operasi tambah",
		"icon": "res://assets/objects/strawberry.png", "color": "f28ba8",
	},
	{
		"id": "tolak", "name": "Tolak", "short": "Tolak",
		"desc": "Beza antara dua nombor",
		"syllabus": "Operasi tolak",
		"icon": "res://assets/objects/banana.png", "color": "f6a95a",
	},
	{
		"id": "darab", "name": "Darab", "short": "Darab",
		"desc": "Sifir 2 hingga 10",
		"syllabus": "Operasi darab",
		"icon": "res://assets/objects/cupcake.png", "color": "b184d6",
	},
	{
		"id": "bahagi", "name": "Bahagi", "short": "Bahagi",
		"desc": "Bahagi sama banyak",
		"syllabus": "Operasi bahagi",
		"icon": "res://assets/objects/cookie.png", "color": "7ec850",
	},
	{
		"id": "banding", "name": "Banding Nombor", "short": "Banding",
		"desc": "Lebih, kurang atau sama",
		"syllabus": "Bandingkan nombor",
		"icon": "res://assets/objects/block.png", "color": "63b7ea",
	},
	{
		"id": "wang", "name": "Wang", "short": "Wang",
		"desc": "Ringgit dan sen",
		"syllabus": "Wang Malaysia",
		"icon": "res://assets/objects/calculator.png", "color": "f7c948",
	},
	{
		"id": "pecahan", "name": "Pecahan", "short": "Pecahan",
		"desc": "Bahagian daripada keseluruhan",
		"syllabus": "Pecahan 1/2 hingga 1/12",
		"icon": "res://assets/objects/cake_slice.png", "color": "e88bb8",
	},
	{
		"id": "masa", "name": "Masa & Waktu", "short": "Masa",
		"desc": "Baca jam dan minit",
		"syllabus": "Masa dan waktu",
		"icon": "res://assets/ui/clock.png", "color": "63b7ea",
	},
	{
		"id": "bentuk", "name": "Bentuk", "short": "Bentuk",
		"desc": "Bentuk 2D dan 3D",
		"syllabus": "Ruang: bentuk dua dan tiga dimensi",
		"icon": "res://assets/objects/block.png", "color": "b184d6",
	},
	{
		"id": "ukur", "name": "Ukuran", "short": "Ukuran",
		"desc": "Panjang, berat dan isi padu",
		"syllabus": "Ukuran panjang, berat, isi padu",
		"icon": "res://assets/objects/ruler.png", "color": "4fc3b0",
	},
	{
		"id": "nilai_tempat", "name": "Nilai Tempat", "short": "Tempat",
		"desc": "Nilai digit ratus, puluh dan sa",
		"syllabus": "Nilai tempat hingga 1000",
		"icon": "res://assets/objects/block.png", "color": "f7b8cb",
	},
	{
		"id": "pola_nombor", "name": "Pola Nombor", "short": "Pola",
		"desc": "Nombor hilang dalam pola menaik",
		"syllabus": "Pola dan susunan nombor",
		"icon": "res://assets/objects/puzzle_piece.png", "color": "a8dcf7",
	},
	{
		"id": "bundar_nombor", "name": "Bundar Nombor", "short": "Bundar",
		"desc": "Bundar kepada puluh atau ratus terdekat",
		"syllabus": "Bundaran nombor",
		"icon": "res://assets/objects/ruler.png", "color": "fde08a",
	},
]

## Bentuk dua dimensi: nama, bilangan sisi dan kunci lukisan.
const SHAPES_2D := [
	{"name": "segi tiga", "sides": 3, "shape": "triangle"},
	{"name": "segi empat sama", "sides": 4, "shape": "square"},
	{"name": "segi empat tepat", "sides": 4, "shape": "rectangle"},
	{"name": "bulatan", "sides": 0, "shape": "circle"},
]

## Bentuk tiga dimensi yang dilukis oleh ShapeView.
const SHAPES_3D := [
	{"name": "kubus", "shape": "cube"},
	{"name": "kuboid", "shape": "cuboid"},
	{"name": "silinder", "shape": "cylinder"},
	{"name": "kon", "shape": "cone"},
	{"name": "sfera", "shape": "sphere"},
	{"name": "piramid", "shape": "pyramid"},
]

## Unit ukuran: unit kecil (untuk jawapan) dan unit besar.
const MEASURES := {
	"panjang": {"small": "cm", "big": "m", "factor": 100},
	"berat": {"small": "g", "big": "kg", "factor": 1000},
	"isi": {"small": "ml", "big": "l", "factor": 1000},
}


## Cari metadata topik mengikut id.
static func topic(id: String) -> Dictionary:
	for item in TOPICS:
		if item["id"] == id:
			return item
	return TOPICS[0]


## Tahap kesukaran untuk soalan ke-index dalam satu pusingan (8 soalan).
static func difficulty_for(index: int) -> int:
	if index < 3:
		return 1
	if index < 6:
		return 2
	return 3


## Jana satu soalan.
static func make_question(topic_id: String, difficulty: int,
		rng: RandomNumberGenerator) -> Dictionary:
	match topic_id:
		"kira":
			return _make_kira(difficulty, rng)
		"tolak":
			return _make_tolak(difficulty, rng)
		"darab":
			return _make_darab(difficulty, rng)
		"bahagi":
			return _make_bahagi(difficulty, rng)
		"banding":
			return _make_banding(difficulty, rng)
		"wang":
			return _make_wang(difficulty, rng)
		"pecahan":
			return _make_pecahan(difficulty, rng)
		"masa":
			return _make_masa(difficulty, rng)
		"bentuk":
			return _make_bentuk(difficulty, rng)
		"ukur":
			return _make_ukur(difficulty, rng)
		"nilai_tempat":
			return _make_nilai_tempat(difficulty, rng)
		"pola_nombor":
			return _make_pola_nombor(difficulty, rng)
		"bundar_nombor":
			return _make_bundar_nombor(difficulty, rng)
		_:
			return _make_tambah(difficulty, rng)


# ------------------------------------------------------------ penjana soalan
static func _make_kira(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var range_max: int = [9, 15, 20][d - 1]
	var range_min: int = [3, 8, 12][d - 1]
	var count := rng.randi_range(range_min, range_max)
	var sprite := _random_object(rng)

	var question := {
		"prompt": "Berapakah bilangan gambar ini?",
		"expr": [],
		"visual": {"mode": "objects", "sprite": sprite, "count": count},
		"hint": "Kira satu demi satu.",
		"check": {"kind": "count", "value": count},
	}
	return _assemble(question, rng, _num_choice(count),
		_number_distractors(rng, count, [1, 2, 3], 0))


static func _make_tambah(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var a := 0
	var b := 0
	var visual := {"mode": "none"}
	match d:
		1:
			a = rng.randi_range(3, 12)
			b = rng.randi_range(2, maxi(2, mini(9, 20 - a)))
			visual = _groups_visual(_random_object(rng), [[a, false], [b, false]])
		2:
			a = rng.randi_range(20, 180)
			b = rng.randi_range(11, 99)
		3:
			a = rng.randi_range(120, 700)
			b = rng.randi_range(30, 199)

	var answer := a + b
	var deltas := [1, 2, 3] if d == 1 else [1, 2, 10, 20, 100]
	var question := {
		"prompt": "Berapakah jumlahnya?",
		"expr": _equation([_num(a), _op("+"), _num(b)]),
		"visual": visual,
		"hint": "Gabungkan dua nombor ini.",
	}
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, deltas, 0))


static func _make_tolak(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var a := 0
	var b := 0
	var visual := {"mode": "none"}
	match d:
		1:
			a = rng.randi_range(7, 20)
			b = rng.randi_range(2, a - 2)
			visual = _groups_visual(_random_object(rng), [[a - b, false], [b, true]])
		2:
			a = rng.randi_range(30, 300)
			b = rng.randi_range(10, a - 5)
		3:
			a = rng.randi_range(250, 990)
			b = rng.randi_range(40, maxi(45, mini(a - 20, 320)))

	var answer := a - b
	var deltas := [1, 2, 3] if d == 1 else [1, 2, 10, 20, 100]
	var question := {
		"prompt": "Berapakah bezanya?",
		"expr": _equation([_num(a), _op("-"), _num(b)]),
		"visual": visual,
		"hint": "Kurangkan nombor kedua.",
	}
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, deltas, 0))


static func _make_darab(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var tables := [2, 3, 4, 5, 10] if d < 3 else [2, 3, 4, 5, 6, 7, 8, 9, 10]
	var a: int = tables[rng.randi_range(0, tables.size() - 1)]
	var b := rng.randi_range(1, 5 if d == 1 else 10)
	var answer := a * b

	var visual := {"mode": "none"}
	var sprite := _random_object(rng)
	if a <= 5 and b <= 6:
		var groups: Array = []
		for i in a:
			groups.append([b, false])
		visual = _groups_visual(sprite, groups)

	var question := {
		"prompt": "Berapakah hasil darab?",
		"expr": _equation([_num(a), _op("x"), _num(b)]),
		"visual": visual,
		"hint": "Darab ialah kumpulan berulang.",
	}
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, [1, 2, a, b], 0))


static func _make_bahagi(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var divisors := [2, 3, 4, 5] if d == 1 else ([2, 3, 4, 5, 10] if d == 2 else [2, 3, 4, 5, 6, 7, 8, 9, 10])
	var divisor: int = divisors[rng.randi_range(0, divisors.size() - 1)]
	var quotient := rng.randi_range(1, 5 if d == 1 else 10)
	var dividend := divisor * quotient

	var visual := {"mode": "none"}
	if dividend <= 24:
		var groups: Array = []
		for i in divisor:
			groups.append([quotient, false])
		visual = _groups_visual(_random_object(rng), groups)

	var question := {
		"prompt": "Berapakah dalam setiap kumpulan?",
		"expr": _equation([_num(dividend), _op("/"), _num(divisor)]),
		"visual": visual,
		"hint": "Bahagi sama banyak ke dalam %d kumpulan." % divisor,
	}
	return _assemble(question, rng, _num_choice(quotient),
		_number_distractors(rng, quotient, [1, 2, 3], 1))


static func _make_banding(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var limit: int = [20, 100, 1000][d - 1]
	var a := rng.randi_range(1, limit)
	var b := a
	if rng.randf() > 0.2:
		b = rng.randi_range(1, limit)
		if b == a:
			b = clampi(a + rng.randi_range(1, 5), 1, limit)
			if b == a:
				b = maxi(a - rng.randi_range(1, 5), 1)

	var correct_sign := "="
	if a < b:
		correct_sign = "<"
	elif a > b:
		correct_sign = ">"

	var others: Array = []
	for sign in ["<", "=", ">"]:
		if sign != correct_sign:
			others.append(_glyph(sign))

	var question := {
		"prompt": "Pilih tanda yang betul.",
		"expr": [_num(a), _unknown_glyph(), _num(b)],
		"visual": {"mode": "none"},
		"hint": "Bandingkan nilai kedua-dua nombor.",
	}
	return _assemble(question, rng, _glyph(correct_sign), others)


static func _make_wang(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var answer_sen := 0
	var expr: Array = []
	var prompt := ""
	var question_hint := ""

	match d:
		1:
			var a := rng.randi_range(1, 40) * 10
			var b := rng.randi_range(1, 40) * 10
			answer_sen = a + b
			expr = _equation([_text(_ringgit(a)), _op("+"), _text(_ringgit(b))])
			prompt = "Berapakah jumlah wang ini?"
			question_hint = "Tambah nilai wang."
		2:
			var total: int = [1000, 2000, 5000][rng.randi_range(0, 2)]
			var spent := rng.randi_range(2, 40) * 5
			answer_sen = total - spent
			expr = _equation([_text(_ringgit(total)), _op("-"), _text(_ringgit(spent))])
			prompt = "Berapakah baki wang ini?"
			question_hint = "Tolak wang yang dibelanjakan."
		3:
			var price := rng.randi_range(5, 30) * 10
			var quantity := rng.randi_range(2, 5)
			answer_sen = price * quantity
			expr = _equation([_text(_ringgit(price)), _op("x"), _num(quantity)])
			prompt = "Berapakah jumlah harga?"
			question_hint = "Darab harga dengan bilangan barang."

	var question := {
		"prompt": prompt,
		"expr": expr,
		"visual": {"mode": "none"},
		"hint": question_hint,
	}
	return _assemble(question, rng, _text_choice(_ringgit(answer_sen)),
		_money_distractors(rng, answer_sen))


static func _make_pecahan(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var denominator: int
	var numerator: int
	match d:
		1:
			denominator = [2, 3, 4][rng.randi_range(0, 2)]
			numerator = 1
		2:
			denominator = [4, 5, 6, 8][rng.randi_range(0, 3)]
			numerator = rng.randi_range(1, denominator - 1)
		_:
			denominator = [8, 10, 12][rng.randi_range(0, 2)]
			numerator = rng.randi_range(1, denominator - 1)

	var answer_text := "%d/%d" % [numerator, denominator]
	var others: Array = []
	var candidates := [
		"%d/%d" % [numerator + 1, denominator],
		"%d/%d" % [maxi(1, numerator - 1), denominator],
		"%d/%d" % [numerator, denominator + 1],
		"%d/%d" % [numerator, denominator + 2],
		"%d/%d" % [numerator + 1, denominator + 1],
		"%d/%d" % [1, denominator + 1],
	]
	for candidate in candidates:
		var text := str(candidate)
		if text == answer_text or others.has(text):
			continue
		var parts := text.split("/")
		if int(parts[0]) >= int(parts[1]) or int(parts[0]) <= 0:
			continue
		others.append(text)
		if others.size() >= 2:
			break

	# Simpanan: pilih pecahan wajar lain jika calon di atas tidak mencukupi.
	if others.size() < 2:
		for den in range(2, 14):
			for num in range(1, den):
				var text := "%d/%d" % [num, den]
				if text != answer_text and not others.has(text):
					others.append(text)
					if others.size() >= 2:
						break
			if others.size() >= 2:
				break

	var question := {
		"prompt": "Apakah pecahan bahagian berwarna?",
		"expr": [],
		"visual": {"mode": "fraction", "num": numerator, "den": denominator},
		"hint": "Kira bahagian berwarna daripada jumlah semua bahagian.",
		"check": {"kind": "fraction", "num": numerator, "den": denominator},
	}
	var choices: Array = []
	for text in others:
		choices.append(_text_choice(text))
	return _assemble(question, rng, _text_choice(answer_text), choices)


static func _make_masa(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var hour := rng.randi_range(1, 12)
	var minute := 0
	match d:
		1:
			minute = [0, 30][rng.randi_range(0, 1)]
		2:
			minute = rng.randi_range(0, 11) * 5
		_:
			minute = [5, 10, 15, 20, 25, 35, 40, 45, 50, 55][rng.randi_range(0, 9)]

	var answer_text := "%d:%02d" % [hour, minute]
	var candidates := [
		"%d:%02d" % [_wrap_hour(hour + 1), minute],
		"%d:%02d" % [_wrap_hour(hour - 1), minute],
		"%d:%02d" % [hour, (minute + 30) % 60],
		"%d:%02d" % [hour, (minute + 5) % 60],
		"%d:%02d" % [hour, (minute + 55) % 60],
		"%d:%02d" % [maxi(1, int(minute / 5.0)), (hour * 5) % 60],
	]

	var others: Array = []
	for candidate in candidates:
		var text := str(candidate)
		if text == answer_text or others.has(text):
			continue
		others.append(text)
		if others.size() >= 2:
			break
	while others.size() < 2:
		var fallback := "%d:%02d" % [_wrap_hour(hour + others.size() + 2), minute]
		if fallback != answer_text and not others.has(fallback):
			others.append(fallback)

	var question := {
		"prompt": "Pukul berapakah jam ini menunjukkan?",
		"expr": [],
		"visual": {"mode": "clock", "hour": hour, "minute": minute},
		"hint": "Jarum pendek = jam, jarum panjang = minit.",
		"check": {"kind": "time", "hour": hour, "minute": minute},
	}
	var choices: Array = []
	for text in others:
		choices.append(_text_choice(text))
	return _assemble(question, rng, _text_choice(answer_text), choices)


static func _wrap_hour(hour: int) -> int:
	var value := hour
	while value > 12:
		value -= 12
	while value < 1:
		value += 12
	return value


static func _make_bentuk(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var question := {
		"prompt": "Apakah nama bentuk ini?",
		"expr": [],
		"hint": "Lihat bilangan sisi dan bucunya.",
	}
	if d == 3:
		var shape: Dictionary = SHAPES_3D[rng.randi_range(0, SHAPES_3D.size() - 1)]
		var names: Array = []
		for item in SHAPES_3D:
			names.append(item["name"])
		question["visual"] = {"mode": "shape", "shape": shape["shape"]}
		question["check"] = {"kind": "shape", "value": shape["name"]}
		question["hint"] = "Bentuk 3D mempunyai permukaan, bucu dan tepi."
		return _assemble(question, rng, _text_choice(shape["name"]),
			_text_distractors(rng, shape["name"], names))

	var candidates: Array = []
	for item in SHAPES_2D:
		candidates.append(item)
	var shape2d: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]

	if d == 2:
		var with_sides: Array = []
		for item in SHAPES_2D:
			if int(item["sides"]) > 0:
				with_sides.append(item)
		shape2d = with_sides[rng.randi_range(0, with_sides.size() - 1)]
		var sides: int = int(shape2d["sides"])
		question["prompt"] = "Berapakah bilangan sisi bentuk ini?"
		question["hint"] = "Kira sisi di sekeliling bentuk."
		question["visual"] = {"mode": "shape", "shape": shape2d["shape"]}
		question["check"] = {"kind": "sides", "value": sides}

		var numbers: Array = []
		for value in [3, 4, 5, 6]:
			if value != sides:
				numbers.append(value)
		return _assemble(question, rng, _num_choice(sides),
			[_num_choice(int(numbers[0])), _num_choice(int(numbers[1]))])

	var names2d: Array = []
	for item in SHAPES_2D:
		names2d.append(item["name"])
	question["visual"] = {"mode": "shape", "shape": shape2d["shape"]}
	question["check"] = {"kind": "shape", "value": shape2d["name"]}
	return _assemble(question, rng, _text_choice(shape2d["name"]),
		_text_distractors(rng, shape2d["name"], names2d))


## Pilih dua nama lain yang berbeza daripada jawapan.
static func _text_distractors(rng: RandomNumberGenerator, answer: String,
		pool: Array) -> Array:
	var options: Array = []
	for value in pool:
		var text := str(value)
		if text != answer and not options.has(text):
			options.append(text)
	for i in range(options.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = options[i]
		options[i] = options[j]
		options[j] = tmp
	var result: Array = []
	for i in mini(2, options.size()):
		result.append(_text_choice(options[i]))
	return result


static func _make_ukur(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var kinds := ["panjang", "berat", "isi"]
	var kind: String = kinds[rng.randi_range(0, kinds.size() - 1)]
	var unit: Dictionary = MEASURES[kind]
	var small: String = unit["small"]
	var big: String = unit["big"]
	var factor: int = int(unit["factor"])
	var prompt := ""
	var hint := ""
	var expr: Array = []
	var answer := 0

	match d:
		1:
			var a := rng.randi_range(25, 95)
			var b := rng.randi_range(5, mini(40, a - 5))
			if rng.randf() > 0.45:
				expr = _equation([_num(a), _op("+"), _num(b)])
				answer = a + b
				prompt = "%d %s ditambah %d %s. Berapa %s jumlahnya?" % [
					a, small, b, small, small]
				hint = "Jumlahkan kedua-dua nilai."
			else:
				expr = _equation([_num(a), _op("-"), _num(b)])
				answer = a - b
				prompt = "%d %s dipotong %d %s. Berapa %s bakinya?" % [
					a, small, b, small, small]
				hint = "Kurangkan nilai kedua daripada nilai pertama."
		2:
			var big_a := rng.randi_range(1, 4)
			var part_a := rng.randi_range(1, 9) * 10
			var big_b := rng.randi_range(1, 3)
			var part_b := rng.randi_range(1, 9) * 10
			var a_small := big_a * factor + part_a
			var b_small := big_b * factor + part_b
			if rng.randf() > 0.5:
				expr = _equation([_num(a_small), _op("+"), _num(b_small)])
				answer = a_small + b_small
				prompt = "%d %s %d %s ditambah %d %s %d %s. Berapa %s jumlahnya?" % [
					big_a, big, part_a, small, big_b, big, part_b, small, small]
			else:
				if b_small > a_small or b_small == a_small:
					var tmp_a := big_a
					var tmp_part := part_a
					big_a = big_b
					part_a = part_b
					big_b = tmp_a
					part_b = tmp_part
					a_small = big_a * factor + part_a
					b_small = big_b * factor + part_b
				if b_small == a_small:
					big_a += 1
					a_small = big_a * factor + part_a
				expr = _equation([_num(a_small), _op("-"), _num(b_small)])
				answer = a_small - b_small
				prompt = "%d %s %d %s dikurangkan %d %s %d %s. Berapa %s bakinya?" % [
					big_a, big, part_a, small, big_b, big, part_b, small, small]
			hint = "Tukar %s kepada %s dahulu: 1 %s = %d %s." % [
				big, small, big, factor, small]
		_:
			var quantity := rng.randi_range(2, 5)
			var amount := 0
			match kind:
				"panjang":
					amount = rng.randi_range(1, 4) * factor + rng.randi_range(1, 9) * 10
				"berat":
					amount = rng.randi_range(1, 3) * factor + rng.randi_range(1, 9) * 100
				_:
					amount = rng.randi_range(1, 9) * 100
			expr = _equation([_num(quantity), _op("x"), _num(amount)])
			answer = quantity * amount
			var item_word := "tali" if kind == "panjang" else ("bungkus" if kind == "berat" else "botol")
			var content_word := "panjang" if kind == "panjang" else ("berat" if kind == "berat" else "isi")
			prompt = "Setiap %s %d %s. Berapa jumlah %s bagi %d %s?" % [
				item_word, amount, small, content_word, quantity, item_word]
			hint = "Darab bilangan %s dengan %s setiap satu." % [item_word, small]

	var question := {
		"prompt": prompt,
		"expr": expr,
		"visual": {"mode": "none"},
		"hint": hint,
	}
	var deltas := [1, 2, 10, 20] if d == 1 else [10, 20, 50, 100]
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, deltas, 0))


# ----------------------------------------------------------- nilai tempat
static func _make_nilai_tempat(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var max_val: int = [99, 999, 999][d - 1]
	var min_val: int = [20, 100, 100][d - 1]
	var number := rng.randi_range(min_val, max_val)
	var text := str(number)
	var digits := text.length()

	# Pilih digit untuk ditandai. Darah 1: puluh atau sa; d >= 2: semua digit.
	var highlight: int
	if d == 1:
		highlight = rng.randi_range(0, 1)
	else:
		highlight = rng.randi_range(0, digits - 1)

	var digit := int(text.substr(highlight, 1))
	var place: int = 10 ** (digits - 1 - highlight)
	var answer: int = digit * place
	var place_name: String = ["sa", "puluh", "ratus"][digits - 1 - highlight]

	var question := {
		"prompt": "Apakah nilai digit %s dalam %s?" % [digit, number],
		"expr": [],
		"visual": {"mode": "place_value", "number": number, "highlight": highlight},
		"hint": "Digit %s berada pada tempat %s (x %d)." % [digit, place_name, place],
	}
	var deltas := [10, 20, 50] if d == 1 else [10, 20, 50, 100, 200]
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, deltas, 0))


# ---------------------------------------------------------- pola nombor
static func _make_pola_nombor(d: int, rng: RandomNumberGenerator) -> Dictionary:
	var steps := [
		[2, 5, 10],
		[2, 3, 5, 10],
		[3, 4, 6, 7, 8, 9],
	]
	var step: int = steps[d - 1][rng.randi_range(0, steps[d - 1].size() - 1)]
	var start := rng.randi_range(1, 20)
	var seq: Array = []
	for i in 4:
		seq.append(start + step * i)

	var hidden := rng.randi_range(0, 3)
	var answer: int = seq[hidden]

	var question := {
		"prompt": "Nombor manakah yang tertinggal?",
		"expr": [],
		"visual": {"mode": "pattern", "seq": seq, "missing_index": hidden},
		"hint": "Pola tambah %d setiap kali." % step,
	}
	var deltas := [step, step * 2, 5, 10]
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, deltas, 0))


# ----------------------------------------------------------- bundar nombor
static func _make_bundar_nombor(d: int, rng: RandomNumberGenerator) -> Dictionary:
	# Darah 1: bundar kepada puluh (10-99); d=2: bundar kepada puluh (100-999);
	# d=3: bundar kepada ratus (100-999).
	var to_hundred: bool = d == 3
	var min_val: int = 100 if to_hundred else (10 if d == 1 else 100)
	var max_val: int = 999
	var number := rng.randi_range(min_val, max_val)

	var unit: int = 100 if to_hundred else 10
	var low := (number / unit) * unit
	var high := low + unit
	var midpoint := low + unit / 2

	var answer: int
	if number < midpoint:
		answer = low
	else:
		answer = high

	var unit_name: String = "ratus" if to_hundred else "puluh"
	var question := {
		"prompt": "Bundarkan %d kepada %s terdekat." % [number, unit_name],
		"expr": [],
		"visual": {
			"mode": "number_line",
			"number": number,
			"low": low,
			"high": high,
			"midpoint": midpoint,
		},
		"hint": "Lihat sama ada nombor di sebelah kiri atau kanan titik tengah.",
	}
	var deltas := [unit, unit * 2, 5, 10] if not to_hundred else [50, 100, 150, 200]
	return _assemble(question, rng, _num_choice(answer),
		_number_distractors(rng, answer, deltas, 0))


# --------------------------------------------------------------- pembantu
## Bina baris operasi dan tambah "= ?" di hujung.
static func _equation(parts: Array) -> Array:
	var tokens: Array = []
	for part in parts:
		tokens.append(part)
	tokens.append(_op("="))
	tokens.append(_unknown())
	return tokens


static func _num(value: int) -> Dictionary:
	return {"t": "num", "v": value}


static func _text(value: String) -> Dictionary:
	return {"t": "text", "v": value}


static func _op(symbol: String) -> Dictionary:
	return {"t": "op", "v": symbol}


static func _unknown() -> Dictionary:
	return {"t": "unknown"}


static func _unknown_glyph() -> Dictionary:
	return {"t": "unknown_glyph"}


static func _num_choice(value: int) -> Dictionary:
	return {"type": "num", "value": value}


static func _text_choice(value: String) -> Dictionary:
	return {"type": "text", "value": value}


static func _glyph(sign: String) -> Dictionary:
	return {"type": "glyph", "value": sign}


static func _groups_visual(sprite: String, groups: Array) -> Dictionary:
	var list: Array = []
	for group in groups:
		list.append({"count": int(group[0]), "dim": bool(group[1])})
	return {"mode": "groups", "sprite": sprite, "groups": list}


static func _random_object(rng: RandomNumberGenerator) -> String:
	return "res://assets/objects/%s.png" % OBJECT_POOL[rng.randi_range(0, OBJECT_POOL.size() - 1)]


## Susun jawapan betul + pengganggu secara rawak.
static func _assemble(base: Dictionary, rng: RandomNumberGenerator,
		correct: Dictionary, others: Array) -> Dictionary:
	var list: Array = [correct]
	for item in others:
		list.append(item)

	var correct_pos := 0
	for i in range(list.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = list[i]
		list[i] = list[j]
		list[j] = tmp
		if correct_pos == i:
			correct_pos = j
		elif correct_pos == j:
			correct_pos = i

	base["choices"] = list
	base["answer_index"] = correct_pos
	base["answer_token"] = correct
	return base


## Pengganggu nombor yang munasabah (beza kecil + salah tempat digit).
static func _number_distractors(rng: RandomNumberGenerator, answer: int,
		deltas: Array, minimum: int = 0) -> Array:
	var candidates: Array = []
	var shuffled: Array = deltas.duplicate()
	for i in range(shuffled.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = tmp

	for delta in shuffled:
		candidates.append(answer + int(delta))
		candidates.append(answer - int(delta))
	candidates.append(answer + 1)
	candidates.append(answer - 1)
	candidates.append(answer + 2)
	candidates.append(answer - 2)

	var chosen: Array = []
	for value in candidates:
		var v := int(value)
		if v == answer or v < minimum or chosen.has(v):
			continue
		chosen.append(v)
		if chosen.size() >= 2:
			break

	var extra := answer + 3
	while chosen.size() < 2:
		if extra != answer and not chosen.has(extra):
			chosen.append(extra)
		extra += 1

	var choices: Array = []
	for v in chosen:
		choices.append(_num_choice(v))
	return choices


## Pengganggu untuk soalan wang (beza sen).
static func _money_distractors(rng: RandomNumberGenerator, answer_sen: int) -> Array:
	var deltas := [10, 20, 50, 100, 5]
	var shuffled: Array = deltas.duplicate()
	for i in range(shuffled.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = tmp

	var chosen: Array = []
	for delta in shuffled:
		for candidate in [answer_sen + int(delta), answer_sen - int(delta)]:
			var v := int(candidate)
			if v <= 0 or v == answer_sen or chosen.has(v):
				continue
			chosen.append(v)
			if chosen.size() >= 2:
				break
		if chosen.size() >= 2:
			break

	var choices: Array = []
	for v in chosen:
		choices.append(_text_choice(_ringgit(v)))
	return choices


## Format sen kepada teks ringgit Malaysia: 470 -> "RM4.70".
static func _ringgit(sen: int) -> String:
	var ringgit := floori(float(sen) / 100.0)
	var cents := sen - ringgit * 100
	return "RM%d.%02d" % [ringgit, absi(cents)]
