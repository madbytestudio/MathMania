# Idea Topik Baharu — MathMania

Senarai cadangan topik untuk ditambah pada masa hadapan. Simpan fail ini sebagai
rujukan; kemas kini lajur **Status** apabila sesuatu topik sudah dilaksanakan.

Status semasa: **17 topik** dalam `QuestionBank.TOPICS` (kod).
**Nilai Tempat**, **Pola Nombor**, **Bundar Nombor**, **Operasi Bergabung**, **Pengurusan Data** dan **Tambah Berulang** — siap visual dan dipasang code.

## Topik KSSR yang belum ada

| Topik | Kandungan | Visual / interaksi | Usaha | Status |
|---|---|---|---|---|
| **Bundar Nombor** | Bundar kepada puluh dan ratus terdekat | Garis nombor dengan titik tengah | Mudah | ✅ Selesai |
| **Operasi Bergabung** | `12 + 8 − 5`, `30 − 10 + 4` | Guna paparan operasi sedia ada | Mudah | ✅ Selesai |
| **Tambah Berulang** | `4 + 4 + 4 = 12` → asas darab | Kumpulan gambar (dah ada) | Mudah | ✅ Selesai |
| **Pengurusan Data** | Baca piktograf, kira dan banding data | Carta piktograf baru | Sederhana | ✅ Selesai |
| **Hari, Minggu & Bulan** | Nama hari, bulan, bilangan hari | Kalendar interaktif | Sederhana | ⬜ Belum |
| **Alat Ukur** | Baca pembaris, neraca, silinder penyukat | Lukisan pembaris/skala baru | Sederhana | ⬜ Belum |
| **Wang Interaktif** | Pilih syiling/nota untuk capai jumlah | Seret & lepas syiling | Sederhana–susah | ⬜ Belum |
| **Simetri** | Kenal paksi simetri bentuk | Garis lipat pada bentuk | Sederhana | ⬜ Belum |

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

Kalau nak tambah 3–5 topik sahaja seterusnya:

1. **Hari & Bulan** — pelengkap kepada topik Masa & Waktu.
2. **Cabaran Campuran** — guna semula semua penjana soalan sedia ada.
3. **Cabaran Masa** — 60 saat, soalan rawak semua topik.
4. **Alat Ukur** — baca pembaris/skala, satu bidang KSSR yang belum ada.
5. **Wang Interaktif** — seret & lepas syiling untuk capai jumlah.

## Nota pelaksanaan

- Setiap topik baharu perlu didaftarkan dalam `QuestionBank.TOPICS` (id, name,
  short, desc, syllabus, icon, color) dan ditambah dalam `make_question()`.
- Jika soalan tidak guna `expr`, tambah metadata `check` supaya ujian automatik
  dapat mengesahkan jawapan.
- Visual baharu dilukis dengan kod dalam `scripts/` dan didaftarkan dalam
  `game.gd` (`_build_visual`).
- Kemas kini `tests/test_runner.gd`, `tests/run_tests.gd` (jumlah topik) dan
  `tests/screenshot.gd` (tangkapan skrin topik baharu).
- Topik ke-17 disusun oleh `HFlowContainer` dalam `topic_select.gd` (lajur bervariat).
