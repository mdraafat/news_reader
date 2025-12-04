import 'article.dart';

abstract class ArticleLocalDatasource {
  Future<List<Article>> getCachedArticles();
  Future<void> cacheArticles(List<Article> articles);
  Future<List<Article>> getBookmarkedArticles();
  Future<void> bookmarkArticle(Article article);
  Future<void> removeBookmark(Article article);
  Future<bool> isBookmarked(Article article);
}
