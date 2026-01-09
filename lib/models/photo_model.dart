class Photo {
  final String id;
  final String url;
  final String thumbUrl;
  final String photographer;
  final String photographerUrl;
  final int width;
  final int height;
  final String alt;

  Photo({
    required this.id,
    required this.url,
    required this.thumbUrl,
    required this.photographer,
    required this.photographerUrl,
    required this.width,
    required this.height,
    required this.alt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      url: json['src']?['large2x'] ?? json['src']?['large'] ?? json['src']?['medium'] ?? '',
      thumbUrl: json['src']?['medium'] ?? json['src']?['small'] ?? '',
      photographer: json['photographer'] ?? 'Unknown',
      photographerUrl: json['photographer_url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      alt: json['alt'] ?? 'Photo',
    );
  }
}

class PhotoSearchResponse {
  final List<Photo> photos;
  final int totalResults;
  final int page;
  final int perPage;

  PhotoSearchResponse({
    required this.photos,
    required this.totalResults,
    required this.page,
    required this.perPage,
  });

  factory PhotoSearchResponse.fromJson(Map<String, dynamic> json) {
    return PhotoSearchResponse(
      photos: (json['photos'] as List? ?? [])
          .map((photo) => Photo.fromJson(photo))
          .toList(),
      totalResults: json['total_results'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 15,
    );
  }
}
