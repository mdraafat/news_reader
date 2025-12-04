import 'dart:convert';
import 'package:http/http.dart';
import '../../constants.dart';
import '../domain/article_remote_datasource.dart';
import 'article_model.dart';

class ArticleRemoteDatasourceImpl implements ArticleRemoteDatasource {
  final Client client;

  ArticleRemoteDatasourceImpl({required this.client});

  @override
  Future<List<ArticleModel>> getTopHeadlines({
    String countryCode = 'us',
  }) async {
    final response = await client.get(
      Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=$countryCode&apiKey=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Check if API returned an error
      if (jsonData['status'] == 'error') {
        throw Exception(jsonData['message'] ?? 'API Error');
      }

      final articles = (jsonData['articles'] as List)
          .map((article) => ArticleModel.fromJson(article))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  @override
  Future<List<ArticleModel>> searchArticles(String query) async {
    final response = await client.get(
      Uri.parse('https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final articles = (jsonData['articles'] as List)
          .map((article) => ArticleModel.fromJson(article))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to search articles');
    }
  }
}
