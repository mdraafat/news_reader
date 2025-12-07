import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/connectivity_service.dart';
import '../../domain/article.dart';
import '../bloc/article_event.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_state.dart';
import 'article_detail.dart';
import 'bookmarks_page.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final ScrollController _scrollController = ScrollController();
  String _currentSearchQuery = '';
  String _currentCountryCode = 'us';
  bool _isSearchMode = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ArticleBloc>().add(LoadTopHeadlines(countryCode: _currentCountryCode));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoadingMore = false;

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      final state = context.read<ArticleBloc>().state;
      if (state is ArticleLoaded && !state.hasReachedMax) {
        _isLoadingMore = true;
        if (_isSearchMode && _currentSearchQuery.isNotEmpty) {
          // Load more search results
          context.read<ArticleBloc>().add(
            LoadMoreArticles(
              query: _currentSearchQuery,
              page: state.currentPage + 1,
            ),
          );
        } else {
          // Load more headlines
          context.read<ArticleBloc>().add(
            LoadMoreHeadlines(
              countryCode: _currentCountryCode,
              page: state.currentPage + 1,
            ),
          );
        }
        // Reset loading flag after a delay
        Future.delayed(Duration(milliseconds: 500), () {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isSearchMode = false;
      _currentSearchQuery = '';
    });
    context.read<ArticleBloc>().add(
      LoadTopHeadlines(countryCode: _currentCountryCode),
    );
    // Wait for the bloc to emit a new state
    await Future.delayed(Duration(seconds: 1));
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Articles'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter search term',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              setState(() {
                _currentSearchQuery = query;
                _isSearchMode = true;
              });
              this.context.read<ArticleBloc>().add(
                SearchArticles(query: query),
              );
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                setState(() {
                  _currentSearchQuery = query;
                  _isSearchMode = true;
                });
                this.context.read<ArticleBloc>().add(
                  SearchArticles(query: query),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSearchMode ? 'Search: $_currentSearchQuery' : 'Top Headlines'),
        actions: [
          SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ArticleBloc>(),
                    child: const BookmarksPage(),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Connectivity Banner
          StreamBuilder<bool>(
            stream: context.read<ConnectivityService>().connectivityStream,
            initialData: true,
            builder: (context, snapshot) {
              _isOnline = snapshot.data ?? true;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isOnline ? 0 : 40,
                child: _isOnline
                    ? const SizedBox.shrink()
                    : Container(
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      'You are offline',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          // Articles List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<ArticleBloc, ArticleState>(
                builder: (context, state) {
                  if (state is ArticleInitial) {
                    return Center(child: Text('Loading news articles...'));
                  } else if (state is ArticleLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ArticleLoaded) {
                    if (state.articles.isEmpty) {
                      return Center(child: Text('No articles found'));
                    }
                    return _buildArticlesList(state.articles, state.hasReachedMax);
                  } else if (state is ArticleError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red),
                          SizedBox(height: 16),
                          Text(state.message),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _onRefresh,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList(List<Article> articles, bool hasReachedMax) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: articles.length + 1, // Always show loading indicator slot
      itemBuilder: (context, index) {
        if (index >= articles.length) {
          // Show loading indicator or end message based on state
          if (hasReachedMax) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No more articles available'),
              ),
            );
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final article = articles[index];
        return ListTile(
          leading: article.imageUrl != null
              ? Image.network(
            article.imageUrl!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: Icon(Icons.image),
              );
            },
          )
              : Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: Icon(Icons.article),
          ),
          title: Text(
            article.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            article.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetails(article: article),
              ),
            );
          },
        );
      },
    );
  }
}