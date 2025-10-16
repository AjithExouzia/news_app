part of 'simple_news_bloc.dart';

@immutable
abstract class SimpleNewsEvent extends Equatable {
  const SimpleNewsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNewsEvent extends SimpleNewsEvent {
  final String? query;

  const FetchNewsEvent({this.query});

  @override
  List<Object?> get props => [query];
}

class LoadMoreNewsEvent extends SimpleNewsEvent {
  const LoadMoreNewsEvent();

  @override
  List<Object?> get props => [];
}

class SearchNewsEvent extends SimpleNewsEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
