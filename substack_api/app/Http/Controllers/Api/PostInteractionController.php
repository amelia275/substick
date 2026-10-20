<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PostInteractionController extends Controller
{
    public function like(Request $request, int $id): JsonResponse
    {
        $post = $this->publishedPost($id);
        $post->likes()->firstOrCreate(['user_id' => $request->user()->id]);

        return $this->likeResponse($post, true);
    }

    public function unlike(Request $request, int $id): JsonResponse
    {
        $post = $this->publishedPost($id);
        $post->likes()->where('user_id', $request->user()->id)->delete();

        return $this->likeResponse($post, false);
    }

    public function restack(Request $request, int $id): JsonResponse
    {
        $post = $this->publishedPost($id);
        $post->restacks()->firstOrCreate(['user_id' => $request->user()->id]);

        return $this->restackResponse($post, true);
    }

    public function unrestack(Request $request, int $id): JsonResponse
    {
        $post = $this->publishedPost($id);
        $post->restacks()->where('user_id', $request->user()->id)->delete();

        return $this->restackResponse($post, false);
    }

    private function publishedPost(int $id): Post
    {
        return Post::where('status', 'published')->findOrFail($id);
    }

    private function likeResponse(Post $post, bool $liked): JsonResponse
    {
        return response()->json([
            'liked' => $liked,
            'likes_count' => $post->likes()->count(),
        ]);
    }

    private function restackResponse(Post $post, bool $restacked): JsonResponse
    {
        return response()->json([
            'restacked' => $restacked,
            'restacks_count' => $post->restacks()->count(),
        ]);
    }
}