<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Episode extends Model
{
    protected $fillable = [
        'podcast_id',
        'title',
        'subtitle',
        'caption_snippet',
        'description',
        'thumbnail_url',
        'audio_url',
        'duration_seconds',
        'is_featured_video',
        'likes_count',
        'comments_count',
        'restacks_count',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'is_featured_video' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function podcast(): BelongsTo
    {
        return $this->belongsTo(Podcast::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }
}
