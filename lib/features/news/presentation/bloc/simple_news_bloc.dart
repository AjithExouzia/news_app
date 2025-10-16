import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

part 'simple_news_event.dart';
part 'simple_news_state.dart';

class SimpleNewsBloc extends Bloc<SimpleNewsEvent, SimpleNewsState> {
  final Dio dio = Dio();

  SimpleNewsBloc() : super(SimpleNewsInitial()) {
    on<FetchNewsEvent>(_onFetchNews);
    on<LoadMoreNewsEvent>(_onLoadMoreNews);
    on<SearchNewsEvent>(_onSearchNews);
  }

  final List<Article> _allArticles = [];
  int _currentPage = 1;
  bool _hasReachedMax = false;
  String? _currentQuery;

  Future<void> _onFetchNews(
    FetchNewsEvent event,
    Emitter<SimpleNewsState> emit,
  ) async {
    if (state is SimpleNewsLoading) return;

    emit(SimpleNewsLoading());

    try {
      _currentPage = 1;
      _hasReachedMax = false;
      _allArticles.clear();
      _currentQuery = event.query;

      final news = await _fetchNews(page: _currentPage, query: event.query);
      _allArticles.addAll(news.articles);
      _hasReachedMax = news.articles.length < 20;

      emit(
        SimpleNewsLoaded(
          articles: List.of(_allArticles),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      emit(SimpleNewsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNewsEvent event,
    Emitter<SimpleNewsState> emit,
  ) async {
    if (_hasReachedMax || state is SimpleNewsLoadingMore) return;

    final currentState = state;
    if (currentState is SimpleNewsLoaded) {
      emit(SimpleNewsLoadingMore(articles: _allArticles));
    }

    try {
      _currentPage++;
      final news = await _fetchNews(page: _currentPage, query: _currentQuery);

      if (news.articles.isEmpty) {
        _hasReachedMax = true;
        emit(
          SimpleNewsLoaded(
            articles: List.of(_allArticles),
            hasReachedMax: true,
          ),
        );
      } else {
        _allArticles.addAll(news.articles);
        _hasReachedMax = news.articles.length < 20;
        emit(
          SimpleNewsLoaded(
            articles: List.of(_allArticles),
            hasReachedMax: _hasReachedMax,
          ),
        );
      }
    } catch (e) {
      _currentPage--;
      emit(SimpleNewsError(e.toString()));
    }
  }

  Future<void> _onSearchNews(
    SearchNewsEvent event,
    Emitter<SimpleNewsState> emit,
  ) async {
    add(FetchNewsEvent(query: event.query));
  }

  Future<News> _fetchNews({int page = 1, String? query}) async {
    final params = {
      'country': 'us',
      'apiKey': '3c908d66c17e479980705eaf3ffff95a',
      'page': page,
      'pageSize': 20,
    };

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    final response = await dio.get(
      'https://newsapi.org/v2/top-headlines',
      queryParameters: params,
    );

    return News.fromJson(response.data);
  }
}

class News {
  final String status;
  final int totalResults;
  final List<Article> articles;

  News({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((article) => Article.fromJson(article))
              .toList() ??
          [],
    );
  }
}

class Article {
  final Source source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;

  Article({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source'] ?? {}),
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'],
    );
  }

  @override
  String toString() {
    return 'Article{title: $title}';
  }
}

class Source {
  final String? id;
  final String name;

  Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(id: json['id'], name: json['name'] ?? '');
  }
}
