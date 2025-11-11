<?php

use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


// Rotas públicas.
Route::post('login', [AuthController::class,'login']);

// Rotas protegidas.
Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class,'logout']);
});
