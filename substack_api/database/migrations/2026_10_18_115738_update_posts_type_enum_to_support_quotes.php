<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("
            ALTER TABLE posts
            MODIFY COLUMN type
            ENUM('article', 'note', 'quote')
            NOT NULL
        ");
    }

    public function down(): void
    {
        // Kembalikan quote menjadi note sebelum rollback.
        DB::table('posts')
            ->where('type', 'quote')
            ->update(['type' => 'note']);

        DB::statement("
            ALTER TABLE posts
            MODIFY COLUMN type
            ENUM('article', 'note')
            NOT NULL
        ");
    }
};
