import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/article.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';

class ArticleDetails extends StatefulWidget {
  final Article article;

  const ArticleDetails({super.key, required this.article});

  @override
  State<ArticleDetails> createState() => _ArticleDetailsState();
}

class _ArticleDetailsState extends State<ArticleDetails> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  void _checkBookmarkStatus() async {
    // Check bookmark status directly from repository without emitting state
    final repository = context.read<ArticleBloc>().repository;
    final isBookmarked = await repository.isBookmarked(widget.article);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  void _toggleBookmark() {
    if (_isBookmarked) {
      context.read<ArticleBloc>().add(RemoveBookmark(article: widget.article));
    } else {
      context.read<ArticleBloc>().add(BookmarkArticle(article: widget.article));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          BlocListener<ArticleBloc, ArticleState>(
            listener: (context, state) {
              if (state is ArticleLoaded) {
                // Update bookmark status from the loaded state
                setState(() {
                  _isBookmarked = state.isBookmarked;
                });
                // Show snackbar message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.isBookmarked
                          ? 'Article bookmarked'
                          : 'Bookmark removed',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is BookmarkToggled) {
                setState(() {
                  _isBookmarked = state.isBookmarked;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.isBookmarked
                          ? 'Article bookmarked'
                          : 'Bookmark removed',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              onPressed: _toggleBookmark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (widget.article.url != null) {
                Share.share(widget.article.url!);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.imageUrl != null)
              Image.network(
                widget.article.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 100),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${widget.article.author ?? "Unknown Author"}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  if (widget.article.publishedAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy - HH:mm')
                          .format(widget.article.publishedAt!),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.article.description ?? 'No description available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}