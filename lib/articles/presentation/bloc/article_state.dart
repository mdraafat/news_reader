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
  final bool hasReachedMax;
  final int currentPage;

  const ArticleLoaded({
    required this.articles,
    this.isBookmarked = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [articles, isBookmarked, hasReachedMax, currentPage];

  ArticleLoaded copyWith({
    List<Article>? articles,
    bool? isBookmarked,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ArticleLoaded(
      articles: articles ?? this.articles,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
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