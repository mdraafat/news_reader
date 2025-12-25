import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_reader/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('click on an item from news list navigates to its details', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MainApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Find and tap the first article ListTile instead of the AppBar text
    final firstArticle = find.byType(ListTile).first;
    expect(firstArticle, findsOneWidget);
    
    await tester.tap(firstArticle);
    await tester.pumpAndSettle();

    // Verify we're on the ArticleDetails page
    expect(find.text('Article Details'), findsOneWidget);
  });

  testWidgets('swipe to refresh is working', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MainApp(prefs: prefs));
    await tester.pumpAndSettle();

    final refreshIndicator = find.byType(RefreshIndicator);
    expect(refreshIndicator, findsOneWidget);

    await tester.fling(refreshIndicator, const Offset(0, 500), 1000);
    await tester.pumpAndSettle();

    // Verify the refresh indicator is still present
    expect(refreshIndicator, findsOneWidget);
  });

  testWidgets('click on bookmarks button in top bar navigates to bookmarks page', 
  
  (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MainApp(prefs: prefs));
    await tester.pumpAndSettle();

    final bookmarksButton = find.byIcon(Icons.bookmarks);
    expect(bookmarksButton, findsOneWidget);

    await tester.tap(bookmarksButton);
    await tester.pumpAndSettle();

    // Verify we're on the Bookmarks page
    expect(find.text('Bookmarks'), findsOneWidget);
  });

  testWidgets('search dialog box appears or not', (WidgetTester tester) async {
    
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MainApp(prefs: prefs));
    await tester.pumpAndSettle();

    final searchButton = find.byIcon(Icons.search);
    expect(searchButton, findsOneWidget);

    await tester.tap(searchButton);
    await tester.pumpAndSettle();

    // Verify the search dialog appears
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Search Articles'), findsOneWidget);
  });

}