<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;


    protected $fillable = [
        'name',
        'foto',
        'email',
        'password',
    ];

    protected $appends = [
        'foto_url'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    public function games(): BelongsToMany {
        return $this->belongsToMany(Games::class, 'games_users', 'user_id', 'game_id')
            ->withPivot('rating');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    protected function fotoUrl(): Attribute
    {
        return Attribute::make(
            get: function (): mixed {
                $path = $this->foto;

                if ($path && Storage::disk('public')->exists($path)) {
                    return Storage::disk('public')->url($path);
                }

                return 'https://ui-avatars.com/api/?name=' . urlencode($this->name) . '&background=random&format=png';
            }
        );
    }
}
