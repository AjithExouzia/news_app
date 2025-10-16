import 'package:dio/dio.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/news_entity.dart';

abstract class NewsRemoteDataSource {
  Future<NewsEntity> getTopHeadlines({int page = 1, String? query});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<NewsEntity> getTopHeadlines({int page = 1, String? query}) async {
    final params = {
      'country': ApiConstants.country,
      'apiKey': ApiConstants.apiKey,
      'page': page,
      'pageSize': 20,
    };

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    final response = await dio.get(
      ApiConstants.topHeadlines,
      queryParameters: params,
    );

    return _parseNewsResponse(response.data);
  }

  NewsEntity _parseNewsResponse(Map<String, dynamic> json) {
    return NewsEntity(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((article) => ArticleEntity.fromJson(article))
              .toList() ??
          [],
    );
  }
}
