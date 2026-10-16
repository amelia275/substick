<?php

namespace Database\Seeders;

use App\Models\Bookmark;
use App\Models\Comment;
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
        $user = User::firstOrCreate(
            ['email' => 'amelia@example.com'],
            [
                'name' => 'Amelia Masayu',
                'username' => 'ameliamasayu',
                'password' => Hash::make('password123'),
                'bio' => 'Belajar teknologi dan berbagi cerita.',
                'avatar_url' => null,
            ]
        );

        $publication = Publication::firstOrCreate(
            ['slug' => 'ruang-amelia'],
            [
                'owner_id' => $user->id,
                'name' => 'Ruang Amelia',
                'description' => 'Tempat berbagi cerita dan pemikiran.',
                'logo_url' => null,
            ]
        );

        $post = Post::firstOrCreate(
            [
                'user_id' => $user->id,
                'title' => 'Belajar Teknologi dari Hal Sederhana',
            ],
            [
                'publication_id' => $publication->id,
                'type' => 'article',
                'content' => 'Teknologi bisa dipelajari sedikit demi sedikit. Mulailah dari rasa ingin tahu, lalu kembangkan pemahaman melalui praktik.',
                'status' => 'published',
                'published_at' => now(),
            ]
        );

        $comment = Comment::firstOrCreate(
            [
                'post_id' => $post->id,
                'user_id' => $user->id,
                'content' => 'Semangat belajar dan terus mencoba hal baru!',
            ],
            ['parent_comment_id' => null]
        );

        PostLike::firstOrCreate([
            'user_id' => $user->id,
            'post_id' => $post->id,
        ]);

        PostRestack::firstOrCreate([
            'user_id' => $user->id,
            'post_id' => $post->id,
        ]);

        Bookmark::firstOrCreate([
            'user_id' => $user->id,
            'post_id' => $post->id,
        ]);

        $user->joinedPublications()->syncWithoutDetaching([
            $publication->id,
        ]);

        \Illuminate\Support\Facades\DB::table('notifications')->insertOrIgnore([
            [
                'recipient_id' => $user->id,
                'actor_id' => $user->id,
                'post_id' => $post->id,
                'comment_id' => $comment->id,
                'type' => 'comment',
                'message' => 'Ada komentar baru pada postinganmu.',
                'is_read' => false,
                'created_at' => now(),
            ],
        ]);
    }
}
