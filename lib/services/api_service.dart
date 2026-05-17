import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  // GET RECIPES
  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List recipesJson = data['recipes'];

      return recipesJson
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // ADD RECIPE
  static Future<void> addRecipe(Recipe recipe) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recipe.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to add recipe');
    }
  }

  // UPDATE RECIPE
  static Future<void> updateRecipe(
      int id,
      Recipe recipe,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recipe.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update recipe');
    }
  }

  // DELETE RECIPE
  static Future<void> deleteRecipe(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe');
    }
  }

  // PATCH RECIPE
  static Future<void> patchRecipe(int id, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      
      body: jsonEncode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to partially update recipe');
    }
  }
}