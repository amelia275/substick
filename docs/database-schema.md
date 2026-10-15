# Database Schema (rancangan)

1. `users`: id, name, username, email, password, avatar_url, bio, timestamps.
2. `publications`: id, user_id FK, name, description, logo_url, timestamps.
3. `posts`: id, user_id FK, publication_id nullable FK, type (`note`/`article`), title nullable, body, cover_url nullable, published_at nullable, timestamps.
4. `comments`: id, post_id FK, user_id FK, parent_comment_id nullable FK ke comments.id, body, timestamps.
5. `post_likes`: id, user_id FK, post_id FK, created_at; unique(user_id, post_id).
6. `post_restacks`: id, user_id FK, post_id FK, created_at; unique(user_id, post_id).
7. `bookmarks`: id, user_id FK, post_id FK, created_at; unique(user_id, post_id).
8. `podcasts`: id, user_id FK, title, description nullable, cover_url nullable, timestamps.
9. `episodes`: id, podcast_id FK, title, description nullable, audio_url, duration_seconds, published_at nullable, timestamps.
10. `notifications`: id, user_id FK penerima, actor_id nullable FK users, type, post_id nullable FK, comment_id nullable FK, is_read, created_at.
11. `conversations`: id, timestamps.
12. `conversation_participants`: id, conversation_id FK, user_id FK, joined_at; unique(conversation_id, user_id).
13. `messages`: id, conversation_id FK, sender_id FK users, body, timestamps.

Gunakan foreign key, indeks untuk kolom relasi, dan hash password. Media disimpan di storage; database hanya menyimpan path/URL.
