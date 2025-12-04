import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:news_reader/articles/data/article_remote_datasource_impl.dart';
import 'package:news_reader/articles/data/article_model.dart';

// Create a mock version of http.Client to simulate API calls without real network requests
class MockClient extends Mock implements http.Client {}

// Fake URI needed for mocktail to handle any() matcher with Uri type
class FakeUri extends Fake implements Uri {}

void main() {
  late ArticleRemoteDatasourceImpl datasource;
  late MockClient mockClient;

  // Register the fake URI once before all tests run
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  // Setup runs before each test - creates fresh instances
  setUp(() {
    mockClient = MockClient();
    datasource = ArticleRemoteDatasourceImpl(client: mockClient);
  });

  group('ArticleRemoteDatasourceImpl', () {
    test('getTopHeadlines returns list of ArticleModel', () async {
      // Arrange - Setup the test data and mock behavior
      // Create a fake JSON response that mimics what the real API would return
      final responseBody = json.encode({
        'status': 'ok',
        'articles': [
          {
            'title': 'Test Article',
            'description': 'Test Description',
            'url': 'https://test.com',
            'urlToImage': 'https://test.com/image.jpg',
            'publishedAt': '2024-01-01T12:00:00Z',
            'author': 'Test Author',
          }
        ]
      });

      // Tell the mock: when get() is called with any URL, return our fake response
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act - Execute the function we're testing
      final result = await datasource.getTopHeadlines(countryCode: 'us');

      // Assert - Verify the results are what we expect
      expect(result, isA<List<ArticleModel>>()); // Check it returns the correct type
      expect(result.length, 1); // Check we got exactly 1 article
      expect(result.first.title, 'Test Article'); // Check the article data is correct
    });

    test('searchArticles returns list of ArticleModel', () async {
      // Arrange - Setup fake search results
      final responseBody = json.encode({
        'status': 'ok',
        'articles': [
          {
            'title': 'Search Result',
            'description': 'Search Description',
            'url': 'https://search.com',
            'urlToImage': 'https://search.com/image.jpg',
            'publishedAt': '2024-01-02T12:00:00Z',
            'author': 'Search Author',
          }
        ]
      });

      // Mock the HTTP response for search endpoint
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act - Call the search function
      final result = await datasource.searchArticles('flutter');

      // Assert - Verify search results are returned correctly
      expect(result, isA<List<ArticleModel>>());
      expect(result.length, 1);
      expect(result.first.title, 'Search Result');
    });
  });
}