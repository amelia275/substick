# Substick

Proyek clone aplikasi Substack menggunakan **Flutter (Dart)** untuk frontend, **Laravel 13** untuk backend API, dan **MySQL** sebagai database.

## Teknologi yang Digunakan

- Flutter & Dart
- Laravel 13
- MySQL
- Laragon
- HeidiSQL
- REST API

## Struktur Proyek

```text
substack-clone/
├── substack_app/    # Flutter application
├── substack_api/    # Laravel REST API
└── README.md
```

## Prasyarat

Pastikan perangkat sudah memiliki:

- Git
- Flutter SDK dan Android Studio
- PHP dan Composer
- Laragon dengan MySQL
- HeidiSQL

## 1. Clone Repository

Clone repository GitHub, kemudian masuk ke folder proyek.

```bash
git clone <URL_REPOSITORY>
cd substack-clone
```

Ganti `<URL_REPOSITORY>` dengan URL repository GitHub kelompok.

## 2. Menyiapkan Backend Laravel

Masuk ke folder backend:

```bash
cd substack_api
```

Install dependency Laravel:

```bash
composer install
```

Salin file konfigurasi environment:

**Windows (Command Prompt):**

```cmd
copy .env.example .env
```

Buat application key:

```bash
php artisan key:generate
```

## 3. Menyiapkan Database MySQL

1. Jalankan Laragon dan aktifkan MySQL.
2. Buka HeidiSQL melalui Laragon.
3. Buat database baru dengan nama `substack_clone`.
4. Buka file `.env` di folder `substack_api`.
5. Sesuaikan konfigurasi database:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=substack_clone
DB_USERNAME=root
DB_PASSWORD=
```

Konfigurasi di atas menggunakan pengaturan default Laragon. Jika konfigurasi MySQL perangkat berbeda, sesuaikan nilainya.

**Penting:** Database harus masih kosong. Jangan membuat tabel secara manual karena tabel akan dibuat melalui migration Laravel.

Jalankan migration dan seeder:

```bash
php artisan migrate --seed
```

Perintah tersebut akan membuat tabel sesuai migration dan mengisi data awal melalui seeder.

Jika berhasil, lanjutkan ke langkah berikutnya.

## 4. Menjalankan Backend

Pastikan terminal berada di folder `substack_api`, lalu jalankan:

```bash
php artisan serve
```

Secara default, Laravel berjalan di:

```text
http://127.0.0.1:8000
```

Untuk mengecek endpoint daftar postingan, buka:

```text
http://127.0.0.1:8000/api/posts
```

Jika berhasil, endpoint akan mengembalikan respons JSON berisi postingan yang berstatus published.

Untuk detail postingan:

```text
http://127.0.0.1:8000/api/posts/1
```

## 5. Menyiapkan Flutter

Buka terminal baru dan masuk ke folder aplikasi:

```bash
cd substack_app
```

Ambil dependency:

```bash
flutter pub get
```

Pastikan alamat API pada konfigurasi Flutter sesuai dengan lingkungan yang digunakan.

Untuk Android Emulator, alamat backend lokal biasanya:

```text
http://10.0.2.2:8000/api
```

Untuk menjalankan aplikasi di browser pada komputer yang sama, gunakan alamat backend lokal:

```text
http://127.0.0.1:8000/api
```

Jika menggunakan perangkat fisik, alamat API perlu disesuaikan dengan alamat IP lokal komputer yang menjalankan Laravel, dan kedua perangkat harus berada pada jaringan yang dapat saling mengakses.

Jalankan aplikasi:

```bash
flutter run
```

Pastikan backend Laravel tetap berjalan saat aplikasi membutuhkan API.

## 6. Alur Pengembangan Tim

Agar pengerjaan lebih teratur:

1. Setiap anggota melakukan clone repository dari GitHub.
2. Setiap anggota membuat database lokal bernama `substack_clone`.
3. Struktur tabel dan data awal dibuat menggunakan migration dan seeder.
4. Perubahan kode dikerjakan pada branch masing-masing.
5. Sebelum menggabungkan perubahan, lakukan commit dan push ke GitHub.
6. Jika ada perubahan migration, anggota lain perlu menarik kode terbaru dan menjalankan migration yang diperlukan.

Database setiap anggota berada di perangkat masing-masing. Migration dan seeder menyamakan struktur serta data awal, tetapi perubahan data saat aplikasi digunakan tidak otomatis tersinkronisasi antaranggota.

## 7. Catatan Penting

- Jangan mengunggah file `.env` ke GitHub.
- Jangan mengunggah password atau kredensial database.
- Jangan menjalankan `php artisan migrate:fresh` pada database yang berisi data penting karena perintah tersebut menghapus tabel sebelum membuatnya kembali.
- Gunakan migration untuk perubahan struktur database dan seeder untuk menyiapkan data awal.
- Pastikan konfigurasi database lokal sesuai dengan pengaturan MySQL di perangkat masing-masing.

---

**Substack Clone — Project UTS**
