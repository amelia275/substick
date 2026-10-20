<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Podcast extends Model
{
    protected $fillable = [
        'user_id',
        'publication_id',
        'short_title',
        'title',
        'author_name',
        'description',
        'cover_url',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function publication(): BelongsTo
    {
        return $this->belongsTo(Publication::class);
    }

    public function episodes(): HasMany
    {
        return $this->hasMany(Episode::class)->orderByDesc('published_at')->orderByDesc('id');
    }
}
