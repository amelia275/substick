<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\PostInteractionController;
use App\Http\Controllers\Api\ReadController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

Route::get('/posts', [PostController::class, 'index']);
Route::get('/posts/{id}', [PostController::class, 'show']);
Route::get('/read', [ReadController::class, 'index']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/notifications', [NotificationController::class, 'index']);

    Route::post('/posts', [PostController::class, 'store'])->middleware('throttle:30,1');

    Route::post('/posts/{id}/like', [PostInteractionController::class, 'like']);
    Route::delete('/posts/{id}/like', [PostInteractionController::class, 'unlike']);
    Route::post('/posts/{id}/restack', [PostInteractionController::class, 'restack']);
    Route::delete('/posts/{id}/restack', [PostInteractionController::class, 'unrestack']);
    Route::post('/posts/{id}/comments', [CommentController::class, 'store'])
        ->middleware('throttle:60,1');
});