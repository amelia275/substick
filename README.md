# Substack Clone — Struktur Project

Template struktur folder untuk project UTS menggunakan Flutter (frontend), Laravel REST API (backend), dan MySQL.

## Isi
- `substack_app/`: struktur awal frontend Flutter.
- `substack_api/`: kerangka struktur backend Laravel.
- `docs/`: dokumentasi tim.

## Penting
ZIP ini adalah scaffold struktur beserta beberapa contoh file, bukan aplikasi yang langsung siap dijalankan. Flutter dan Laravel tetap perlu dibuat/diinstal dengan CLI resminya, lalu file-file ini digabungkan ke project tersebut. Beberapa file masih berupa TODO dan migration belum diimplementasikan.

## Setup
1. Buat Flutter project dengan `flutter create substack_app`.
2. Buat Laravel project dengan `composer create-project laravel/laravel substack_api`.
3. Siapkan database MySQL dan konfigurasi `.env`.
4. Implementasikan migration dan endpoint sesuai `docs/`.
5. Jalankan `php artisan storage:link` untuk media publik.
6. Sesuaikan base URL API dengan emulator/perangkat.
