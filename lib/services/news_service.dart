import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  static const String _apiKey = 'apikey';
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsArticle>> fetchTopHeadlines({String category = 'technology', int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/top-headlines?country=us&category=$category&page=$page&pageSize=20&apiKey=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          return (data['articles'] as List)
              .map((article) => NewsArticle.fromJson(article))
              .where((article) => article.title != '[Removed]')
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching news: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=$query&sortBy=publishedAt&pageSize=20&apiKey=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          return (data['articles'] as List)
              .map((article) => NewsArticle.fromJson(article))
              .where((article) => article.title != '[Removed]')
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching news: $e');
      return [];
    }
  }
}
