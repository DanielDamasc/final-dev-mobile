<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Genres extends Model
{
    /** @use HasFactory<\Database\Factories\GenresFactory> */
    use HasFactory;

    protected $fillable = [
        "name",
    ];

    public function games(): BelongsToMany {
        return $this->belongsToMany(Games::class, "games_genres", "genre_id", "game_id");
    }
}
