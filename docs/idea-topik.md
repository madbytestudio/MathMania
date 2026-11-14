# Idea Topik Baharu — MathMania

Senarai cadangan topik untuk ditambah pada masa hadapan. Simpan fail ini sebagai
rujukan; kemas kini lajur **Status** apabila sesuatu topik sudah dilaksanakan.

Status semasa: **11 topik** dalam `QuestionBank.TOPICS` (kod).
**Nilai Tempat** dan **Pola Nombor** — visual (`place_value_view.gd`, `pattern_view.gd`)
sudah siap, masih belum dipasang dalam `question_bank.gd` / `game.gd`.

## Topik KSSR yang belum ada

| Topik | Kandungan | Visual / interaksi | Usaha | Status |
|---|---|---|---|---|
| **Bundar Nombor** | Bundar kepada puluh dan ratus terdekat | Garis nombor dengan titik tengah | Mudah | ⬜ Belum |
| **Operasi Bergabung** | `12 + 8 − 5`, `30 − 10 + 4` | Guna paparan operasi sedia ada | Mudah | ⬜ Belum |
| **Tambah Berulang** | `4 + 4 + 4 = 12` → asas darab | Kumpulan gambar (dah ada) | Mudah | ⬜ Belum |
| **Pengurusan Data** | Baca piktograf, kira dan banding data | Carta piktograf baru | Sederhana | ⬜ Belum |
| **Hari, Minggu & Bulan** | Nama hari, bulan, bilangan hari | Kalendar interaktif | Sederhana | ⬜ Belum |
| **Alat Ukur** | Baca pembaris, neraca, silinder penyukat | Lukisan pembaris/skala baru | Sederhana | ⬜ Belum |
| **Wang Interaktif** | Pilih syiling/nota untuk capai jumlah | Seret & lepas syiling | Sederhana–susah | ⬜ Belum |
| **Simetri** | Kenal paksi simetri bentuk | Garis lipat pada bentuk | Sederhana | ⬜ Belum |

## Antara antara: siap visual, belum dipasang code

| Topik | Kandungan | Visual | Status |
|---|---|---|---|
| **Nilai Tempat & Nilai Digit** | Nombor hingga 1000: ratus, puluh, sa | Blok ratus/puluh/sa, digit ditanda | 🟡 Visual siap, belum dipasang |
| **Pola & Susun Nombor** | Pola menaik/menurun, langkau 2/5/10, susun tertib | Kad nombor, nombor hilang | 🟡 Visual siap, belum dipasang |

## Idea "topik istimewa" (bukan KSSR, tambah variasi)

| Mod | Konsep | Status |
|---|---|---|
| **Cabaran Campuran** | 8 soalan rawak daripada semua topik | ⬜ Belum |
| **Cabaran Masa** | Jawab seberapa banyak dalam 60 saat | ⬜ Belum |
| **Padankan** | Padankan pecahan ↔ gambar, jam ↔ masa, bentuk ↔ nama | ⬜ Belum |
| **Cari yang Salah** | Tiga pilihan, pilih jawapan yang tidak betul | ⬜ Belum |
| **Benar atau Salah** | Tunjuk ayat matematik, pilih ✓/✗ | ⬜ Belum |
| **Urutan** | Susun 4 nombor/kad mengikut tertib | ⬜ Belum |

## Cadangan keutamaan

Kalau nak tambah 3–5 topik sahaja dahulu:

1. **Nilai Tempat** — visual dah siap, hanya perlu daftarkan dalam code.
2. **Pola Nombor** — visual dah siap, hanya perlu daftarkan dalam code.
3. **Bundar Nombor** — ringkas, guna garis nombor.
4. **Operasi Bergabung** — hampir percuma, guna semula paparan operasi.
5. **Pengurusan Data/Piktograf** — satu-satunya bidang KSSR yang belum ada.

## Nota pelaksanaan

- Setiap topik baharu perlu didaftarkan dalam `QuestionBank.TOPICS` (id, name,
  short, desc, syllabus, icon, color) dan ditambah dalam `make_question()`.
- Jika soalan tidak guna `expr`, tambah metadata `check` supaya ujian automatik
  dapat mengesahkan jawapan.
- Visual baharu dilukis dengan kod dalam `scripts/` dan didaftarkan dalam
  `game.gd` (`_build_visual`).
- Kemas kini `tests/test_runner.gd`, `tests/run_tests.gd` (jumlah topik) dan
  `tests/screenshot.gd` (tangkapan skrin topik baharu).
- Topik ke-13 memerlukan susunan grid 5 lajur dalam `topic_select.gd`.
