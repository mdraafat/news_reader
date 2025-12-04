import '../data/article_model.dart';

abstract class ArticleRemoteDatasource {
  Future<List<ArticleModel>> getTopHeadlines ({String countryCode});
  Future<List<ArticleModel>> searchArticles (String query);
}