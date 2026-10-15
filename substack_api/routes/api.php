<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PostController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\PodcastController;
use App\Http\Controllers\EpisodeController;

Route::get('/posts', [PostController::class, 'index']);
Route::get('/posts/{id}', [PostController::class, 'show']);
Route::get('/posts/{id}/comments', [CommentController::class, 'index']);
Route::get('/podcasts', [PodcastController::class, 'index']);
Route::get('/podcasts/{id}/episodes', [EpisodeController::class, 'index']);
