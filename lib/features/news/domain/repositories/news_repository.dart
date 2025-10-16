import '../entities/news_entity.dart';

abstract class NewsRepository {
  Future<NewsEntity> getTopHeadlines({int page = 1, String? query});
}
