<?php
namespace App\Http\Controllers;
use App\Models\Podcast;

class PodcastController extends Controller {
    public function index() {
        return response()->json(['data' => Podcast::with('user')->latest()->paginate(20)]);
    }
}
