<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Games extends Model
{
    /** @use HasFactory<\Database\Factories\GamesFactory> */
    use HasFactory;

    protected $primaryKey = "rawg_id";

    protected $fillable = [
        "rawg_id",
        "name",
        "description",
        "background_image",
        "released",
        "favorite",
    ];

    public function genres(): BelongsToMany {
        return $this->belongsToMany(Genres::class, "games_genres", "game_id", "genre_id");
    }
}
