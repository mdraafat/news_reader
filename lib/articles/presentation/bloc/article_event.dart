import 'package:equatable/equatable.dart';
import '../../domain/article.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopHeadlines extends ArticleEvent {
  final String countryCode;

  const LoadTopHeadlines({this.countryCode = 'us'});

  @override
  List<Object?> get props => [countryCode];
}

class SearchArticles extends ArticleEvent {
  final String query;

  const SearchArticles({required this.query});

  @override
  List<Object?> get props => [query];
}

class LoadBookmarkedArticles extends ArticleEvent {
  const LoadBookmarkedArticles();
}

class BookmarkArticle extends ArticleEvent {
  final Article article;

  const BookmarkArticle({required this.article});

  @override
  List<Object?> get props => [article];
}

class RemoveBookmark extends ArticleEvent {
  final Article article;

  const RemoveBookmark({required this.article});

  @override
  List<Object?> get props => [article];
}

class CheckBookmarkStatus extends ArticleEvent {
  final Article article;

  const CheckBookmarkStatus({required this.article});

  @override
  List<Object?> get props => [article];
}