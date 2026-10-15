<?php
namespace App\Http\Controllers;
use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller {
    public function index(Request $request) {
        $query = Post::with('user')->orderByDesc('published_at');
        if ($request->filled('type')) $query->where('type', $request->query('type'));
        return response()->json(['data' => $query->paginate(20)]);
    }
    public function show($id) {
        $post = Post::with(['user', 'publication', 'comments.user'])->findOrFail($id);
        return response()->json(['data' => $post]);
    }
}
