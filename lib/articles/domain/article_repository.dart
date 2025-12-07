import 'article.dart';

abstract class ArticleRepository {
  Future<List<Article>> getTopHeadlines({String countryCode = 'us', int page = 1});
  Future<List<Article>> searchArticles(String query, {int page = 1});
  Future<List<Article>> getCachedArticles();
  Future<List<Article>> getBookmarkedArticles();
  Future<void> bookmarkArticle(Article article);
  Future<void> removeBookmark(Article article);
  Future<bool> isBookmarked(Article article);
}
