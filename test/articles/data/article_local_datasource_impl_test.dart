import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/articles/data/article_local_datasource_impl.dart';
import 'package:news_reader/articles/data/article_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ArticleLocalDatasourceImpl datasource;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    datasource = ArticleLocalDatasourceImpl(prefs: mockPrefs);
  });

  group('ArticleLocalDatasourceImpl', () {
    final tArticles = [
      ArticleModel(
        title: 'Test Article 1',
        description: 'Description 1',
        url: 'https://test1.com',
        imageUrl: 'https://test1.com/image.jpg',
        publishedAt: DateTime.parse('2024-01-01T12:00:00Z'),
        author: 'Author 1',
      ),
      ArticleModel(
        title: 'Test Article 2',
        description: 'Description 2',
        url: 'https://test2.com',
        imageUrl: null,
        publishedAt: null,
        author: null,
      ),
    ];

    group('cacheArticles', () {
      test('should cache articles to SharedPreferences', () async {
        // Arrange
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await datasource.cacheArticles(tArticles);

        // Assert
        verify(() => mockPrefs.setString('cached_articles', any())).called(1);
      });
    });

    group('getCachedArticles', () {
      test('should return cached articles from SharedPreferences', () async {
        // Arrange
        final jsonString = json.encode(
          tArticles.map((article) => article.toJson()).toList(),
        );
        when(() => mockPrefs.getString('cached_articles'))
            .thenReturn(jsonString);

        // Act
        final result = await datasource.getCachedArticles();

        // Assert
        expect(result.length, 2);
        expect(result[0].title, 'Test Article 1');
        expect(result[1].title, 'Test Article 2');
      });

      test('should return empty list when no cache exists', () async {
        // Arrange
        when(() => mockPrefs.getString('cached_articles')).thenReturn(null);

        // Act
        final result = await datasource.getCachedArticles();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('bookmarkArticle', () {
      test('should add article to bookmarks', () async {
        // Arrange
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(null);
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await datasource.bookmarkArticle(tArticles[0]);

        // Assert
        verify(() => mockPrefs.setString('bookmarked_articles', any()))
            .called(1);
      });

      test('should append to existing bookmarks', () async {
        // Arrange
        final existingBookmark = [tArticles[0]];
        final jsonString = json.encode(
          existingBookmark.map((a) => ArticleModel.fromArticle(a).toJson()).toList(),
        );
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(jsonString);
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await datasource.bookmarkArticle(tArticles[1]);

        // Assert
        final captured = verify(
          () => mockPrefs.setString('bookmarked_articles', captureAny()),
        ).captured;
        final savedList = json.decode(captured[0]) as List;
        expect(savedList.length, 2);
      });
    });

    group('removeBookmark', () {
      test('should remove article from bookmarks', () async {
        // Arrange
        final jsonString = json.encode(
          tArticles.map((a) => ArticleModel.fromArticle(a).toJson()).toList(),
        );
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(jsonString);
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await datasource.removeBookmark(tArticles[0]);

        // Assert
        final captured = verify(
          () => mockPrefs.setString('bookmarked_articles', captureAny()),
        ).captured;
        final savedList = json.decode(captured[0]) as List;
        expect(savedList.length, 1);
        expect(savedList[0]['title'], 'Test Article 2');
      });
    });

    group('isBookmarked', () {
      test('should return true if article is bookmarked', () async {
        // Arrange
        final jsonString = json.encode(
          [ArticleModel.fromArticle(tArticles[0]).toJson()],
        );
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(jsonString);

        // Act
        final result = await datasource.isBookmarked(tArticles[0]);

        // Assert
        expect(result, true);
      });

      test('should return false if article is not bookmarked', () async {
        // Arrange
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(null);

        // Act
        final result = await datasource.isBookmarked(tArticles[0]);

        // Assert
        expect(result, false);
      });
    });

    group('getBookmarkedArticles', () {
      test('should return all bookmarked articles', () async {
        // Arrange
        final jsonString = json.encode(
          tArticles.map((a) => ArticleModel.fromArticle(a).toJson()).toList(),
        );
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(jsonString);

        // Act
        final result = await datasource.getBookmarkedArticles();

        // Assert
        expect(result.length, 2);
        expect(result[0].title, 'Test Article 1');
      });

      test('should return empty list when no bookmarks exist', () async {
        // Arrange
        when(() => mockPrefs.getString('bookmarked_articles'))
            .thenReturn(null);

        // Act
        final result = await datasource.getBookmarkedArticles();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
