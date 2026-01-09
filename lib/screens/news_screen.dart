import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../services/favorites_service.dart';
import '../models/favorite_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  String _currentCategory = 'technology';
  String _searchQuery = '';

  final List<String> _categories = [
    'technology',
    'business',
    'science',
    'health',
    'entertainment',
    'sports',
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
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
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    
    List<NewsArticle> articles;
    if (_searchQuery.isNotEmpty) {
      articles = await _newsService.searchNews(_searchQuery);
    } else {
      articles = await _newsService.fetchTopHeadlines(
        category: _currentCategory,
        page: _currentPage,
      );
    }

    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  Future<void> _loadMoreArticles() async {
    if (_searchQuery.isNotEmpty) return; // No pagination for search
    
    setState(() => _isLoadingMore = true);
    
    final newArticles = await _newsService.fetchTopHeadlines(
      category: _currentCategory,
      page: _currentPage + 1,
    );

    setState(() {
      _articles.addAll(newArticles);
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  Future<void> _searchArticles() async {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _currentPage = 1;
    });
    await _loadArticles();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _currentCategory = category;
      _searchQuery = '';
      _searchController.clear();
      _currentPage = 1;
    });
    _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArticles,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildCategoryChips(theme),
          Expanded(
            child: _isLoading
                ? _buildLoadingList()
                : _articles.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildArticleList(theme),
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
        decoration: InputDecoration(
          hintText: 'Rechercher des actualités...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadArticles();
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
        onSubmitted: (_) => _searchArticles(),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _currentCategory && _searchQuery.isEmpty;
          
          return FilterChip(
            label: Text(
              _getCategoryDisplayName(category),
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.cardColor,
            onSelected: (_) => _onCategoryChanged(category),
          );
        },
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    final names = {
      'technology': 'Tech',
      'business': 'Business',
      'science': 'Science',
      'health': 'Santé',
      'entertainment': 'Divertissement',
      'sports': 'Sports',
    };
    return names[category] ?? category;
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 150,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
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
              Icons.article_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun article trouvé',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez une autre recherche ou sélectionnez une catégorie',
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

  Widget _buildArticleList(ThemeData theme) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == _articles.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final article = _articles[index];
        return _buildArticleCard(context, article, theme);
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, NewsArticle article, ThemeData theme) {
    final isFavorite = context.watch<FavoritesService>().isFavorite(article.id, FavoriteType.news);
    
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _openArticle(article.url),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              CachedNetworkImage(
                imageUrl: article.urlToImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => context.read<FavoritesService>().toggleFavorite(article),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: theme.textTheme.headlineMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.publishedAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'Lire plus',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openArticle(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'article')),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
