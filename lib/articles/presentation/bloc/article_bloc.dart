import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/article_repository.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository repository;

  ArticleBloc({required this.repository}) : super(ArticleInitial()) {
    on<LoadTopHeadlines>(_onLoadTopHeadlines);
    on<LoadMoreHeadlines>(_onLoadMoreHeadlines);
    on<SearchArticles>(_onSearchArticles);
    on<LoadBookmarkedArticles>(_onLoadBookmarkedArticles);
    on<LoadMoreArticles>(_onLoadMoreArticles);
    on<BookmarkArticle>(_onBookmarkArticle);
    on<RemoveBookmark>(_onRemoveBookmark);
    on<CheckBookmarkStatus>(_onCheckBookmarkStatus);
  }

  Future<void> _onLoadTopHeadlines(
      LoadTopHeadlines event,
      Emitter<ArticleState> emit,
      ) async {
    emit(ArticleLoading());
    try {
      final articles = await repository.getTopHeadlines(
        countryCode: event.countryCode,
      );
      emit(ArticleLoaded(articles: articles));
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreHeadlines(
      LoadMoreHeadlines event,
      Emitter<ArticleState> emit,
      ) async {
    if (state is ArticleLoaded) {
      final currentState = state as ArticleLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final newArticles = await repository.getTopHeadlines(
          countryCode: event.countryCode,
          page: event.page,
        );

        if (newArticles.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(currentState.copyWith(
            articles: List.of(currentState.articles)..addAll(newArticles),
            hasReachedMax: false,
            currentPage: event.page,
          ));
        }
      } catch (e) {
        emit(ArticleError(message: e.toString()));
      }
    }
  }

  Future<void> _onSearchArticles(
      SearchArticles event,
      Emitter<ArticleState> emit,
      ) async {
    emit(ArticleLoading());
    try {
      final articles = await repository.searchArticles(event.query, page: 1);
      emit(ArticleLoaded(articles: articles, currentPage: 1));
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreArticles(
      LoadMoreArticles event,
      Emitter<ArticleState> emit,
      ) async {
    if (state is ArticleLoaded) {
      final currentState = state as ArticleLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final newArticles = await repository.searchArticles(
          event.query,
          page: event.page,
        );

        if (newArticles.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(currentState.copyWith(
            articles: List.of(currentState.articles)..addAll(newArticles),
            hasReachedMax: false,
            currentPage: event.page,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(hasReachedMax: true));
      }
    }
  }

  Future<void> _onLoadBookmarkedArticles(
      LoadBookmarkedArticles event,
      Emitter<ArticleState> emit,
      ) async {
    emit(ArticleLoading());
    try {
      final articles = await repository.getBookmarkedArticles();
      emit(ArticleLoaded(articles: articles));
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onBookmarkArticle(
      BookmarkArticle event,
      Emitter<ArticleState> emit,
      ) async {
    try {
      await repository.bookmarkArticle(event.article);
      // Preserve current state if it's ArticleLoaded
      if (state is ArticleLoaded) {
        final currentArticles = (state as ArticleLoaded).articles;
        emit(ArticleLoaded(articles: currentArticles, isBookmarked: true));
      } else {
        emit(const BookmarkToggled(isBookmarked: true));
      }
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onRemoveBookmark(
      RemoveBookmark event,
      Emitter<ArticleState> emit,
      ) async {
    try {
      await repository.removeBookmark(event.article);
      // Preserve current state if it's ArticleLoaded
      if (state is ArticleLoaded) {
        final currentArticles = (state as ArticleLoaded).articles;
        emit(ArticleLoaded(articles: currentArticles, isBookmarked: false));
      } else {
        emit(const BookmarkToggled(isBookmarked: false));
      }
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }

  Future<void> _onCheckBookmarkStatus(
      CheckBookmarkStatus event,
      Emitter<ArticleState> emit,
      ) async {
    try {
      final isBookmarked = await repository.isBookmarked(event.article);
      // Don't emit state change if we're in ArticleLoaded to preserve the list
      if (state is! ArticleLoaded) {
        emit(BookmarkStatusChecked(isBookmarked: isBookmarked));
      }
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }
}