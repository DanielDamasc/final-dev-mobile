<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('games_genres', function (Blueprint $table) {

            $table->foreignId('game_id')->references('id')->on('games')->onDelete('cascade');
            $table->foreignId('genre_id')->references('id')->on('genres')->onDelete('cascade');

            $table->primary(['game_id', 'genre_id']);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('games_genres');
    }
};
