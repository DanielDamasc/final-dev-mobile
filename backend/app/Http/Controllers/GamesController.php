<?php

namespace App\Http\Controllers;

use App\Http\Requests\GameRegisterRequest;
use App\Models\Games;
use App\Models\Genres;
use DB;

class GamesController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(GameRegisterRequest $request)
    {
        $games = $request->validated();
        
        DB::beginTransaction();

        try {

            $game = Games::create([
                'rawg_id' => $games['rawg_id'],
                'name' => $games['name'],
                'description' => $games['description'],
                'background_image' => $games['background_image'],
                'released' => $games['released'],
            ]);

            $genresIds = collect($games['genres'])->map(function ($genreName) {
                return Genres::firstOrCreate(['name' => $genreName])->id;
            });

            $game->genres()->sync($genresIds);

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
    public function destroy(Games $games)
    {
        //
    }
}
