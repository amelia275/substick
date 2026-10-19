<?php

namespace Database\Seeders;

use App\Models\Bookmark;
use App\Models\Comment;
use App\Models\Notification;
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
    }
}
