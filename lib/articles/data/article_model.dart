import '../domain/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.title,
    super.description,
    super.url,
    super.imageUrl,
    super.publishedAt,
    super.author,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      imageUrl: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      author: json['author'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt?.toIso8601String(),
      'author': author,
    };
  }

  factory ArticleModel.fromArticle(Article article) {
    return ArticleModel(
      title: article.title,
      description: article.description,
      url: article.url,
      imageUrl: article.imageUrl,
      publishedAt: article.publishedAt,
      author: article.author,
    );
  }
}
