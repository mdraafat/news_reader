import 'package:flutter_test/flutter_test.dart';
import 'package:news_reader/articles/data/article_model.dart';

void main() {
  group('ArticleModel', () {

    test('should create ArticleModel from JSON map', () {
      // Arrange
      final json = {
        'title': 'Test News Title',
        'description': 'Test description',
        'url': 'https://example.com/article',
        'urlToImage': 'https://example.com/image.jpg',
        'publishedAt': '2024-01-01T12:00:00Z',
        'author': 'John Doe',
      };

      // Act
      final article = ArticleModel.fromJson(json);

      // Assert
      expect(article.title, 'Test News Title');
      expect(article.description, 'Test description');
      expect(article.url, 'https://example.com/article');
      expect(article.imageUrl, 'https://example.com/image.jpg');
      expect(article.publishedAt, DateTime.parse('2024-01-01T12:00:00Z'));
      expect(article.author, 'John Doe');
    });
    
  });
}