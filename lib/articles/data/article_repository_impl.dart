import '../domain/article.dart';
import '../domain/article_local_datasource.dart';
import '../domain/article_repository.dart';
import '../domain/article_remote_datasource.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDatasource remoteDatasource;
  final ArticleLocalDatasource localDatasource;

  ArticleRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<List<Article>> getTopHeadlines({String countryCode = 'us'}) async {
    return await remoteDatasource.getTopHeadlines(countryCode: countryCode);
  }

  @override
  Future<List<Article>> searchArticles(String query) async {
    return await remoteDatasource.searchArticles(query);
  }

  @override
  Future<List<Article>> getCachedArticles() async {
    return await localDatasource.getCachedArticles();
  }

  @override
  Future<List<Article>> getBookmarkedArticles() async {
    return await localDatasource.getBookmarkedArticles();
  }

  @override
  Future<void> bookmarkArticle(Article article) async {
    await localDatasource.bookmarkArticle(article);
  }

  @override
  Future<void> removeBookmark(Article article) async {
    await localDatasource.removeBookmark(article);
  }

  @override
  Future<bool> isBookmarked(Article article) async {
    return await localDatasource.isBookmarked(article);
  }
}