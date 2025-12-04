import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/articles/data/article_model.dart';
import 'package:news_reader/articles/data/article_repository_impl.dart';
import 'package:news_reader/articles/domain/article.dart';
import 'package:news_reader/articles/domain/article_local_datasource.dart';
import 'package:news_reader/articles/domain/article_remote_datasource.dart';

// Mock the datasource
class MockArticleRemoteDatasource extends Mock
    implements ArticleRemoteDatasource {}

// Mock the HTTP client for the second test
class MockHttpClient extends Mock implements http.Client {}

class MockArticleLocalDatasource extends Mock
    implements ArticleLocalDatasource {}

// Add Fake class for Article
class FakeArticle extends Fake implements Article {}

void main() {
  late ArticleRepositoryImpl repository;
  late MockArticleRemoteDatasource mockDatasource;

  // Register fallback for Uri (required by mocktail)
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(FakeArticle()); // Add this line
  });

  late MockArticleLocalDatasource mockLocalDatasource;

  setUp(() {
    mockDatasource = MockArticleRemoteDatasource();
    mockLocalDatasource = MockArticleLocalDatasource();
    repository = ArticleRepositoryImpl(
      remoteDatasource: mockDatasource,
      localDatasource: mockLocalDatasource,
    );
  });

  group('ArticleRepositoryImpl', () {
    test('getTopHeadlines returns list of Articles', () async {
      final tArticleModels = [
        ArticleModel(
          title: 'Test Article',
          description: 'Description',
          url: 'https://test.com',
          imageUrl: 'https://test.com/image.jpg',
          publishedAt: DateTime.parse('2024-01-01T12:00:00Z'),
          author: 'Author',
        ),
      ];

      when(
        () => mockDatasource.getTopHeadlines(
          countryCode: any(named: 'countryCode'),
        ),
      ).thenAnswer((_) async => tArticleModels);

      final result = await repository.getTopHeadlines(countryCode: 'us');

      expect(result, isA<List<Article>>());
      expect(result.length, 1);
      expect(result.first.title, 'Test Article');
    });

    test('searchArticles returns list of ArticleModel', () async {
      // Mock the searchArticles method on the datasource instead
      final tArticleModels = [
        ArticleModel(
          title: 'Flutter 3.0 Released',
          description: 'New features in Flutter',
          url: 'https://flutter.dev',
          imageUrl: 'https://flutter.dev/image.jpg',
          publishedAt: DateTime.parse('2025-01-02T12:00:00Z'),
          author: 'Flutter Team',
        ),
        ArticleModel(
          title: 'Building Apps with Flutter',
          description: 'Tutorial on Flutter development',
          url: 'https://example.com',
          imageUrl: 'https://example.com/image.jpg',
          publishedAt: DateTime.parse('2025-01-03T12:00:00Z'),
          author: 'Developer',
        ),
      ];

      when(
        () => mockDatasource.searchArticles(any()),
      ).thenAnswer((_) async => tArticleModels);

      final result = await repository.searchArticles('flutter');

      expect(result, isA<List<Article>>());
      expect(result.length, 2);
      expect(result.first.title, 'Flutter 3.0 Released');
      expect(result[1].title, 'Building Apps with Flutter');
    });
  });

  group('Caching', () {
    test('getCachedArticles returns cached articles', () async {
      final tArticles = [
        Article(
          title: 'Cached Article',
          description: 'Description',
          url: 'https://cached.com',
          imageUrl: null,
          publishedAt: null,
          author: null,
        ),
      ];

      when(
        () => mockLocalDatasource.getCachedArticles(),
      ).thenAnswer((_) async => tArticles);

      final result = await repository.getCachedArticles();

      expect(result, tArticles);
      verify(() => mockLocalDatasource.getCachedArticles()).called(1);
    });
  });

  group('Bookmarks', () {
    final tArticle = Article(
      title: 'Bookmark Article',
      description: 'Description',
      url: 'https://bookmark.com',
      imageUrl: null,
      publishedAt: null,
      author: null,
    );

    test('getBookmarkedArticles returns bookmarked articles', () async {
      when(
        () => mockLocalDatasource.getBookmarkedArticles(),
      ).thenAnswer((_) async => [tArticle]);

      final result = await repository.getBookmarkedArticles();

      expect(result.length, 1);
      verify(() => mockLocalDatasource.getBookmarkedArticles()).called(1);
    });

    test('bookmarkArticle calls local datasource', () async {
      when(
        () => mockLocalDatasource.bookmarkArticle(any()),
      ).thenAnswer((_) async => {});

      await repository.bookmarkArticle(tArticle);

      verify(() => mockLocalDatasource.bookmarkArticle(tArticle)).called(1);
    });

    test('removeBookmark calls local datasource', () async {
      when(
        () => mockLocalDatasource.removeBookmark(any()),
      ).thenAnswer((_) async => {});

      await repository.removeBookmark(tArticle);

      verify(() => mockLocalDatasource.removeBookmark(tArticle)).called(1);
    });

    test('isBookmarked returns bookmark status', () async {
      when(
        () => mockLocalDatasource.isBookmarked(any()),
      ).thenAnswer((_) async => true);

      final result = await repository.isBookmarked(tArticle);

      expect(result, true);
      verify(() => mockLocalDatasource.isBookmarked(tArticle)).called(1);
    });
  });
}
