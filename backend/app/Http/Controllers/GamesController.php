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
    public function show(Games $games)
    {
        //
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
    public function update()
    {
        //
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
