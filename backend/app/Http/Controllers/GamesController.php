<?php

namespace App\Http\Controllers;

use App\Http\Requests\GameRegisterRequest;
use App\Models\Games;
use App\Models\Genres;
use DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class GamesController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $authUser = auth()->user();

        $games = Games::with('genres')
                ->whereAttachedTo($authUser, 'users')
                ->orderBy("name", "asc")
                ->get();

        $data = $games->map(function($game) {
            $genreNames = $game->genres->map(function($genre) {
                return $genre->name;
            });

            return [
                "id" => $game->rawg_id,
                "name" => $game->name,
                "background_image" => $game->background_image,
                "released" => $game->released,
                "genres" => $genreNames
            ];
        });

        return response()->json(
            $data
        , 200);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(GameRegisterRequest $request)
    {
        $games = $request->validated();

        $authUser = $request->user();

        DB::beginTransaction();

        try {
            // firstOrCreate porque o game já pode ter sido adicionado por outro user.
            $game = Games::firstOrCreate(
    ['rawg_id' => $games['rawg_id']],
        [
                    'rawg_id' => $games['rawg_id'],
                    'name' => $games['name'],
                    'description' => $games['description'],
                    'background_image' => $games['background_image'],
                    'released' => $games['released']
                ]
            );

            $genresIds = collect($games['genres'])->map(function ($genreName) {
                return Genres::firstOrCreate(['name' => $genreName])->id;
            });

            $game->genres()->sync($genresIds);

            // Relaciona o usuário autenticado com o game que ele adicionou.
            $authUser->games()->attach($game->rawg_id);

            DB::commit();

            return response()->json([
                'message' => 'Jogo registrado com sucesso!'
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'message' => 'Erro interno ao registrar o jogo.',
                'erro' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store()
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(int $gameId)
    {
        $user = auth()->user();

        try {
            // Carrega a relação mas pega somente o user autenticado, para depois buscar o atributo da pivot.
            $game = Games::where('rawg_id', $gameId)
                ->whereAttachedTo($user, 'users')
                ->with(['users' => function($query) use ($user) {
                    $query->where('id', $user->id);
                }, 'genres'])
                ->firstOrFail();

            // Consegue acessar o atributo diretamente por ter carregado a relação antes.
            $rating = $game->users->first()->pivot->rating;

            $genreData = $game->genres->map(function ($genre) {
                return $genre->name;
            });

            $gameData = [
                'rawg_id' => $game->rawg_id,
                'name' => $game->name,
                'description' => $game->description,
                'background_image' => $game->background_image,
                'released' => $game->released,
                'rating' => (double) $rating,
                'genres' => $genreData
            ];

            return response()->json($gameData);

        } catch (ModelNotFoundException $e) {
            return response()->json([
                "message" => "Jogo não encontrado."
            ], 404);

        } catch (\Exception $e) {
            return response()->json([
                "message" => "Erro de conexão."
            ], 500);
        }

    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Games $games)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(int $gameId, float $rating)
    {
        $user = auth()->user();

        try {
            $game = Games::with(['users' => function ($query) use ($user) {
                $query->where('id', $user->id);
            }])
                ->where('rawg_id', $gameId)
                ->firstOrFail();

            $game->users()->updateExistingPivot($user->id, ['rating' => $rating]);

            return response()->noContent();

        } catch (\Exception $e) {
            return response()->json([
                "message" => "Erro de conexão"
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(int $gameId)
    {
        $user = auth()->user();

        try {
            $game = Games::findOrFail($gameId);
            $rows = $game->users()->detach($user->id);

            if ($rows == 0) {
                return response()->json([
                    "message" => "ID $gameId não encontrado."
                ], 404);
            }

            return response()->noContent();

        } catch (ModelNotFoundException $e) {
            // findOrFail cai aqui.
            return response()->json([
                "message" => "Jogo com ID $gameId não encontrado."
            ], 404);

        } catch (\Exception $e) {
            return response()->json([
                "message" => "Erro de conexão."
            ], 500);
        }
    }
}
