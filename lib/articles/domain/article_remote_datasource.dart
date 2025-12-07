import '../data/article_model.dart';

abstract class ArticleRemoteDatasource {
  Future<List<ArticleModel>> getTopHeadlines({String countryCode, int page});
  Future<List<ArticleModel>> searchArticles(String query, {int page});
}