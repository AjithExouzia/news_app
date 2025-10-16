import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/usecases/get_news_usecase.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNewsUseCase getNews;

  NewsBloc({required this.getNews}) : super(NewsInitial()) {
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMoreNews);
    on<SearchNews>(_onSearchNews);
  }

  final List<ArticleEntity> _allArticles = [];
  int _currentPage = 1;
  bool _hasReachedMax = false;
  String? _currentQuery;

  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    if (state is NewsLoading) return;

    emit(NewsLoading());

    _currentPage = 1;
    _hasReachedMax = false;
    _allArticles.clear();
    _currentQuery = event.query;

    try {
      final news = await getNews(
        NewsParams(page: _currentPage, query: event.query),
      );
      _allArticles.addAll(news.articles);
      _hasReachedMax = news.articles.length < 20;
      emit(
        NewsLoaded(
          articles: List.of(_allArticles),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNews event,
    Emitter<NewsState> emit,
  ) async {
    if (_hasReachedMax || state is NewsLoadingMore) return;

    emit(NewsLoadingMore(articles: _allArticles));

    _currentPage++;

    try {
      final news = await getNews(
        NewsParams(page: _currentPage, query: _currentQuery),
      );
      if (news.articles.isEmpty) {
        _hasReachedMax = true;
      } else {
        _allArticles.addAll(news.articles);
      }
      emit(
        NewsLoaded(
          articles: List.of(_allArticles),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      _currentPage--;
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    add(FetchNews(query: event.query));
  }
}
