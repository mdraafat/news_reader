import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/articles/domain/article.dart';
import 'package:news_reader/articles/domain/article_repository.dart';
import 'package:news_reader/articles/presentation/bloc/article_bloc.dart';
import 'package:news_reader/articles/presentation/view/article_detail.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepository;
  late ArticleBloc articleBloc;

  setUp(() {
    mockRepository = MockArticleRepository();
    articleBloc = ArticleBloc(repository: mockRepository);
  });

  Widget createWidget(Article article) {
    return MaterialApp(
      home: BlocProvider<ArticleBloc>.value(
        value: articleBloc,
        child: ArticleDetails(article: article),
      ),
    );
  }

  group('ArticleDetails Essential Tests', () {
    testWidgets('displays article title', (tester) async {
      final article = Article(
        title: 'Test Article Title',
        description: 'Test Description',
        url: 'https://test.com',
        imageUrl: null,
        publishedAt: DateTime(2024, 1, 1),
        author: 'Test Author',
      );
      when(() => mockRepository.isBookmarked(article)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget(article));
      await tester.pumpAndSettle();

      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('displays author and description', (tester) async {
      final article = Article(
        title: 'News',
        description: 'Breaking news today',
        url: 'https://test.com',
        imageUrl: null,
        publishedAt: DateTime(2024, 1, 1),
        author: 'John Doe',
      );
      when(() => mockRepository.isBookmarked(article)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget(article));
      await tester.pumpAndSettle();

      expect(find.text('By John Doe'), findsOneWidget);
      expect(find.text('Breaking news today'), findsOneWidget);
    });

    testWidgets('shows unbookmarked icon initially', (tester) async {
      final article = Article(
        title: 'Test',
        description: null,
        url: null,
        imageUrl: null,
        publishedAt: null,
        author: null,
      );
      when(() => mockRepository.isBookmarked(article)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget(article));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('shows bookmarked icon when article is bookmarked', (tester) async {
      final article = Article(
        title: 'Test',
        description: null,
        url: null,
        imageUrl: null,
        publishedAt: null,
        author: null,
      );
      when(() => mockRepository.isBookmarked(article)).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidget(article));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('calls bookmarkArticle when bookmark icon tapped', (tester) async {
      final article = Article(
        title: 'Test',
        description: null,
        url: null,
        imageUrl: null,
        publishedAt: null,
        author: null,
      );
      when(() => mockRepository.isBookmarked(article)).thenAnswer((_) async => false);
      when(() => mockRepository.bookmarkArticle(article)).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidget(article));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();

      verify(() => mockRepository.bookmarkArticle(article)).called(1);
    });

    testWidgets('displays "Unknown Author" when author is null', (tester) async {
      final article = Article(
        title: 'Test Article',
        description: 'Description',
        url: null,
        imageUrl: null,
        publishedAt: null,
        author: null,
      );
      when(() => mockRepository.isBookmarked(article)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget(article));
      await tester.pumpAndSettle();

      expect(find.text('By Unknown Author'), findsOneWidget);
    });
  });
}