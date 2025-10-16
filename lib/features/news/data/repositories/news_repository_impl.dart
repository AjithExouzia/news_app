import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<NewsEntity> getTopHeadlines({int page = 1, String? query}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteNews = await remoteDataSource.getTopHeadlines(
          page: page,
          query: query,
        );

        // Convert NewsResponseModel to NewsEntity
        return NewsEntity(
          status: remoteNews.status,
          totalResults: remoteNews.totalResults,
          articles:
              remoteNews.articles
                  .map(
                    (articleModel) => ArticleEntity(
                      source: SourceEntity(
                        id: articleModel.source.id,
                        name: articleModel.source.name,
                      ),
                      author: articleModel.author,
                      title: articleModel.title,
                      description: articleModel.description,
                      url: articleModel.url,
                      urlToImage: articleModel.urlToImage,
                      publishedAt: articleModel.publishedAt,
                      content: articleModel.content,
                    ),
                  )
                  .toList(),
        );
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }
}
