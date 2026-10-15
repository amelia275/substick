<?php
namespace App\Http\Controllers;
use App\Models\Episode;

class EpisodeController extends Controller {
    public function index($id) {
        return response()->json(['data' => Episode::where('podcast_id', $id)
            ->orderByDesc('published_at')->get()]);
    }
}
