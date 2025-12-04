import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/articles/domain/article.dart';
import 'package:news_reader/articles/domain/article_repository.dart';
import 'package:news_reader/articles/presentation/view/bookmarks_page.dart';


// Mocks
class MockArticleRepository extends Mock implements ArticleRepository {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Fake for registration
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockArticleRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockRepository = MockArticleRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: RepositoryProvider<ArticleRepository>.value(
        value: mockRepository,
        child: const BookmarksPage(),
      ),
    );
  }

  final testArticles = [
    Article(
      title: 'Test Article 1',
      description: 'Description 1',
      url: 'https://test1.com',
      imageUrl: 'https://test1.com/image.jpg',
      publishedAt: DateTime(2024, 1, 1),
      author: 'Author 1',
    ),
    Article(
      title: 'Test Article 2',
      description: 'Description 2',
      url: 'https://test2.com',
      publishedAt: DateTime(2024, 1, 2),
      author: 'Author 2',
    ),
  ];

  group('BookmarksPage', () {
    testWidgets('displays app bar with title', (tester) async {
      when(() => mockRepository.getBookmarkedArticles())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows empty state when no bookmarks exist', (tester) async {
      when(() => mockRepository.getBookmarkedArticles())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsOneWidget);
    });

    testWidgets('displays list of bookmarked articles', (tester) async {
      when(() => mockRepository.getBookmarkedArticles())
          .thenAnswer((_) async => testArticles);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test Article 1'), findsOneWidget);
      expect(find.text('Test Article 2'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
    });

    testWidgets('displays article image when imageUrl is available',
            (tester) async {
          when(() => mockRepository.getBookmarkedArticles())
              .thenAnswer((_) async => testArticles);

          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();

          expect(find.byType(Image), findsWidgets);
        });

    testWidgets('displays placeholder icon when imageUrl is null',
            (tester) async {
          final articlesWithoutImage = [
            Article(
              title: 'Test Article',
              description: 'Description',
              url: 'https://test.com',
            ),
          ];

          when(() => mockRepository.getBookmarkedArticles())
              .thenAnswer((_) async => articlesWithoutImage);

          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.article), findsOneWidget);
        });

    testWidgets('shows error message when loading fails', (tester) async {
      when(() => mockRepository.getBookmarkedArticles())
          .thenThrow(Exception('Failed to load bookmarks'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Exception: Failed to load bookmarks'), findsOneWidget);
    });

    testWidgets('truncates long titles and descriptions', (tester) async {
      final longArticle = [
        Article(
          title: 'Very Long Title ' * 20,
          description: 'Very Long Description ' * 20,
          url: 'https://test.com',
        ),
      ];

      when(() => mockRepository.getBookmarkedArticles())
          .thenAnswer((_) async => longArticle);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(Text),
        ).first,
      );

      expect(titleText.maxLines, 2);
      expect(titleText.overflow, TextOverflow.ellipsis);
    });
  });
}