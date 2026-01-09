import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo_model.dart';
import '../services/photo_service.dart';
import '../services/favorites_service.dart';
import '../models/favorite_model.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final PhotoService _photoService = PhotoService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Photo> _photos = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  String _searchQuery = '';

  final List<String> _suggestedSearches = [
    'nature',
    'technology',
    'architecture',
    'people',
    'business',
    'travel',
    'food',
    'art',
    'city',
    'abstract',
  ];

  @override
  void initState() {
    super.initState();
    _loadCuratedPhotos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 400 &&
        !_isLoadingMore) {
      _loadMorePhotos();
    }
  }

  Future<void> _loadCuratedPhotos() async {
    setState(() => _isLoading = true);
    
    final response = await _photoService.getCuratedPhotos(
      page: _currentPage,
      perPage: 20,
    );

    setState(() {
      _photos = response.photos;
      _isLoading = false;
    });
  }

  Future<void> _searchPhotos() async {
    if (_searchQuery.isEmpty) {
      _loadCuratedPhotos();
      return;
    }

    setState(() => _isLoading = true);
    
    final response = await _photoService.searchPhotos(
      query: _searchQuery,
      page: _currentPage,
      perPage: 20,
    );

    setState(() {
      _photos = response.photos;
      _isLoading = false;
    });
  }

  Future<void> _loadMorePhotos() async {
    setState(() => _isLoadingMore = true);
    
    final response = _searchQuery.isEmpty
        ? await _photoService.getCuratedPhotos(
            page: _currentPage + 1,
            perPage: 20,
          )
        : await _photoService.searchPhotos(
            query: _searchQuery,
            page: _currentPage + 1,
            perPage: 20,
          );

    setState(() {
      _photos.addAll(response.photos);
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
      _currentPage = 1;
    });
    
    if (query.isEmpty) {
      _loadCuratedPhotos();
    }
  }

  void _onSuggestedSearchTap(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
      _currentPage = 1;
    });
    _searchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCuratedPhotos,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildSuggestedSearches(theme),
          Expanded(
            child: _isLoading
                ? _buildLoadingGrid()
                : _photos.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildPhotoGrid(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher des photos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.cardColor,
        ),
        onSubmitted: (_) => _searchPhotos(),
      ),
    );
  }

  Widget _buildSuggestedSearches(ThemeData theme) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedSearches.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final search = _suggestedSearches[index];
          final isSelected = search == _searchQuery;
          
          return FilterChip(
            label: Text(
              search,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.cardColor,
            onSelected: (_) => _onSuggestedSearchTap(search),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
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
              Icons.photo_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune photo trouvée',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez une autre recherche',
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

  Widget _buildPhotoGrid(ThemeData theme) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _photos.length + (_isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= _photos.length) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final photo = _photos[index];
        return _buildPhotoCard(context, photo, theme);
      },
    );
  }

  Widget _buildPhotoCard(BuildContext context, Photo photo, ThemeData theme) {
    final isFavorite = context.watch<FavoritesService>().isFavorite(photo.id, FavoriteType.photo);
    
    return Hero(
      tag: 'photo_${photo.id}',
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photo.thumbUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () => context.read<FavoritesService>().toggleFavoritePhoto(photo),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo by ${photo.photographer}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    photo.alt,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPhotoViewer(context, photo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPhotoViewer(BuildContext context, Photo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(photo: photo),
      ),
    );
  }
}

class PhotoViewerScreen extends StatelessWidget {
  final Photo photo;

  const PhotoViewerScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<FavoritesService>(
            builder: (context, service, _) {
              final isFavorite = service.isFavorite(photo.id, FavoriteType.photo);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () => service.toggleFavoritePhoto(photo),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Implémenter le téléchargement
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité de téléchargement à implémenter')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'photo_${photo.id}',
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.black,
                child: const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo by ${photo.photographer}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (photo.alt.isNotEmpty)
                    Text(
                      photo.alt,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${photo.width} × ${photo.height} pixels',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
