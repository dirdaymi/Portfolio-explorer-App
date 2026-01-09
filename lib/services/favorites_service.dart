import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/favorite_model.dart';
import '../models/news_model.dart';
import '../models/photo_model.dart';
import '../models/recipe_model.dart';

class FavoritesService extends ChangeNotifier {
  List<FavoriteItem> _favorites = [];
  
  List<FavoriteItem> get favorites => List.unmodifiable(_favorites);

  FavoritesService() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorites');
      
      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) => FavoriteItem(
          id: item['id'],
          type: FavoriteType.values.firstWhere(
            (e) => e.toString() == 'FavoriteType.${item['type']}',
            orElse: () => FavoriteType.news,
          ),
          title: item['title'],
          imageUrl: item['imageUrl'],
          description: item['description'],
          itemUrl: item['itemUrl'],
          data: item['data'],
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_favorites.map((item) => {
        'id': item.id,
        'type': item.type.toString().split('.').last,
        'title': item.title,
        'imageUrl': item.imageUrl,
        'description': item.description,
        'itemUrl': item.itemUrl,
        'data': item.data,
      }).toList());
      
      await prefs.setString('favorites', encoded);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  bool isFavorite(String id, FavoriteType type) {
    return _favorites.any((item) => item.id == id && item.type == type);
  }

  void toggleFavorite(NewsArticle article) {
    final favorite = FavoriteItem(
      id: article.id,
      type: FavoriteType.news,
      title: article.title,
      imageUrl: article.urlToImage,
      description: article.description,
      itemUrl: article.url,
      data: article.toJson(),
    );
    _toggleFavoriteItem(favorite);
  }

  void toggleFavoritePhoto(Photo photo) {
    final favorite = FavoriteItem(
      id: photo.id,
      type: FavoriteType.photo,
      title: 'Photo by ${photo.photographer}',
      imageUrl: photo.url,
      description: photo.alt,
      itemUrl: photo.photographerUrl,
      data: {
        'id': photo.id,
        'photographer': photo.photographer,
        'photographerUrl': photo.photographerUrl,
        'width': photo.width,
        'height': photo.height,
      },
    );
    _toggleFavoriteItem(favorite);
  }

  void toggleFavoriteRecipe(Recipe recipe) {
    final favorite = FavoriteItem(
      id: recipe.id,
      type: FavoriteType.recipe,
      title: recipe.name,
      imageUrl: recipe.thumbUrl,
      description: '${recipe.category} • ${recipe.area}',
      itemUrl: '',
      data: {
        'id': recipe.id,
        'category': recipe.category,
        'area': recipe.area,
        'instructions': recipe.instructions,
        'ingredients': recipe.ingredients,
        'measures': recipe.measures,
        'youtubeUrl': recipe.youtubeUrl,
      },
    );
    _toggleFavoriteItem(favorite);
  }

  void _toggleFavoriteItem(FavoriteItem item) {
    final existingIndex = _favorites.indexWhere(
      (fav) => fav.id == item.id && fav.type == item.type
    );

    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
    } else {
      _favorites.add(item);
    }

    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(String id, FavoriteType type) {
    _favorites.removeWhere((item) => item.id == id && item.type == type);
    _saveFavorites();
    notifyListeners();
  }

  void clearFavorites() {
    _favorites.clear();
    _saveFavorites();
    notifyListeners();
  }

  List<FavoriteItem> getFavoritesByType(FavoriteType type) {
    return _favorites.where((item) => item.type == type).toList();
  }
}
