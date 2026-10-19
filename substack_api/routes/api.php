<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\ReadController;

Route::get('/posts', [PostController::class, 'index']);
Route::get('/posts/{id}', [PostController::class, 'show']);
<<<<<<< HEAD
Route::get('/read', [ReadController::class, 'index']);
=======
Route::get('/notifications', [NotificationController::class, 'index']);
>>>>>>> bfb09e7f024ce3d5ed4d70ebf3c3d3e317e5bc7f
