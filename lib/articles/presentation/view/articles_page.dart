import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/connectivity_service.dart';
import '../../domain/article.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
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
    context.read<ArticleBloc>().add(
      LoadTopHeadlines(countryCode: _currentCountryCode),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoadingMore = false;

  void _onScroll() async {
    if (_isBottom && !_isLoadingMore) {
      final isConnected = await context.read<ConnectivityService>().isConnected;

      if (!isConnected) {
        return;
      }

      final state = context.read<ArticleBloc>().state;
      if (state is ArticleLoaded && !state.hasReachedMax) {
        _isLoadingMore = true;
        if (_isSearchMode && _currentSearchQuery.isNotEmpty) {
          context.read<ArticleBloc>().add(
            LoadMoreArticles(
              query: _currentSearchQuery,
              page: state.currentPage + 1,
            ),
          );
        } else {
          context.read<ArticleBloc>().add(
            LoadMoreHeadlines(
              countryCode: _currentCountryCode,
              page: state.currentPage + 1,
            ),
          );
        }

        Future.delayed(Duration(milliseconds: 500), () {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    final isConnected = await context.read<ConnectivityService>().isConnected;

    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please turn on WiFi to refresh'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSearchMode = false;
      _currentSearchQuery = '';
    });
    context.read<ArticleBloc>().add(
      LoadTopHeadlines(countryCode: _currentCountryCode),
    );

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
        title: Text(
          _isSearchMode ? 'Search: $_currentSearchQuery' : 'Top Headlines',
        ),
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
                    return _buildArticlesList(
                      state.articles,
                      state.hasReachedMax,
                    );
                  } else if (state is ArticleError) {
                    final isNetworkError =
                        state.message.toLowerCase().contains('socket') ||
                        state.message.toLowerCase().contains('client') ||
                        state.message.toLowerCase().contains('failed');

                    return ListView(
                      children: [
                        SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isNetworkError
                                    ? Icons.wifi_off
                                    : Icons.error_outline,
                                size: 60,
                                color: isNetworkError
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                isNetworkError
                                    ? 'Please turn on WiFi'
                                    : 'Something went wrong',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  isNetworkError
                                      ? 'Connect to the internet to load articles'
                                      : state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _onRefresh,
                                icon: Icon(Icons.refresh),
                                label: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
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
      itemCount: articles.length + 1,
      itemBuilder: (context, index) {
        if (index >= articles.length) {
          if (hasReachedMax) {
            if (!_isOnline) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Please turn on WiFi',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
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