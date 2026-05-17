import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> displayedRecipes = [];
  String? centerMessage;
  bool showCenterMessage = false;
  int? updatingIndex;
  int? patchingIndex;

  Future<void> getAllRecipes() async {
    final provider = context.read<RecipeProvider>();
    await provider.fetchRecipes();
    setState(() {
      displayedRecipes = [];
      centerMessage = "${provider.recipes.length}";
      showCenterMessage = true;
    });
    _clearCenterMessage();
  }

  void getRandomRecipe() {
    final provider = context.read<RecipeProvider>();
    if (provider.recipes.isEmpty) {
      setState(() {
        centerMessage = "No recipes found!\nPress GET ALL first";
        showCenterMessage = true;
        displayedRecipes = [];
      });
      _clearCenterMessage();
      return;
    }
    final random = Random().nextInt(provider.recipes.length);
    setState(() {
      displayedRecipes = [provider.recipes[random]];
      showCenterMessage = false;
      centerMessage = null;
    });
  }

  void addRecipeDialog() {
    final controllers = {
      'name': TextEditingController(),
      'cuisine': TextEditingController(),
      'difficulty': TextEditingController(),
      'image': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Recipe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controllers['name'], decoration: const InputDecoration(hintText: "Name")),
            TextField(controller: controllers['cuisine'], decoration: const InputDecoration(hintText: "Cuisine")),
            TextField(controller: controllers['difficulty'], decoration: const InputDecoration(hintText: "Difficulty")),
            TextField(controller: controllers['image'], decoration: const InputDecoration(hintText: "Image URL")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final newRecipe = Recipe(
                id: DateTime.now().millisecondsSinceEpoch,
                name: controllers['name']!.text,
                cuisine: controllers['cuisine']!.text,
                difficulty: controllers['difficulty']!.text,
                image: controllers['image']!.text,
              );
              await context.read<RecipeProvider>().addRecipe(newRecipe);
              Navigator.pop(context);
              await getAllRecipes();
              setState(() {
                centerMessage = "Added: ${newRecipe.name}";
                showCenterMessage = true;
                displayedRecipes = [];
              });
              _clearCenterMessage();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> updateRecipe(Recipe recipe, int index) async {
    setState(() {
      updatingIndex = index;
      showCenterMessage = false;
      centerMessage = null;
    });
    
    final updatedRecipe = Recipe(
      id: recipe.id,
      name: "${recipe.name} ✨",
      cuisine: recipe.cuisine,
      difficulty: recipe.difficulty,
      image: recipe.image,
    );
    
    await context.read<RecipeProvider>().updateRecipe(index, updatedRecipe);
    setState(() {
      displayedRecipes[index] = updatedRecipe;
      updatingIndex = null;
      centerMessage = "Updated: ${recipe.name}";
      showCenterMessage = true;
      displayedRecipes = [];
    });
    _clearCenterMessage();
  }

void patchRecipeDialog(Recipe recipe, int index) {
  final difficultyController = TextEditingController(text: recipe.difficulty);
  
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Patch Difficulty"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Update difficulty level:",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: difficultyController,
            decoration: const InputDecoration(
              hintText: "Difficulty",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.thermostat),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        TextButton(
          onPressed: () async {
            final Map<String, dynamic> updates = {};
            final String recipeName = recipe.name;
            
            if (difficultyController.text != recipe.difficulty && difficultyController.text.isNotEmpty) {
              updates['difficulty'] = difficultyController.text;
            }
            
            if (updates.isNotEmpty) {
              setState(() {
                patchingIndex = index;
              });
              
              try {
                await context.read<RecipeProvider>().patchRecipe(recipe.id, updates);
                
                setState(() {
                  // Update only the difficulty field in displayedRecipes
                  displayedRecipes[index] = displayedRecipes[index].copyWith(
                    difficulty: updates['difficulty'] ?? displayedRecipes[index].difficulty,
                  );
                  patchingIndex = null;
                  centerMessage = "Updated difficulty for: $recipeName";
                  showCenterMessage = true;
                });
                _clearCenterMessage();
              } catch (e) {
                setState(() {
                  patchingIndex = null;
                  centerMessage = "Update failed: $recipeName";
                  showCenterMessage = true;
                });
                _clearCenterMessage();
              }
            } else {
              setState(() {
                centerMessage = "No changes made to $recipeName";
                showCenterMessage = true;
              });
              _clearCenterMessage();
            }
            Navigator.pop(context);
          },
          child: const Text("APPLY UPDATE"),
        ),
      ],
    ),
  );
}

  void deleteRecipe(Recipe recipe, int index) async {
    final recipeName = recipe.name;
    await context.read<RecipeProvider>().deleteRecipe(recipe.id);
    setState(() {
      displayedRecipes.removeAt(index);
      centerMessage = "Deleted: $recipeName";
      showCenterMessage = true;
      displayedRecipes = [];
    });
    _clearCenterMessage();
  }

  void _clearCenterMessage() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showCenterMessage = false;
          centerMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RecipeSnap"),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: getAllRecipes,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey,
                      shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, 
                    ),),
                    
                    child: const Text("GET ALL", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: getRandomRecipe,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, 
                      ),),
                    child: const Text("GET ONE", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: addRecipeDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, 
                      ),),
                    child: const Text("POST", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Center(
                child: context.watch<RecipeProvider>().isLoading
                    ? const CircularProgressIndicator()
                    : showCenterMessage
                        ? _buildCenterMessage()
                        : displayedRecipes.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: displayedRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = displayedRecipes[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          child: Image.network(
                                            recipe.image,
                                            height: 250,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              height: 150,
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Cuisine: ${recipe.cuisine}",
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Difficulty: ${recipe.difficulty}",
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              if (updatingIndex == index || patchingIndex == index)
                                                const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                )
                                              else
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () => patchRecipeDialog(recipe, index),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.green,
                                                        padding: EdgeInsets.zero,
                                                        minimumSize: const Size(60, 30),
                                                      ),
                                                      child: const Text("PATCH", style: TextStyle(fontSize: 12)),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    TextButton(
                                                      onPressed: () => updateRecipe(recipe, index),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.blue,
                                                        padding: EdgeInsets.zero,
                                                        minimumSize: const Size(60, 30),
                                                      ),
                                                      child: const Text("UPDATE", style: TextStyle(fontSize: 12)),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    TextButton(
                                                      onPressed: () => deleteRecipe(recipe, index),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.red,
                                                        padding: EdgeInsets.zero,
                                                        minimumSize: const Size(60, 30),
                                                      ),
                                                      child: const Text("DELETE", style: TextStyle(fontSize: 12)),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : const Text(
                                "Press GET ONE to view a recipe",
                                style: TextStyle(color: Colors.grey),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterMessage() {
    bool isNumber = centerMessage != null && int.tryParse(centerMessage!) != null;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isNumber ? Icons.check_circle : Icons.info_outline,
          size: 60,
          color: Colors.grey,
        ),
        const SizedBox(height: 20),
        Text(
          centerMessage ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isNumber ? 64 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        if (isNumber)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              int.parse(centerMessage!) == 1 ? "Item Loaded" : "Items Loaded",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}