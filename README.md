# 💍 TemanNikah - Aplikasi Persiapan & Manajemen Pernikahan

**TemanNikah** adalah aplikasi mobile & web modern berbasis **Flutter** yang dirancang khusus untuk membantu calon pengantin dan keluarga mengelola seluruh rangkaian persiapan pernikahan secara terstruktur, rapi, dan elegan.

---

## ✨ Fitur Utama

1. **⏱️ Dashboard & Live Countdown Timer**
   - Hitung mundur hari, jam, dan menit menuju Hari H pernikahan.
   - Nama kedua mempelai, lokasi acara, dan tanggal pernikahan yang dapat diubah kapan saja.
   - 4 Kartu Metrik Cepat (Persentase Checklist, Total Tamu Hadir, Mitra Vendor Aktif, Sisa Anggaran).
   - Akses cepat ke checklist terdekat dan susunan acara hari H.

2. **✅ Checklist & Timeline Persiapan (To-Do)**
   - Terbagi otomatis berdasarkan timeline persiapan pernikahan standar Indonesia:
     - `H-12 Bulan` (Konsep, budget awal, booking venue utama)
     - `H-6 Bulan` (Food tasting katering, foto/video prewedding, MUA & desainer)
     - `H-3 Bulan` (Administrasi KUA / Catatan Sipil, cincin kawin, cetak undangan)
     - `H-1 Bulan` (Final fitting busana, kirim undangan, pelunasan vendor, rundown)
     - `H-1 Minggu` (Technical meeting, gladi resik, cek mahar & seserahan)
     - `Hari H` (Koordinasi dengan WO dan panitia)
   - Filter berdasarkan status (`Belum Selesai`, `Selesai`) dan periode waktu.
   - Atur PIC (Penanggung Jawab), tanggal target, serta catatan untuk tiap tugas.

3. **💰 Anggaran & Pengeluaran (Budget Tracker)**
   - Manajemen Total Anggaran Pernikahan.
   - Tracking biaya per kategori: *Venue & Dekorasi, Katering, Busana & MUA, Foto & Video, Undangan & Souvenir, Mahar & Seserahan, dll.*
   - Perbandingan antara **Estimasi Biaya**, **Biaya Riil Kesepakatan**, dan **Nominal Terbayar**.
   - Indikator Status Pembayaran: `Belum Bayar`, `DP (Down Payment)`, atau `Lunas`.
   - Otomatis menghitung sisa tagihan per pos pengeluaran dan sisa saldo anggaran total.

4. **💌 Buku Tamu & RSVP (Guest List)**
   - Pencatatan tamu per kategori (*Keluarga Pria, Keluarga Wanita, Teman Pria, Teman Wanita, Rekan Kerja, VIP, Tetangga*).
   - Catatan jumlah pax (misal: +1 pasangan/keluarga).
   - Pelacak status pengiriman undangan (Undangan Fisik / Digital).
   - Status RSVP Kehadiran: `Akan Hadir`, `Tidak Hadir`, `Belum Pasti (Tentative)`, `Pending`.
   - Penomoran meja (*Table Seating*) dan nomor kontak WhatsApp.
   - Fitur pencarian instan nama tamu dan filter status.

5. **🏢 Manajemen Mitra Vendor**
   - Direktori vendor: *Venue, Katering, Dekorasi, MUA & Busana, Dokumentasi Foto/Video, WO / Planner, Musik & MC, Souvenir, dll.*
   - Catatan nama kontak PIC, nomor WhatsApp/Telepon, akun Instagram, dan harga paket.
   - Status pengerjaan / kontrak: `Riset`, `Diskusi`, `Booking (DP)`, `Lunas`.

6. **📜 Susunan Acara (Rundown Hari H)**
   - Timeline jadwal detail acara dari pagi hingga selesai (Waktu, Nama Kegiatan, Lokasi, PIC, dan Catatan Perlengkapan).
   - Filter kategori acara: `Akad Nikah / Pemberkatan`, `Resepsi`, `Pra-Nikah (Lamaran / Pengajian / Siraman)`.

7. **💾 Penyimpanan Otomatis (Local Storage)**
   - Seluruh data tersimpan secara otomatis di perangkat lokal menggunakan `SharedPreferences`. Data tidak akan hilang saat aplikasi ditutup.
   - Dilengkapi dengan opsi **Reset ke Data Template** di menu pengaturan untuk mencoba kembali data contoh.

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                       # Entry point aplikasi & konfigurasi Provider
├── theme/
│   └── app_theme.dart              # Tema warna elegan (Rose Gold, Champagne, Slate)
├── models/
│   ├── wedding_info.dart           # Model data mempelai, tanggal & budget
│   ├── checklist_item.dart         # Model to-do list & timeline
│   ├── expense_item.dart           # Model pengeluaran & status pembayaran
│   ├── guest_item.dart             # Model tamu & status RSVP
│   ├── vendor_item.dart            # Model mitra vendor
│   └── rundown_item.dart           # Model rundown susunan acara
├── providers/
│   └── wedding_provider.dart       # State management & persistensi data lokal
├── utils/
│   ├── default_data.dart           # Data template pernikahan Indonesia
│   └── formatters.dart             # Format mata uang Rupiah & tanggal lokal
├── widgets/
│   ├── countdown_widget.dart       # Widget countdown hari, jam, menit
│   ├── budget_summary_card.dart    # Kartu ringkasan anggaran interaktif
│   ├── section_header.dart         # Komponen header bagian
│   └── wedding_edit_dialog.dart    # Dialog ubah nama mempelai, tanggal, budget
└── screens/
    ├── main_navigation_screen.dart # Bottom Navigation Bar 5 menu utama
    ├── dashboard_screen.dart       # Halaman ringkasan / beranda
    ├── checklist_screen.dart       # Halaman checklist persiapan
    ├── budget_screen.dart          # Halaman pencatatan anggaran
    ├── guest_screen.dart           # Halaman buku tamu & RSVP
    ├── vendor_screen.dart          # Halaman direktori vendor
    └── rundown_screen.dart         # Halaman susunan acara (rundown)
```

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Prasyarat
Pastikan Flutter SDK telah terpasang di komputer Anda. Jika belum terpasang:
- Kunjungi dokumentasi resmi: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Atau via Homebrew di macOS:
  ```bash
  brew install --cask flutter
  ```

### 2. Pasang Dependencies
Masuk ke direktori proyek dan unduh package yang dibutuhkan:
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
Anda dapat menjalankan aplikasi di berbagai target platform:

- **Di Web Browser (Google Chrome)**:
  ```bash
  flutter run -d chrome
  ```

- **Di Simulator iOS (macOS)**:
  ```bash
  open -a Simulator
  flutter run -d iOS
  ```

- **Di Emulator Android**:
  ```bash
  flutter run -d android
  ```

- **Di macOS Desktop**:
  ```bash
  flutter run -d macos
  ```
