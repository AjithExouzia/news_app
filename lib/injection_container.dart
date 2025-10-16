import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'features/news/data/datasources/news_remote_data_source.dart';
import 'features/news/data/repositories/news_repository_impl.dart';
import 'features/news/domain/repositories/news_repository.dart';
import 'features/news/domain/usecases/get_news_usecase.dart';
import 'features/news/presentation/bloc/news_bloc.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';

class DependencyInjector {
  static final DependencyInjector _instance = DependencyInjector._internal();
  factory DependencyInjector() => _instance;
  DependencyInjector._internal();

  // Singleton instances
  DioClient? _dioClient;
  Connectivity? _connectivity;
  NetworkInfo? _networkInfo;
  NewsRemoteDataSource? _newsRemoteDataSource;
  NewsRepository? _newsRepository;
  GetNewsUseCase? _getNewsUseCase;
  NewsBloc? _newsBloc;

  DioClient get dioClient {
    _dioClient ??= DioClient();
    return _dioClient!;
  }

  Dio get dio => dioClient.dio;

  Connectivity get connectivity {
    _connectivity ??= Connectivity();
    return _connectivity!;
  }

  NetworkInfo get networkInfo {
    _networkInfo ??= NetworkInfoImpl(connectivity);
    return _networkInfo!;
  }

  NewsRemoteDataSource get newsRemoteDataSource {
    _newsRemoteDataSource ??= NewsRemoteDataSourceImpl(dio: dio);
    return _newsRemoteDataSource!;
  }

  NewsRepository get newsRepository {
    _newsRepository ??= NewsRepositoryImpl(
      remoteDataSource: newsRemoteDataSource,
      networkInfo: networkInfo,
    );
    return _newsRepository!;
  }

  GetNewsUseCase get getNewsUseCase {
    _getNewsUseCase ??= GetNewsUseCase(newsRepository);
    return _getNewsUseCase!;
  }

  NewsBloc get newsBloc {
    _newsBloc ??= NewsBloc(getNews: getNewsUseCase);
    return _newsBloc!;
  }

  void dispose() {
    _newsBloc?.close();
    _newsBloc = null;
    _getNewsUseCase = null;
    _newsRepository = null;
    _newsRemoteDataSource = null;
    _networkInfo = null;
    _connectivity = null;
    _dioClient = null;
  }
}

final di = DependencyInjector();
