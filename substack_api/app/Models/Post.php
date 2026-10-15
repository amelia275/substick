<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Post extends Model {
    protected $fillable = ['user_id', 'publication_id', 'type', 'title', 'body', 'cover_url', 'published_at'];
    public function user() { return $this->belongsTo(User::class); }
    public function publication() { return $this->belongsTo(Publication::class); }
    public function comments() { return $this->hasMany(Comment::class); }
}
