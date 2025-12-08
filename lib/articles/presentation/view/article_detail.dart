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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),

        actions: [
          BlocBuilder<ArticleBloc, ArticleState>(
            buildWhen: (previous, current) {
              final prevBookmarked = previous is ArticleLoaded
                  ? previous.isBookmarked
                  : (previous is BookmarkToggled
                        ? previous.isBookmarked
                        : false);

              final currBookmarked = current is ArticleLoaded
                  ? current.isBookmarked
                  : (current is BookmarkToggled ? current.isBookmarked : false);

              return prevBookmarked != currBookmarked;
            },
            builder: (context, state) {
              final isBookmarked = state is ArticleLoaded
                  ? state.isBookmarked
                  : (state is BookmarkToggled ? state.isBookmarked : false);

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  if (isBookmarked) {
                    context.read<ArticleBloc>().add(
                      RemoveBookmark(article: widget.article),
                    );
                  } else {
                    context.read<ArticleBloc>().add(
                      BookmarkArticle(article: widget.article),
                    );
                  }
                },
              );
            },
          ),

          BlocListener<ArticleBloc, ArticleState>(
            listenWhen: (previous, current) {
              return current is ArticleLoaded || current is BookmarkToggled;
            },
            listener: (context, state) {
              if (state is ArticleLoaded) {
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
            child: const SizedBox.shrink(),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  if (widget.article.publishedAt != null)
                    Text(
                      DateFormat(
                        'MMM dd, yyyy - HH:mm',
                      ).format(widget.article.publishedAt!),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
