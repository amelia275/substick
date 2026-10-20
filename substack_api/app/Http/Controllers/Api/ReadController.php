<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;

class ReadController extends Controller
{
    public function index()
    {
        $categories = Category::orderBy('sort_order')
            ->with([
                'posts' => fn ($q) => $q
                    ->where('type', 'article')
                    ->where('status', 'published')
                    ->with([
                        'user:id,name,username,avatar_url',
                        'publication:id,name,slug,logo_url',
                    ])
                    ->withCount(['likes', 'comments', 'restacks'])
                    ->orderByDesc('published_at')
                    ->orderByDesc('created_at')
                    ->limit(10),
            ])
            ->get();

        return response()->json([
            'data' => $categories->map(fn ($category) => [
                'category' => $category->name,
                'posts' => $category->posts,
            ])->values(),
        ]);
    }
}
