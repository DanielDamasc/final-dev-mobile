<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class GameRegisterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return (bool) $this->user();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'rawg_id' => 'required|integer',
            'name' => 'required|string',
            'description' => 'required|max:5000',
            'background_image' => 'required|string|url',
            'released' => 'required|date|date_format:Y-m-d',
            'genres' => 'required|array|min:1',
            'genres.*' => 'string',
        ];
    }
}
