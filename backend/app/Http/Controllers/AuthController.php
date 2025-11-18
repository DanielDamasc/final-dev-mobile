<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(LoginRequest $request) {
        $credentials = $request->only('email', 'password');

        if (!Auth::attempt($credentials)) {
            // Unauthorized
            return response()->json([
                'message' => 'Credenciais inválidas.'
            ], 401);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        // garante que o usuário só possa estar logado em um dispositivo.
        $user->tokens()->delete();

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'token' => $token
        ], 200);
    }

    public function register(RegisterRequest $request) {

        try {

            DB::beginTransaction();

            // $caminho = null;
            // if ($request->hasFile('foto')) {
            //     $caminho = $request->file('foto')->store('fotos', 'public');
            // }

            $user = User::create([
                'name' => $request->name,
                // 'foto' => $caminho,
                'email' => $request->email,
                'password'=> Hash::make($request->password),
            ]);

            $token = $user->createToken('api-token')->plainTextToken;

            DB::commit();

        } catch (Exception $e) {

            DB::rollBack();

            return response()->json([
               'message' => $e
            ], 500);

        }

        return response()->json([
            'token'=> $token
        ], 201);

    }

    public function logout(Request $request){

        // Pega o usuário autenticado.
        $user = $request->user();

        // Apaga o token do banco de dados.
        $user->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout realizado com sucesso.'
        ], 200);
    }

    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
