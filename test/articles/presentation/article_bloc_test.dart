import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/articles/domain/article.dart';
import 'package:news_reader/articles/domain/article_repository.dart';
import 'package:news_reader/articles/presentation/bloc/article_bloc.dart';
import 'package:news_reader/articles/presentation/bloc/article_event.dart';
import 'package:news_reader/articles/presentation/bloc/article_state.dart';

// Mock the repository
class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late ArticleBloc bloc;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    bloc = ArticleBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ArticleBloc', () {
    final tArticles = [
      Article(
        title: 'Test Article 1',
        description: 'Description 1',
        url: 'https://test1.com',
        imageUrl: 'https://test1.com/image.jpg',
        publishedAt: DateTime.parse('2024-01-01T12:00:00Z'),
        author: 'Author 1',
      ),
      Article(
        title: 'Test Article 2',
        description: 'Description 2',
        url: 'https://test2.com',
        imageUrl: 'https://test2.com/image.jpg',
        publishedAt: DateTime.parse('2024-01-02T12:00:00Z'),
        author: 'Author 2',
      ),
    ];

    test('initial state should be ArticleInitial', () {
      expect(bloc.state, equals(ArticleInitial()));
    });

    blocTest<ArticleBloc, ArticleState>(
      'emits [ArticleLoading, ArticleLoaded] when LoadTopHeadlines succeeds',
      build: () {
        when(() => mockRepository.getTopHeadlines(countryCode: any(named: 'countryCode')))
            .thenAnswer((_) async => tArticles);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTopHeadlines(countryCode: 'us')),
      expect: () => [
        ArticleLoading(),
        ArticleLoaded(articles: tArticles),
      ],
      verify: (_) {
        verify(() => mockRepository.getTopHeadlines(countryCode: 'us')).called(1);
      },
    );

    blocTest<ArticleBloc, ArticleState>(
      'emits [ArticleLoading, ArticleError] when LoadTopHeadlines fails',
      build: () {
        when(() => mockRepository.getTopHeadlines(countryCode: any(named: 'countryCode')))
            .thenThrow(Exception('Failed to load articles'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTopHeadlines(countryCode: 'us')),
      expect: () => [
        ArticleLoading(),
        ArticleError(message: 'Exception: Failed to load articles'),
      ],
    );

    blocTest<ArticleBloc, ArticleState>(
      'emits [ArticleLoading, ArticleLoaded] when SearchArticles succeeds',
      build: () {
        when(() => mockRepository.searchArticles(any()))
            .thenAnswer((_) async => tArticles);
        return bloc;
      },
      act: (bloc) => bloc.add(SearchArticles(query: 'flutter')),
      expect: () => [
        ArticleLoading(),
        ArticleLoaded(articles: tArticles),
      ],
      verify: (_) {
        verify(() => mockRepository.searchArticles('flutter')).called(1);
      },
    );

    blocTest<ArticleBloc, ArticleState>(
      'emits [ArticleLoading, ArticleError] when SearchArticles fails',
      build: () {
        when(() => mockRepository.searchArticles(any()))
            .thenThrow(Exception('Failed to search articles'));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchArticles(query: 'flutter')),
      expect: () => [
        ArticleLoading(),
        ArticleError(message: 'Exception: Failed to search articles'),
      ],
    );

    // Add these tests to the existing file

    blocTest<ArticleBloc, ArticleState>(
      'emits [ArticleLoading, ArticleLoaded] when LoadBookmarkedArticles succeeds',
      build: () {
        when(() => mockRepository.getBookmarkedArticles())
            .thenAnswer((_) async => tArticles);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadBookmarkedArticles()),
      expect: () => [
        ArticleLoading(),
        ArticleLoaded(articles: tArticles),
      ],
      verify: (_) {
        verify(() => mockRepository.getBookmarkedArticles()).called(1);
      },
    );

  });
}