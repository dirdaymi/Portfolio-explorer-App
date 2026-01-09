class Recipe {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbUrl;
  final String? youtubeUrl;
  final List<String> ingredients;
  final List<String> measures;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    this.youtubeUrl,
    required this.ingredients,
    required this.measures,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];
    
    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'] ?? '';
      String measure = json['strMeasure$i'] ?? '';
      
      if (ingredient.isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure);
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown Recipe',
      category: json['strCategory'] ?? 'Unknown',
      area: json['strArea'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? 'No instructions available',
      thumbUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
    );
  }
}
