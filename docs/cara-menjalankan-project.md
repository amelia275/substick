# Cara Menjalankan Project

## Flutter
1. Pastikan Flutter SDK tersedia.
2. Jalankan `flutter pub get` di `substack_app/`.
3. Jalankan emulator/perangkat.
4. Sesuaikan `ApiConstants.baseUrl`.
5. Jalankan `flutter run`.

## Laravel
1. Pastikan PHP, Composer, dan MySQL tersedia.
2. Buat project Laravel resmi terlebih dahulu jika menggunakan scaffold ini.
3. Konfigurasikan `.env`.
4. Buat migration, lalu jalankan `php artisan migrate`.
5. Jalankan `php artisan storage:link`.
6. Jalankan `php artisan serve --host=0.0.0.0`.

ZIP ini bukan instalasi framework lengkap; beberapa fitur dan migration masih harus dibuat.
