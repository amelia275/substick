<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Podcast;
use Illuminate\Http\JsonResponse;

class PodcastController extends Controller
{
    public function index(): JsonResponse
    {
        $podcasts = Podcast::with([
            'user',
            'publication',
            'episodes.comments.user',
        ])->orderBy('id')->get();

        return response()->json([
            'data' => $podcasts,
        ]);
    }

    public function episodes(int $id): JsonResponse
    {
        $podcast = Podcast::with('episodes.comments.user')->findOrFail($id);

        return response()->json([
            'data' => $podcast->episodes,
        ]);
    }
}
