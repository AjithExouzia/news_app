part of 'simple_news_bloc.dart';

@immutable
abstract class SimpleNewsState extends Equatable {
  const SimpleNewsState();

  @override
  List<Object?> get props => [];
}

class SimpleNewsInitial extends SimpleNewsState {}

class SimpleNewsLoading extends SimpleNewsState {}

class SimpleNewsLoadingMore extends SimpleNewsState {
  final List<Article> articles;

  const SimpleNewsLoadingMore({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class SimpleNewsLoaded extends SimpleNewsState {
  final List<Article> articles;
  final bool hasReachedMax;

  const SimpleNewsLoaded({required this.articles, required this.hasReachedMax});

  @override
  List<Object?> get props => [articles, hasReachedMax];
}

class SimpleNewsError extends SimpleNewsState {
  final String message;

  const SimpleNewsError(this.message);

  @override
  List<Object?> get props => [message];
}
