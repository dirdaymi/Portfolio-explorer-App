import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class RecipeService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=$query'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => Recipe.fromJson(meal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  Future<Recipe?> getRandomRecipe() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/random.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching random recipe: $e');
      return null;
    }
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/filter.php?c=$category'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          List<Recipe> recipes = [];
          for (var meal in data['meals']) {
            final detailResponse = await http.get(
              Uri.parse('$_baseUrl/lookup.php?i=${meal['idMeal']}'),
            );
            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              if (detailData['meals'] != null) {
                recipes.add(Recipe.fromJson(detailData['meals'][0]));
              }
            }
          }
          return recipes;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching recipes by category: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/list.php?c=list'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((cat) => cat['strCategory'] as String)
              .toList();
        }
      }
      return ['Beef', 'Chicken', 'Dessert', 'Lamb', 'Miscellaneous', 'Pasta', 'Pork', 'Seafood', 'Side', 'Starter', 'Vegan', 'Vegetarian'];
    } catch (e) {
      print('Error fetching categories: $e');
      return ['Beef', 'Chicken', 'Dessert', 'Lamb', 'Miscellaneous', 'Pasta', 'Pork', 'Seafood', 'Side', 'Starter', 'Vegan', 'Vegetarian'];
    }
  }
}
