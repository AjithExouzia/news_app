import '../../../../core/usecases/usecase.dart';
import '../entities/news_entity.dart';
import '../repositories/news_repository.dart';

class GetNewsUseCase implements UseCase<NewsEntity, NewsParams> {
  final NewsRepository repository;

  GetNewsUseCase(this.repository);

  @override
  Future<NewsEntity> call(NewsParams params) async {
    return await repository.getTopHeadlines(
      page: params.page,
      query: params.query,
    );
  }
}

class NewsParams {
  final int page;
  final String? query;

  NewsParams({required this.page, this.query});
}
