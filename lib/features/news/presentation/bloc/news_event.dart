part of 'news_bloc.dart';

@immutable
abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNews extends NewsEvent {
  final String? query;

  const FetchNews({this.query});

  @override
  List<Object?> get props => [query];
}

class LoadMoreNews extends NewsEvent {
  const LoadMoreNews();

  @override
  List<Object?> get props => [];
}

class SearchNews extends NewsEvent {
  final String query;

  const SearchNews(this.query);

  @override
  List<Object?> get props => [query];
}
