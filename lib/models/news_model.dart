class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String source;
  final String author;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
    required this.author,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Sans titre',
      description: json['description'] ?? 'Pas de description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? DateTime.now().toIso8601String(),
      source: json['source']?['name'] ?? 'Source inconnue',
      author: json['author'] ?? 'Auteur inconnu',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'publishedAt': publishedAt,
    'source': {'name': source},
    'author': author,
  };
}
