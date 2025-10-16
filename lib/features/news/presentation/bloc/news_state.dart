part of 'news_bloc.dart';

@immutable
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoadingMore extends NewsState {
  final List<ArticleEntity> articles;

  const NewsLoadingMore({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class NewsLoaded extends NewsState {
  final List<ArticleEntity> articles;
  final bool hasReachedMax;

  const NewsLoaded({required this.articles, required this.hasReachedMax});

  @override
  List<Object?> get props => [articles, hasReachedMax];
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
