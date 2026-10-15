# Rancangan API

| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/api/posts?type=note` | Feed Notes |
| GET | `/api/posts?type=article` | Daftar artikel |
| GET | `/api/posts/{id}` | Detail konten |
| GET | `/api/posts/{id}/comments` | Daftar komentar |
| POST | `/api/posts/{id}/comments` | Tambah komentar |
| POST | `/api/posts/{id}/like` | Toggle like |
| POST | `/api/posts/{id}/restack` | Toggle restack |
| POST | `/api/posts/{id}/bookmark` | Toggle bookmark |
| GET | `/api/bookmarks` | Daftar tersimpan |
| GET | `/api/search?q=kata` | Pencarian |
| GET | `/api/users/{id}` | Profil |
| GET | `/api/users/{id}/posts` | Postingan pengguna |
| GET | `/api/podcasts` | Daftar podcast |
| GET | `/api/podcasts/{id}/episodes` | Daftar episode |
| GET | `/api/notifications` | Aktivitas |
| GET | `/api/conversations` | Daftar obrolan |
| GET | `/api/conversations/{id}/messages` | Daftar pesan |
| POST | `/api/conversations/{id}/messages` | Kirim pesan |

Endpoint selain yang terdaftar pada `routes/api.php` masih berupa rancangan dan perlu diimplementasikan.
