# DiViLab Mobile App (Flutter)

Pembaruan aplikasi DiViLab (pemantau kesehatan) menggunakan Flutter, dikerjakan sebagai Online Technical Test Intern Mobile Developer. Tampilan mengikuti mockup yang diberikan. Pengukuran hanya simulasi, tanpa alat nyata.

## Fitur
- Splash screen dan onboarding 5 slide
- Registrasi 2 langkah (data tersimpan di SQLite, password di-hash SHA-256)
- Login dan Logout (akun lokal di SQLite)
- Dashboard: profil, kartu perangkat, hasil pengukuran terakhir, bottom sheet "Tambah pengukuran"
- Pengukuran simulasi Gula Darah (disertai dialog hitung mundur strip) dan Tekanan Darah (sistolik, diastolik, nadi)
- Laporan dan riwayat 7 hari per jenis pengukuran, dengan hapus data
- List User External: data diambil dari API eksternal (menu Pengaturan)
- Download laporan dalam bentuk PDF (tombol "Download" di Laporan)

## Teknologi
Flutter, `sqflite` (SQLite), `http`, `crypto`, `pdf` dan `printing`. State memakai `setState` dan Navigator.

## Cara menjalankan
Prasyarat: Flutter SDK dan satu Android Emulator (AVD).

```bash
git clone https://github.com/alferd06/divilab_app
cd divilab_app
flutter pub get
flutter emulators --launch <id_avd>
flutter run
```

Koneksi internet dibutuhkan untuk halaman List User External.
Aplikasi dikembangkan di Windows dan diuji di Android Emulator. Belum diuji di iOS Simulator (butuh macOS).

## Alur demo
1. Splash, lalu Onboarding, lalu Login. Tekan "Registrasi".
2. Buat akun (password minimal 10 karakter dengan huruf besar, huruf kecil, dan simbol), lalu isi data personal.
3. Login. Dashboard terbuka.
4. Tekan "Ukur Sekarang", lalu "Hubungkan Bluetooth" (simulasi). Gula Darah terukur otomatis dan dialog hitung mundur muncul.
5. Pindah ke tab "Tekanan Darah", lalu tekan "Mulai Pengukuran".
6. Kembali ke Dashboard: nilai terakhir tampil. Buka tab Laporan untuk riwayat 7 hari.
7. Pengaturan, lalu "List User External" untuk data dari API.

## Data dan API
- Database lokal SQLite (`divilab.db`): tabel `users` dan `measurements`.
- API eksternal: `GET https://dummyjson.com/users`.

## Struktur folder
```
lib/
  data/      database_helper, user_repository, measurement_repository
  models/    external_user
  screens/   splash, onboarding, login, registration, home_shell, dashboard,
             connect_device, measurement, reports, history, settings,
             external_user_page
  services/  session, user_api, report_pdf
  theme/     app_theme
  widgets/   logo, language_chip, labeled_field, dan lainnya
```

## Asumsi dan batasan
- Login memakai akun lokal di SQLite, bukan API auth.
- Ambang status: Gula Darah <70 Rendah, 70-140 Normal, >140 Tinggi. Tekanan Darah (sistolik) <90 Rendah, 90-139 Normal, >=140 Tinggi.
- Nilai pengukuran acak (simulasi). Bluetooth hanya simulasi.
- Hanya Gula Darah dan Tekanan Darah yang disimulasikan. Kolesterol dan Asam Urat menampilkan "Belum ada data".
- Halaman Produk berupa placeholder "Segera hadir" (tidak ada mockup).
- Tidak diimplementasikan: Pengukuran Manual, tab Prediksi, ganti bahasa, Lupa Password, pemindaian kamera Kode Produksi.
- Sesi login hanya di memori (tanpa auto-login).