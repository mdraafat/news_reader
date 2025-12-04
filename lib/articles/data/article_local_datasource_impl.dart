import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/article.dart';
import '../domain/article_local_datasource.dart';
import 'article_model.dart';

class ArticleLocalDatasourceImpl implements ArticleLocalDatasource {
  final SharedPreferences prefs;
  static const String cachedArticlesKey = 'cached_articles';
  static const String bookmarkedArticlesKey = 'bookmarked_articles';

  ArticleLocalDatasourceImpl({required this.prefs});

  @override
  Future<List<Article>> getCachedArticles() async {
    final jsonString = prefs.getString(cachedArticlesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => ArticleModel.fromJson(json)).toList();
  }

  @override
  Future<void> cacheArticles(List<Article> articles) async {
    final articleModels = articles
        .map((article) => ArticleModel.fromArticle(article))
        .toList();
    final jsonString = json.encode(
      articleModels.map((article) => article.toJson()).toList(),
    );
    await prefs.setString(cachedArticlesKey, jsonString);
  }

  @override
  Future<List<Article>> getBookmarkedArticles() async {
    final jsonString = prefs.getString(bookmarkedArticlesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => ArticleModel.fromJson(json)).toList();
  }

  @override
  Future<void> bookmarkArticle(Article article) async {
    final bookmarks = await getBookmarkedArticles();
    final articleModel = ArticleModel.fromArticle(article);
    
    // Avoid duplicates
    if (!bookmarks.any((a) => a.url == article.url)) {
      bookmarks.add(articleModel);
      final jsonString = json.encode(
        bookmarks
            .map((a) => ArticleModel.fromArticle(a).toJson())
            .toList(),
      );
      await prefs.setString(bookmarkedArticlesKey, jsonString);
    }
  }

  @override
  Future<void> removeBookmark(Article article) async {
    final bookmarks = await getBookmarkedArticles();
    bookmarks.removeWhere((a) => a.url == article.url);
    
    final jsonString = json.encode(
      bookmarks
          .map((a) => ArticleModel.fromArticle(a).toJson())
          .toList(),
    );
    await prefs.setString(bookmarkedArticlesKey, jsonString);
  }

  @override
  Future<bool> isBookmarked(Article article) async {
    final bookmarks = await getBookmarkedArticles();
    return bookmarks.any((a) => a.url == article.url);
  }
}
