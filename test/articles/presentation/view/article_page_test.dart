import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_reader/articles/domain/article.dart';
import 'package:news_reader/articles/presentation/bloc/article_bloc.dart';
import 'package:news_reader/articles/presentation/bloc/article_event.dart';
import 'package:news_reader/articles/presentation/bloc/article_state.dart';
import 'package:news_reader/articles/presentation/view/articles_page.dart';

class MockArticleBloc extends Mock implements ArticleBloc {}

void main() {
  late MockArticleBloc mockBloc;

  setUpAll(() {
    // Register fallback values for events
    registerFallbackValue(LoadTopHeadlines(countryCode: 'us'));
    registerFallbackValue(SearchArticles(query: ''));
  });

  setUp(() {
    mockBloc = MockArticleBloc();
  });

  Widget makeTestableWidget(Widget child) {
    return BlocProvider<ArticleBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: child,
      ),
    );
  }

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

  group('ArticlesPage', () {
    testWidgets('should show articles list when state is ArticleLoaded',
            (tester) async {
          when(() => mockBloc.state).thenReturn(ArticleLoaded(articles: tArticles));
          when(() => mockBloc.stream)
              .thenAnswer((_) => Stream.value(ArticleLoaded(articles: tArticles)));
          when(() => mockBloc.add(any())).thenReturn(null);

          await tester.pumpWidget(makeTestableWidget(ArticlesPage()));
          await tester.pump();

          expect(find.text('Test Article 1'), findsOneWidget);
          expect(find.text('Test Article 2'), findsOneWidget);
        });

    testWidgets('should show error message when state is ArticleError',
            (tester) async {
          const errorMessage = 'Failed to load articles';
          when(() => mockBloc.state)
              .thenReturn(ArticleError(message: errorMessage));
          when(() => mockBloc.stream)
              .thenAnswer((_) => Stream.value(ArticleError(message: errorMessage)));
          when(() => mockBloc.add(any())).thenReturn(null);

          await tester.pumpWidget(makeTestableWidget(ArticlesPage()));
          await tester.pump();

          expect(find.text(errorMessage), findsOneWidget);
        });

    testWidgets('should dispatch SearchArticles event when search is submitted',
            (tester) async {
          when(() => mockBloc.state).thenReturn(ArticleInitial());
          when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ArticleInitial()));
          when(() => mockBloc.add(any())).thenReturn(null);

          await tester.pumpWidget(makeTestableWidget(ArticlesPage()));
          await tester.tap(find.byIcon(Icons.search));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'flutter');
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle();

          verify(() => mockBloc.add(SearchArticles(query: 'flutter'))).called(1);
        });

    testWidgets('should dispatch LoadTopHeadlines on initial load',
            (tester) async {
          when(() => mockBloc.state).thenReturn(ArticleInitial());
          when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ArticleInitial()));
          when(() => mockBloc.add(any())).thenReturn(null);

          await tester.pumpWidget(makeTestableWidget(ArticlesPage()));

          verify(() => mockBloc.add(LoadTopHeadlines(countryCode: 'us'))).called(1);
        });
  });
}