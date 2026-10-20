<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\Post;
use App\Models\PostRestack;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class UserController extends Controller
{
    public function show(int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        // Query dasar post: lengkap dengan penulis, publikasi, dan jumlah interaksi
        $postQuery = fn () => Post::with(['user', 'publication'])
            ->withCount(['likes', 'comments', 'restacks'])
            ->where('status', 'published');

        $posts = $postQuery()
            ->where('user_id', $id)
            ->orderByDesc('published_at')
            ->orderByDesc('id')
            ->get();

        $likes = $postQuery()
            ->whereHas('likes', fn ($q) => $q->where('user_id', $id))
            ->orderByDesc('published_at')
            ->get();

        $restackTimes = PostRestack::where('user_id', $id)->pluck('created_at', 'post_id');

        $restacked = $postQuery()
            ->whereIn('id', $restackTimes->keys())
            ->get();

        // Tab Activity: postingan sendiri + restack, diurutkan dari yang terbaru
        $activity = $posts
            ->map(fn ($post) => [
                'kind' => 'post',
                'at' => $post->published_at ?? $post->created_at,
                'post' => $post,
            ])
            ->concat($restacked->map(fn ($post) => [
                'kind' => 'restack',
                'at' => $restackTimes[$post->id] ?? $post->created_at,
                'post' => $post,
            ]))
            ->sortByDesc(fn ($item) => Carbon::parse($item['at'])->timestamp)
            ->values();

        $replies = Comment::with('post.user')
            ->where('user_id', $id)
            ->orderByDesc('created_at')
            ->get();

        $subscriptions = $user->joinedPublications()
            ->orderBy('publications.name')
            ->get();

        return response()->json([
            'data' => [
                // Sengaja tidak mengirim email/password
                'user' => $user->only(['id', 'name', 'username', 'avatar_url', 'bio']),
                'posts_count' => $posts->count(),
                'activity' => $activity,
                'posts' => $posts,
                'replies' => $replies,
                'likes' => $likes,
                'subscriptions' => $subscriptions,
            ],
        ]);
    }
}
