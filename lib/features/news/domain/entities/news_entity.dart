import 'package:equatable/equatable.dart';

class NewsEntity extends Equatable {
  final String status;
  final int totalResults;
  final List<ArticleEntity> articles;

  const NewsEntity({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  @override
  List<Object?> get props => [status, totalResults, articles];
}

class ArticleEntity extends Equatable {
  final SourceEntity source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;

  const ArticleEntity({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  // Add factory method to convert from JSON
  factory ArticleEntity.fromJson(Map<String, dynamic> json) {
    return ArticleEntity(
      source: SourceEntity.fromJson(json['source'] ?? {}),
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'],
    );
  }

  // Add method to convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [
    source,
    author,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    content,
  ];
}

class SourceEntity extends Equatable {
  final String? id;
  final String name;

  const SourceEntity({this.id, required this.name});

  factory SourceEntity.fromJson(Map<String, dynamic> json) {
    return SourceEntity(id: json['id'], name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name];
}
