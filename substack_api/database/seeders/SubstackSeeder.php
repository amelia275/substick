<?php

namespace Database\Seeders;

use App\Models\Bookmark;
use App\Models\Comment;
use App\Models\Episode;
use App\Models\Notification;
use App\Models\Podcast;
use App\Models\Post;
use App\Models\PostLike;
use App\Models\PostRestack;
use App\Models\Publication;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SubstackSeeder extends Seeder
{
    public function run(): void
    {
        // User utama
        $amelia = User::firstOrCreate(
            ['email' => 'amelia@example.com'],
            [
                'name' => 'Amelia Masayu',
                'username' => 'ameliamasayu',
                'password' => Hash::make('password123'),
                'bio' => 'Belajar teknologi dan berbagi cerita.',
                'avatar_url' => null,
            ]
        );

        // User tambahan
        $usersData = [
            [
                'email' => 'arwa@example.com',
                'name' => 'Arwa',
                'username' => 'arwa',
                'bio' => 'Writing about life and people.',
                'publication' => 'Unheard Things in Closed Rooms',
                'slug' => 'unheard-things',
            ],
            [
                'email' => 'nanash@example.com',
                'name' => 'Nanash',
                'username' => 'nanash',
                'bio' => 'Catatan kecil tentang kehidupan.',
                'publication' => 'Little Things',
                'slug' => 'little-things',
            ],
            [
                'email' => 'claire@example.com',
                'name' => 'Claire',
                'username' => 'claire',
                'bio' => 'Letters, thoughts, and stories.',
                'publication' => 'Letters for You',
                'slug' => 'letters-for-you',
            ],
        ];

        $users = [];

        foreach ($usersData as $data) {
            $user = User::firstOrCreate(
                ['email' => $data['email']],
                [
                    'name' => $data['name'],
                    'username' => $data['username'],
                    'password' => Hash::make('password123'),
                    'bio' => $data['bio'],
                    'avatar_url' => null,
                ]
            );

            $publication = Publication::firstOrCreate(
                ['slug' => $data['slug']],
                [
                    'owner_id' => $user->id,
                    'name' => $data['publication'],
                    'description' => $data['bio'],
                    'logo_url' => null,
                ]
            );

            $user->joinedPublications()->syncWithoutDetaching([
                $publication->id,
            ]);

            $users[$data['username']] = [
                'user' => $user,
                'publication' => $publication,
            ];
        }

        // Publication Amelia
        $ameliaPublication = Publication::firstOrCreate(
            ['slug' => 'ruang-amelia'],
            [
                'owner_id' => $amelia->id,
                'name' => 'Ruang Amelia',
                'description' => 'Tempat berbagi cerita dan pemikiran.',
                'logo_url' => null,
            ]
        );

        $amelia->joinedPublications()->syncWithoutDetaching([
            $ameliaPublication->id,
        ]);

        // Post artikel Amelia yang sudah ada
        $mainPost = Post::firstOrCreate(
            [
                'user_id' => $amelia->id,
                'title' => 'Belajar Teknologi dari Hal Sederhana',
            ],
            [
                'publication_id' => $ameliaPublication->id,
                'type' => 'article',
                'content' => 'Teknologi bisa dipelajari sedikit demi sedikit. Mulailah dari rasa ingin tahu, lalu kembangkan pemahaman melalui praktik.',
                'status' => 'published',
                'published_at' => now()->subDays(2),
            ]
        );

        // Post tambahan: teks, quote, dan artikel
        $postsData = [
            [
                'author' => 'nanash',
                'title' => 'Tentang Kehilangan Spark',
                'type' => 'note',
                'content' => 'Kadang kita masih tertawa, bekerja, dan ngobrol seperti biasa. Namun, ada bagian dari diri kita yang perlahan terasa hilang. Mungkin kita hanya perlu waktu untuk menemukannya lagi.',
                'published_at' => now()->subHours(5),
            ],
            [
                'author' => 'arwa',
                'title' => 'Memahami Manusia',
                'type' => 'quote',
                'content' => 'Saya ingin pendidikan membuat saya lebih mampu memahami manusia tanpa buru-buru merendahkannya.',
                'published_at' => now()->subHours(8),
            ],
            [
                'author' => 'claire',
                'title' => 'Letter for You',
                'type' => 'note',
                'content' => 'Untuk kamu yang sedang berusaha melewati hari-hari sulit: tidak apa-apa kalau hari ini kamu hanya mampu melakukan sedikit hal. Itu tetap berarti.',
                'published_at' => now()->subDay(),
            ],
            [
                'author' => 'arwa',
                'title' => 'Belajar Mendengarkan',
                'type' => 'article',
                'content' => 'Mendengarkan bukan sekadar menunggu giliran berbicara. Ada banyak hal yang baru bisa kita pahami ketika kita benar-benar memberi ruang kepada orang lain.',
                'published_at' => now()->subDays(3),
            ],
        ];

        $createdPosts = [];

        foreach ($postsData as $data) {
            $author = $users[$data['author']];

            $post = Post::firstOrCreate(
                [
                    'user_id' => $author['user']->id,
                    'title' => $data['title'],
                ],
                [
                    'publication_id' => $author['publication']->id,
                    'type' => $data['type'],
                    'content' => $data['content'],
                    'status' => 'published',
                    'published_at' => $data['published_at'],
                ]
            );

            $createdPosts[$data['title']] = $post;
        }

        // Contoh komentar
        $comment = Comment::firstOrCreate(
            [
                'post_id' => $mainPost->id,
                'user_id' => $users['arwa']['user']->id,
                'content' => 'Semangat belajar dan terus mencoba hal baru!',
            ],
            ['parent_comment_id' => null]
        );

        // Contoh interaksi pada post
        PostLike::firstOrCreate([
            'user_id' => $users['nanash']['user']->id,
            'post_id' => $mainPost->id,
        ]);

        Bookmark::firstOrCreate([
            'user_id' => $amelia->id,
            'post_id' => $createdPosts['Memahami Manusia']->id,
        ]);

        // Amelia merestack post milik Arwa
        PostRestack::firstOrCreate([
            'user_id' => $amelia->id,
            'post_id' => $createdPosts['Memahami Manusia']->id,
        ]);

        // Contoh notifikasi untuk halaman Activity
        Notification::firstOrCreate(
            [
                'recipient_id' => $amelia->id,
                'actor_id' => $users['nanash']['user']->id,
                'post_id' => $mainPost->id,
                'type' => 'like',
            ],
            [
                'message' => 'liked your note',
                'is_read' => false,
                'created_at' => now()->subDays(30),
            ]
        );

        Notification::firstOrCreate(
            [
                'recipient_id' => $amelia->id,
                'actor_id' => $users['arwa']['user']->id,
                'post_id' => $createdPosts['Memahami Manusia']->id,
                'type' => 'restack',
            ],
            [
                'message' => 'liked your restack',
                'is_read' => false,
                'created_at' => now()->subDays(30),
            ]
        );

        Notification::firstOrCreate(
            [
                'recipient_id' => $amelia->id,
                'actor_id' => $users['claire']['user']->id,
                'type' => 'follow',
            ],
            [
                'message' => 'followed you',
                'is_read' => false,
                'created_at' => now()->subDays(60),
            ]
        );

        Notification::firstOrCreate(
            [
                'recipient_id' => $amelia->id,
                'actor_id' => $users['arwa']['user']->id,
                'post_id' => $mainPost->id,
                'comment_id' => $comment->id,
                'type' => 'comment',
            ],
            [
                'message' => 'replied to your note',
                'is_read' => false,
                'created_at' => now()->subDays(14),
            ]
        );

        // Contoh 2 Podcast & Episode untuk halaman Podcast
        $hackerspotPodcast = Podcast::firstOrCreate(
            [
                'user_id' => $amelia->id,
                'title' => 'Hackerspot Podcast',
            ],
            [
                'publication_id' => $ameliaPublication->id,
                'short_title' => 'Hackerspot',
                'author_name' => $amelia->name,
                'description' => 'A knowledge-sharing platform for those interested in cybersecurity.',
                'cover_url' => 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80',
            ]
        );

        $epChatSecurity = Episode::firstOrCreate(
            [
                'podcast_id' => $hackerspotPodcast->id,
                'title' => 'A Security Analysis of Chat Applications',
            ],
            [
                'subtitle' => 'A security analysis comparison between Signal, WhatsApp and Telegram',
                'caption_snippet' => "And lucky for us, there's this super in-depth security analysis paper we can use as like our guide.",
                'description' => "Choosing the right messaging app is more important than ever. With increasing concerns over how data is handled, many users turn to encrypted messaging platforms to protect their privacy.\n\nAmong the most popular are Signal, WhatsApp and Telegram. Each platform offers its own encryption model, metadata policy, and open-source transparency.",
                'thumbnail_url' => 'https://images.unsplash.com/photo-1611746872915-64382b5c76da?auto=format&fit=crop&w=400&q=80',
                'duration_seconds' => 13 * 60 + 18,
                'is_featured_video' => false,
                'likes_count' => 4,
                'comments_count' => 2,
                'restacks_count' => 1,
                'published_at' => now()->subYear(),
            ]
        );

        $epMetaModeration = Episode::firstOrCreate(
            [
                'podcast_id' => $hackerspotPodcast->id,
                'title' => "Meta's Content Moderation and the Future of Tech",
            ],
            [
                'subtitle' => 'How automated moderation systems and policy shifts shape online discourse.',
                'caption_snippet' => 'When platforms scale to billions of users, automated moderation becomes both essential and controversial.',
                'description' => 'Content moderation at scale requires a delicate balance between safety, free expression, and algorithmic accuracy.',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=400&q=80',
                'duration_seconds' => 21 * 60,
                'is_featured_video' => false,
                'likes_count' => 9,
                'comments_count' => 1,
                'restacks_count' => 2,
                'published_at' => now()->subYear()->subDays(10),
            ]
        );

        $quantumPodcast = Podcast::firstOrCreate(
            [
                'user_id' => $users['arwa']['user']->id,
                'title' => 'Quantum Mind',
            ],
            [
                'publication_id' => $users['arwa']['publication']->id,
                'short_title' => 'Quantum Mind',
                'author_name' => $users['arwa']['user']->name,
                'description' => 'Membahas cara kerja pikiran, memori, dan pembelajaran manusia.',
                'cover_url' => 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=900&q=80',
            ]
        );

        $epQuantumMind = Episode::firstOrCreate(
            [
                'podcast_id' => $quantumPodcast->id,
                'title' => 'Kenapa Otak Anda "Sengaja" Membuang Ilmu yang Sudah Dipelajari',
            ],
            [
                'subtitle' => 'Beberapa waktu lalu saya menulis tentang kenapa Anda sering lupa apa yang baru dibaca...',
                'caption_snippet' => 'Otak manusia dirancang untuk menyaring informasi, bukan menyimpan setiap detail tanpa konteks.',
                'description' => 'Beberapa waktu lalu saya menulis tentang kenapa Anda sering lupa apa yang baru saja dipelajari. Ternyata mekanisme lupa justru bagian penting dari cara kerja memori manusia.',
                'thumbnail_url' => 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=900&q=80',
                'duration_seconds' => 18 * 60,
                'is_featured_video' => true,
                'likes_count' => 24,
                'comments_count' => 2,
                'restacks_count' => 5,
                'published_at' => now()->subDays(30),
            ]
        );

        // Komentar di episode podcast (masuk ke tabel comments, sesuai user di tabel users)
        Comment::firstOrCreate(
            [
                'episode_id' => $epChatSecurity->id,
                'user_id' => $users['nanash']['user']->id,
                'content' => 'Iseng-iseng dengerin dan baca ini karena gabut ehh malah relate banget sama keamanan chat yang kita pakai sehari-hari.',
            ],
            ['post_id' => null, 'parent_comment_id' => null]
        );

        Comment::firstOrCreate(
            [
                'episode_id' => $epChatSecurity->id,
                'user_id' => $users['claire']['user']->id,
                'content' => 'Penjelasan perbandingan enkripsi Signal, WhatsApp, dan Telegram-nya sangat jelas dan mudah dipahami!',
            ],
            ['post_id' => null, 'parent_comment_id' => null]
        );

        Comment::firstOrCreate(
            [
                'episode_id' => $epMetaModeration->id,
                'user_id' => $users['arwa']['user']->id,
                'content' => 'Topik moderasi konten ini menarik banget buat dibahas lebih dalam.',
            ],
            ['post_id' => null, 'parent_comment_id' => null]
        );

        Comment::firstOrCreate(
            [
                'episode_id' => $epQuantumMind->id,
                'user_id' => $amelia->id,
                'content' => 'Pantesan sering lupa kalau belajar cuma hafalan tanpa konteks, penjelasannya mantap!',
            ],
            ['post_id' => null, 'parent_comment_id' => null]
        );
    }
}
