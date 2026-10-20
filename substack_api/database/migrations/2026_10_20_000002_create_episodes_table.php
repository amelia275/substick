<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('episodes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('podcast_id')->constrained('podcasts')->cascadeOnDelete();
            $table->string('title');
            $table->string('subtitle')->nullable();
            $table->text('caption_snippet')->nullable();
            $table->longText('description')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->string('audio_url')->nullable();
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->boolean('is_featured_video')->default(false);
            $table->unsignedInteger('likes_count')->default(0);
            $table->unsignedInteger('comments_count')->default(0);
            $table->unsignedInteger('restacks_count')->default(0);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });

        Schema::table('comments', function (Blueprint $table) {
            $table->unsignedBigInteger('post_id')->nullable()->change();
            $table->foreignId('episode_id')
                ->nullable()
                ->after('post_id')
                ->constrained('episodes')
                ->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('comments', function (Blueprint $table) {
            $table->dropConstrainedForeignId('episode_id');
        });

        Schema::dropIfExists('episodes');
    }
};
