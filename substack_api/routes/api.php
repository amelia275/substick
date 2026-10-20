<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PodcastController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\ReadController;

Route::get('/posts', [PostController::class, 'index']);
Route::get('/posts/{id}', [PostController::class, 'show']);
Route::get('/read', [ReadController::class, 'index']);
Route::get('/notifications', [NotificationController::class, 'index']);
Route::get('/podcasts', [PodcastController::class, 'index']);
Route::get('/podcasts/{id}/episodes', [PodcastController::class, 'episodes']);
