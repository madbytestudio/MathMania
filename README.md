# MathMania

Game matematik interaktif untuk murid **Darjah 2 (KSSR)**. Dibina dengan **Godot 4.7**
menggunakan GDScript dan gaya grafik CraftPix.

## Ciri

- **11 topik KSSR**: Kira Objek, Tambah, Tolak, Darab, Bahagi, Banding Nombor,
  Wang, Pecahan, Masa & Waktu, Bentuk, dan Ukuran.
- **3 tahap kesukaran** setiap topik (mudah, sederhana, susah).
- **8 soalan** setiap pusingan dengan pilihan jawapan A/B/C.
- **Bintang 1–3** berdasarkan ketepatan jawapan, serta skor bonus untuk jawapan
  betul berturut-turut.
- **Skrin Kemajuan**: jumlah bintang, topik dimainkan, skor tertinggi, rekod
  setiap topik, dan butang **Padam Rekod** (dengan pengesahan).
- **Semakan Jawapan** di skrin keputusan: semua 8 jawapan dipaparkan bersama
  jawapan pilihan murid dan jawapan betul.
- **Muzik latar** berulang dan **kesan bunyi** yang boleh dihidupkan/dimatikan
  dari menu utama. Tetapan disimpan antara sesi.
- Visual matematik yang dilukis dengan kod: bar pecahan, jam analog, bentuk 2D/3D.

## Keperluan

- Godot **4.7** (diuji dengan 4.7.2 stable, renderer *GL Compatibility*).

## Menjalankan

Buka folder projek ini dalam Godot, kemudian tekan **F5**. Atau dari terminal:

```powershell
godot --path .
```

## Kawalan

| Tindakan | Kawalan |
| --- | --- |
| Pilih jawapan / butang | Klik atau sentuh |
| Jawab soalan | Tekan `1`, `2` atau `3` |
| Kembali / tutup modal | `Esc` |

Petunjuk papan kekunci dipaparkan di skrin permainan:
*"Tekan 1 / 2 / 3 untuk menjawab"*.

## Simpanan

Rekod dan tetapan disimpan dalam `user://mathmania_save.cfg`
(Windows: `%APPDATA%\Godot\app_userdata\MathMania\mathmania_save.cfg`).
Rekod disimpan pada peranti ini sahaja.

## Ujian automatik

Ujian penuh (bank soalan + setiap skrin):

```powershell
godot --path . --headless res://tests/test_runner.tscn
```

Ujian pantas bank soalan sahaja:

```powershell
godot --path . --headless --script res://tests/run_tests.gd
```

Kedua-dua arahan mencetak `SEMUA UJIAN LULUS` dan keluar dengan kod 0 jika
semuanya lulus.

## Tangkapan skrin

```powershell
godot --path . res://tests/screenshot.tscn --resolution 1920x1080
```

Imej PNG (01–16) disimpan dalam folder `_shots` di sebelah folder projek
(laluan boleh dipindahkan bersama projek).

## Struktur projek

```
scenes/     main_menu, topic_select, game, result, progress
scripts/    logik permainan, autoload, dan visual tersuai
assets/     grafik, fon, kesan bunyi, muzik
tests/      ujian automatik dan penjana tangkapan skrin
```

Autoload: `GameState` (rekod + tetapan), `Sfx` (kesan bunyi), `Music` (muzik latar).

## Aset

Grafik daripada [CraftPix.net](https://craftpix.net) di bawah lesen penggunaan
bebas — lihat `assets/license_craftpix_*.txt`.

Dua aset baharu dijana secara setempat untuk projek ini:

- `assets/ui/clock.png` — ikon topik Masa & Waktu
- `assets/music/theme.wav` — gelung muzik latar 20 saat (16-bit stereo, 44.1 kHz)
