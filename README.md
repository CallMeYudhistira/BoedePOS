# BoedePOS - Sistem Point of Sale (Kasir)

BoedePOS adalah solusi Point of Sale (POS) mobile-first yang dirancang untuk efisiensi manajemen warung atau toko retail kecil. Proyek ini terdiri dari aplikasi mobile Flutter yang elegan dan API backend Go yang tangguh.

## 🚀 Fitur Utama

### 📱 Mobile App (Flutter)
- **Beranda (Dashboard):** Ringkasan pendapatan, jumlah transaksi, dan produk terjual secara real-time.
- **Transaksi (POS):** Antarmuka penjualan yang cepat dengan sistem keranjang belanja.
  - Mendukung **Produk Standar** (harga tetap).
  - Mendukung **Produk Pecahan** (harga kustom/variabel).
- **Riwayat Transaksi:** Pencarian riwayat penjualan berdasarkan tanggal dan rincian struk belanja.
- **Manajemen Produk:** CRUD data produk lengkap dengan identitas ID dan label jenis produk.
- **Monitoring Harga:** Pantau kenaikan atau penurunan harga produk dengan grafik tren sederhana.
- **Laporan Penjualan:** Statistik pendapatan harian, mingguan, bulanan, hingga tahunan.

### ⚙️ Backend API (Go)
- **Arsitektur Bersih:** Pemisahan layer handler, repository, dan model.
- **Database Terpusat:** Menggunakan PostgreSQL untuk penyimpanan data yang aman.
- **Migrasi Database:** Manajemen skema database otomatis.
- **Docker Ready:** Mudah dijalankan di lingkungan produksi menggunakan Docker Compose.

## 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
| --- | --- |
| **Aplikasi Mobile** | Flutter, Provider, HTTP |
| **Backend API** | Go (Golang), Gin Gonic, GORM |
| **Database** | PostgreSQL |
| **DevOps** | Docker, Docker Compose |

## 📁 Struktur Proyek

```
BoedePOS/
├── client/             # Flutter Mobile Application
│   ├── lib/
│   │   ├── core/       # Constants, API Client, Navigation
│   │   ├── models/     # Data Models
│   │   ├── providers/  # State Management (Provider)
│   │   └── ui/         # Screens & Widgets
├── server/             # Go Backend API
│   ├── config/         # App & DB Config
│   ├── database/       # Migrations & Migrator
│   ├── handler/        # API Request Handlers
│   ├── model/          # Database Models
│   ├── repository/     # Database Queries
│   └── router/         # API Route Definitions
```

## 🏁 Memulai

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Go (Golang)](https://go.dev/doc/install)
- [Docker](https://docs.docker.com/get-started/)

### Setup Backend (Server)
1. Masuk ke direktori server: `cd server`
2. Salin file environment: `cp .env.example .env` (Sesuaikan konfigurasi DB)
3. Jalankan menggunakan Docker:
   ```bash
   docker compose up -d --build
   ```
   Atau jalankan secara manual:
   ```bash
   go run main.go
   ```

### Setup Frontend (Mobile)
1. Masuk ke direktori client: `cd client`
2. Instal dependensi: `flutter pub get`
3. Konfigurasi API: Ubah `baseUrl` di `lib/core/constants.dart` ke alamat IP server Anda.
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## 📦 Build Produksi (Android)
Untuk menghasilkan file APK rilis:
```bash
cd client
flutter build apk --release
```
File akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

---
*Dibuat dengan ❤️ untuk kemajuan UMKM Indonesia.*
