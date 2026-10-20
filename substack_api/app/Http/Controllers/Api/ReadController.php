<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;

class ReadController extends Controller
{
    public function index()
    {
        $categories = Category::orderBy('sort_order')
            ->with(['posts' => fn ($q) => $q
                ->with(['user', 'publication'])
                ->where('type', 'article')
                ->orderByDesc('published_at')
                ->limit(10)])
            ->get();

        return response()->json([
            'data' => $categories->map(fn ($c) => [
                'category' => $c->name,   // teks saja, bukan objek
                'posts'    => $c->posts,
            ])->values(),
        ]);
    }
}