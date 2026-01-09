import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';

class PhotoService {
  static const String _apiKey = 'api_key';
  static const String _baseUrl = 'https://api.pexels.com/v1';

  Future<PhotoSearchResponse> searchPhotos({
    required String query,
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?query=$query&per_page=$perPage&page=$page'),
        headers: {'Authorization': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PhotoSearchResponse.fromJson(data);
      } else {
        print('Pexels API error: ${response.statusCode} - ${response.body}');
        return PhotoSearchResponse(photos: [], totalResults: 0, page: 1, perPage: 15);
      }
    } catch (e) {
      print('Error fetching photos: $e');
      return PhotoSearchResponse(photos: [], totalResults: 0, page: 1, perPage: 15);
    }
  }

  Future<PhotoSearchResponse> getCuratedPhotos({
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/curated?per_page=$perPage&page=$page'),
        headers: {'Authorization': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PhotoSearchResponse.fromJson(data);
      } else {
        print('Pexels API error: ${response.statusCode} - ${response.body}');
        return PhotoSearchResponse(photos: [], totalResults: 0, page: 1, perPage: 15);
      }
    } catch (e) {
      print('Error fetching curated photos: $e');
      return PhotoSearchResponse(photos: [], totalResults: 0, page: 1, perPage: 15);
    }
  }
}
