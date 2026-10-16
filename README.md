# \# Substack Clone

# 

# Proyek clone aplikasi Substack menggunakan \*\*Flutter (Dart)\*\* untuk frontend, \*\*Laravel 13\*\* untuk backend API, dan \*\*MySQL\*\* sebagai database.

# 

# \## Teknologi yang Digunakan

# 

# \- Flutter \& Dart

# \- Laravel 13

# \- MySQL

# \- Laragon

# \- HeidiSQL

# \- REST API

# 

# \## Struktur Proyek

# 

# ```text

# substack-clone/

# ├── substack\_app/    # Flutter application

# ├── substack\_api/    # Laravel REST API

# └── README.md

# ```

# 

# \## Prasyarat

# 

# Pastikan perangkat sudah memiliki:

# 

# \- Git

# \- Flutter SDK dan Android Studio

# \- PHP dan Composer

# \- Laragon dengan MySQL

# \- HeidiSQL

# 

# \## 1. Clone Repository

# 

# Clone repository GitHub, kemudian masuk ke folder proyek.

# 

# ```bash

# git clone <URL\_REPOSITORY>

# cd substack-clone

# ```

# 

# Ganti `<URL\_REPOSITORY>` dengan URL repository GitHub kelompok.

# 

# \## 2. Menyiapkan Backend Laravel

# 

# Masuk ke folder backend:

# 

# ```bash

# cd substack\_api

# ```

# 

# Install dependency Laravel:

# 

# ```bash

# composer install

# ```

# 

# Salin file konfigurasi environment:

# 

# \*\*Windows (Command Prompt):\*\*

# 

# ```cmd

# copy .env.example .env

# ```

# 

# Buat application key:

# 

# ```bash

# php artisan key:generate

# ```

# 

# \## 3. Menyiapkan Database MySQL

# 

# 1\. Jalankan Laragon dan aktifkan MySQL.

# 2\. Buka HeidiSQL melalui Laragon.

# 3\. Buat database baru dengan nama `substack\_clone`.

# 4\. Buka file `.env` di folder `substack\_api`.

# 5\. Sesuaikan konfigurasi database:

# 

# ```env

# DB\_CONNECTION=mysql

# DB\_HOST=127.0.0.1

# DB\_PORT=3306

# DB\_DATABASE=substack\_clone

# DB\_USERNAME=root

# DB\_PASSWORD=

# ```

# 

# Konfigurasi di atas menggunakan pengaturan default Laragon. Jika konfigurasi MySQL perangkat berbeda, sesuaikan nilainya.

# 

# \*\*Penting:\*\* Database harus masih kosong. Jangan membuat tabel secara manual karena tabel akan dibuat melalui migration Laravel.

# 

# Jalankan migration dan seeder:

# 

# ```bash

# php artisan migrate --seed

# ```

# 

# Perintah tersebut akan membuat tabel sesuai migration dan mengisi data awal melalui seeder.

# 

# Jika berhasil, lanjutkan ke langkah berikutnya.

# 

# \## 4. Menjalankan Backend

# 

# Pastikan terminal berada di folder `substack\_api`, lalu jalankan:

# 

# ```bash

# php artisan serve

# ```

# 

# Secara default, Laravel berjalan di:

# 

# ```text

# http://127.0.0.1:8000

# ```

# 

# Untuk mengecek endpoint daftar postingan, buka:

# 

# ```text

# http://127.0.0.1:8000/api/posts

# ```

# 

# Jika berhasil, endpoint akan mengembalikan

