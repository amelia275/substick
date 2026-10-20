<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $posts = $this->withInteractions(Post::query(), $request)
            ->with([
                'user:id,name,username,avatar_url',
                'publication:id,name,slug,logo_url',
                'restacks.user:id,name,username',
            ])
            ->where('status', 'published')
            ->orderByDesc('published_at')
            ->orderByDesc('created_at')
            ->paginate(10);

        return response()->json($posts);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $post = $this->withInteractions(Post::query(), $request)
            ->with([
                'user:id,name,username,avatar_url',
                'publication:id,name,slug,logo_url',
                'comments' => fn ($query) => $query
                    ->with('user:id,name,username,avatar_url')
                    ->oldest(),
                'restacks.user:id,name,username',
            ])
            ->where('status', 'published')
            ->findOrFail($id);

        return response()->json(['data' => $post]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'content' => ['required', 'string', 'max:2000'],
        ], [
            'content.required' => 'Catatan tidak boleh kosong.',
            'content.max' => 'Catatan maksimal 2000 karakter.',
        ]);

        $post = Post::create([
            'user_id' => $request->user()->id,
            'type' => 'note',
            'content' => $data['content'],
            'status' => 'published',
            'published_at' => now(),
        ]);

        $post->load([
            'user:id,name,username,avatar_url',
            'publication:id,name,slug,logo_url',
            'restacks.user:id,name,username',
        ])->loadCount(['likes', 'comments', 'restacks']);

        return response()->json(['data' => $post], 201);
    }

    /**
     * Hitungan like/komentar/restack, plus apakah user yang login
     * (kalau ada token) sudah like/restack post ini.
     */
    private function withInteractions(Builder $query, Request $request): Builder
    {
        $userId = $request->user('sanctum')?->id ?? 0;

        return $query
            ->withCount(['likes', 'comments', 'restacks'])
            ->withExists([
                'likes as liked_by_me' => fn ($q) => $q->where('user_id', $userId),
                'restacks as restacked_by_me' => fn ($q) => $q->where('user_id', $userId),
            ]);
    }
}