import 'package:flutter/foundation.dart';

enum FavoriteType { news, photo, recipe }

class FavoriteItem {
  final String id;
  final FavoriteType type;
  final String title;
  final String imageUrl;
  final String description;
  final String itemUrl;
  final DateTime addedDate;
  final Map<String, dynamic> data;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.itemUrl,
    required this.data,
  }) : addedDate = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;

  FavoriteItem copyWith({
    String? id,
    FavoriteType? type,
    String? title,
    String? imageUrl,
    String? description,
    String? itemUrl,
    Map<String, dynamic>? data,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      itemUrl: itemUrl ?? this.itemUrl,
      data: data ?? this.data,
    );
  }
}
