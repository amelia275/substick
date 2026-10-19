<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Notification::with([
            'actor',
            'post.publication',
            'comment',
        ])->orderByDesc('created_at')->orderByDesc('id');

        if ($request->filled('recipient_id')) {
            $query->where('recipient_id', (int) $request->query('recipient_id'));
        }

        if ($request->filled('type')) {
            $query->where('type', $request->query('type'));
        }

        $notifications = $query->paginate(20);

        return response()->json($notifications);
    }
}
