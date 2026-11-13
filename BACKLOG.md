# Product Backlog

Catatan: soal tidak mencantumkan kriteria penilaian. Prioritas saya turunkan dari daftar "Yang harus anda buat".

| ID | Requirement (kutip asli) | Prioritas | Estimasi | Status |
|---|---|---|---|---|
| R1 | "Application IOS menggunakan Flatter" | Must | ST-01 | Todo |
| R2 | "Running di IOS Emulator" | Must | ST-01 (dicek tiap ST) | Todo |
| R3 | "Database menggunakan SQLite" | Must | ST-01, ST-03 | Todo |
| R4 | "Get API From external (Pada page List user External)" | Must | 25 mnt (ST-02) | Todo |
| R5 | "API pakai API dari google contoh : https://sampleapis.com/ https://dummyjson.com/docs/auth" | Must | ST-02 | Todo |
| R6 | "Registration" | Must | 30 mnt (ST-03) | Todo |
| R7 | "Login" | Must | 15 mnt (ST-04) | Todo |
| R8 | "Dashboard" | Must | 20 mnt (ST-05) | Todo |
| R9 | "Pengukuran" (+ catatan Alwi: "pengukuran hanya simulasi saja, tanpa menggunakan alat nyata") | Must | 40 mnt (ST-06) | Todo |
| R10 | "Splash screen" | Should | 20 mnt (ST-07) | Todo |
| R11 | "Product" | Should | 15 mnt (ST-08) | Todo |
| R12 | "Untuk detail per page ada pada mockup berikut" (dialog strip, Laporan, Tekanan Darah) | Could | 15 + 40 mnt (ST-09, ST-10) | Todo |

# Asumsi
1. List User External: halaman terpisah dari tab Pengaturan, GET https://dummyjson.com/users tanpa auth.
2. Login memvalidasi akun SQLite hasil Registration, bukan dummyjson auth.
3. Product (tanpa mockup): daftar statis 3 produk strip.
4. Hanya Gula Darah yang disimulasikan; Kolesterol, Asam Urat, Tekanan Darah, Manual, dan Laporan masuk Could.
5. Pengumpulan berupa link repo GitHub plus README.
6. Hanya iOS yang dinilai.
7. Status Gula Darah: <70 Rendah, 70-140 Normal, >140 Tinggi.
8. setState + Navigator, session in-memory, password di-hash SHA-256.
9. Onboarding 3 slide; chip bahasa, "Lupa Password?", dan kamera Kode Produksi hanya tampilan.

# Sprint 1 (Must)
| ST | Judul | Requirement |
|---|---|---|
| ST-01 | Skeleton, dependency, SQLite helper, bottom nav | R1, R2, R3 |
| ST-02 | Page List User External (API) | R4, R5 |
| ST-03 | Registration 2 langkah + simpan SQLite | R6, R3 |
| ST-04 | Login + logout | R7 |
| ST-05 | Dashboard | R8 |
| ST-06 | Pengukuran simulasi Gula Darah | R9 |

# Sprint 2 (Should)
| ST | Judul | Requirement |
|---|---|---|
| ST-07 | Splash dan Onboarding | R10 |
| ST-08 | Halaman Product | R11 |

# Could (hanya jika ada sisa waktu)
| ST | Judul | Requirement |
|---|---|---|
| ST-09 | Dialog hitung mundur strip (7 detik) | R12 |
| ST-10 | Laporan + detail Tekanan Darah dari SQLite | R12 |