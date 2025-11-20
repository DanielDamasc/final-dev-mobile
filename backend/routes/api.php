<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GamesController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


// Rotas públicas.
Route::post('login', [AuthController::class,'login']);
Route::post('register', [AuthController::class,'register']);

// Rotas protegidas.
Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class,'logout']);

    Route::post('gameRegister', [GamesController::class, 'create']);

    Route::get('games', [GamesController::class, 'index']);
});
