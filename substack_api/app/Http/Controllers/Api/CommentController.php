<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    public function store(Request $request, int $id): JsonResponse
    {
        $post = Post::where('status', 'published')->findOrFail($id);

        $data = $request->validate([
            'content' => ['required', 'string', 'max:1000'],
        ], [
            'content.required' => 'Balasan tidak boleh kosong.',
            'content.max' => 'Balasan maksimal 1000 karakter.',
        ]);

        $comment = $post->comments()->create([
            'user_id' => $request->user()->id,
            'content' => $data['content'],
        ]);

        $comment->load('user:id,name,username,avatar_url');

        return response()->json(['data' => $comment], 201);
    }
}