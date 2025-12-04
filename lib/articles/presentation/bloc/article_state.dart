import 'package:equatable/equatable.dart';
import '../../domain/article.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;
  final bool isBookmarked;

  const ArticleLoaded({
    required this.articles,
    this.isBookmarked = false,
  });

  @override
  List<Object?> get props => [articles, isBookmarked];
}

class ArticleError extends ArticleState {
  final String message;

  const ArticleError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookmarkStatusChecked extends ArticleState {
  final bool isBookmarked;

  const BookmarkStatusChecked({required this.isBookmarked});

  @override
  List<Object?> get props => [isBookmarked];
}

class BookmarkToggled extends ArticleState {
  final bool isBookmarked;

  const BookmarkToggled({required this.isBookmarked});

  @override
  List<Object?> get props => [isBookmarked];
}