import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? author;
  final String? language;

  const Article({
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
    this.author,
    this.language,
  });

  @override
  List<Object?> get props => [title, description, url, imageUrl, publishedAt, author, language];
}