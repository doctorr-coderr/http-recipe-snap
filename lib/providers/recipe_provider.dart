import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> recipes = [];

  bool isLoading = false;

  String? error;

  // FETCH RECIPES
  Future<void> fetchRecipes() async {
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      recipes = await ApiService.fetchRecipes();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ADD RECIPE
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await ApiService.addRecipe(recipe);

      recipes.insert(0, recipe);

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // UPDATE RECIPE
  Future<void> updateRecipe(int index, Recipe recipe) async {
    try {
      await ApiService.updateRecipe(recipe.id, recipe);

      recipes[index] = recipe;

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // DELETE RECIPE
  Future<void> deleteRecipe(int id) async {
    try {
      await ApiService.deleteRecipe(id);

      recipes.removeWhere((recipe) => recipe.id == id);

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // PATCH
  Future<void> patchRecipe(int id, Map<String, dynamic> updates) async {
    try {
      await ApiService.patchRecipe(id, updates);
      
      // Update local state
      final index = recipes.indexWhere((recipe) => recipe.id == id);
      if (index != -1) {
        // Apply only the updates to the existing recipe
        final updatedRecipe = recipes[index].copyWith(
          name: updates['name'] ?? recipes[index].name,
          cuisine: updates['cuisine'] ?? recipes[index].cuisine,
          difficulty: updates['difficulty'] ?? recipes[index].difficulty,
          image: updates['image'] ?? recipes[index].image,
        );
        recipes[index] = updatedRecipe;
        notifyListeners();
      }
    } catch (e) {
      print('Error patching recipe: $e');
      rethrow;
    }
  }
}