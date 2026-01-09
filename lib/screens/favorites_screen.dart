import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/favorite_model.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoriteType _selectedType = FavoriteType.news;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesService = context.watch<FavoritesService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        actions: [
          if (favoritesService.favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearConfirmation(context),
              tooltip: 'Tout supprimer',
            ),
        ],
      ),
      body: favoritesService.favorites.isEmpty
          ? _buildEmptyState(theme)
          : Column(
              children: [
                _buildTypeSelector(theme, favoritesService),
                Expanded(
                  child: _buildFavoritesList(theme, favoritesService),
                ),
              ],
            ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme, FavoritesService service) {
    final items = [
      _TypeSelectorItem(FavoriteType.news, 'Articles', Icons.article),
      _TypeSelectorItem(FavoriteType.photo, 'Photos', Icons.photo),
      _TypeSelectorItem(FavoriteType.recipe, 'Recettes', Icons.restaurant),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final count = service.getFavoritesByType(item.type).length;
          final isSelected = _selectedType == item.type;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedType = item.type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFavoritesList(ThemeData theme, FavoritesService service) {
    final favorites = service.getFavoritesByType(_selectedType);
    
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun favori',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez à ajouter des ${_getTypeLabelPlural()} à vos favoris',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _buildFavoriteCard(theme, favorite, service);
      },
    );
  }

  Widget _buildFavoriteCard(ThemeData theme, FavoriteItem favorite, FavoritesService service) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Dismissible(
        key: Key('${favorite.id}_${favorite.type}'),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => service.removeFavorite(favorite.id, favorite.type),
        child: InkWell(
          onTap: () => _openFavoriteContent(favorite),
          child: Row(
            children: [
              if (favorite.imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: favorite.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(_getTypeIcon()),
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    _getTypeIcon(),
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favorite.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        favorite.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(),
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getTypeLabel(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatDate(favorite.addedDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun favori',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des articles, photos et recettes à vos favoris',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (_selectedType) {
      case FavoriteType.news:
        return Icons.article;
      case FavoriteType.photo:
        return Icons.photo;
      case FavoriteType.recipe:
        return Icons.restaurant;
    }
  }

  IconData _getEmptyIcon() {
    switch (_selectedType) {
      case FavoriteType.news:
        return Icons.article_outlined;
      case FavoriteType.photo:
        return Icons.photo_outlined;
      case FavoriteType.recipe:
        return Icons.restaurant_outlined;
    }
  }

  String _getTypeLabel() {
    switch (_selectedType) {
      case FavoriteType.news:
        return 'Article';
      case FavoriteType.photo:
        return 'Photo';
      case FavoriteType.recipe:
        return 'Recette';
    }
  }

  String _getTypeLabelPlural() {
    switch (_selectedType) {
      case FavoriteType.news:
        return 'articles';
      case FavoriteType.photo:
        return 'photos';
      case FavoriteType.recipe:
        return 'recettes';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openFavoriteContent(FavoriteItem favorite) {
    // Implémenter l'ouverture du contenu selon le type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ouverture de: ${favorite.title}')),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer tous les favoris ?'),
        content: const Text(
          'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer tous vos favoris ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<FavoritesService>().clearFavorites();
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSelectorItem {
  final FavoriteType type;
  final String label;
  final IconData icon;

  _TypeSelectorItem(this.type, this.label, this.icon);
}
