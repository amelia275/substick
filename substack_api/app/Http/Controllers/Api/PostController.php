<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\JsonResponse;

class PostController extends Controller
{
    public function index(): JsonResponse
    {
        $posts = Post::with(['user', 'publication'])
            ->where('status', 'published')
            ->orderByDesc('published_at')
            ->orderByDesc('created_at')
            ->paginate(10);

        return response()->json($posts);
    }

    public function show(int $id): JsonResponse
    {
        $post = Post::with([
            'user',
            'publication',
            'comments.user',
        ])
            ->where('status', 'published')
            ->findOrFail($id);

        return response()->json([
            'data' => $post,
        ]);
    }
}
