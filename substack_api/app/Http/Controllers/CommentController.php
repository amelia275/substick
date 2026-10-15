<?php
namespace App\Http\Controllers;
use App\Models\Comment;

class CommentController extends Controller {
    public function index($id) {
        return response()->json(['data' => Comment::with('user')
            ->where('post_id', $id)->whereNull('parent_comment_id')
            ->orderBy('created_at')->get()]);
    }
}
