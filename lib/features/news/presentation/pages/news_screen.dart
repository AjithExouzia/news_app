import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../bloc/simple_news_bloc.dart';
import 'article_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<SimpleNewsBloc>().add(const FetchNewsEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<SimpleNewsBloc>().add(const LoadMoreNewsEvent());
    }
  }

  void _onRefresh() async {
    context.read<SimpleNewsBloc>().add(
      FetchNewsEvent(query: _searchController.text),
    );
    _refreshController.refreshCompleted();
  }

  void _debounceSearch(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (query.isEmpty) {
          context.read<SimpleNewsBloc>().add(const FetchNewsEvent());
        } else if (query.length >= 2) {
          context.read<SimpleNewsBloc>().add(SearchNewsEvent(query));
        }
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    context.read<SimpleNewsBloc>().add(const FetchNewsEvent());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _refreshController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    final isLargeScreen = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'News Feed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: Column(
        children: [
          _buildSearchBar(isSmallScreen, isMediumScreen),
          const SizedBox(height: 8),
          _buildSearchInfo(isSmallScreen),
          Expanded(
            child: BlocConsumer<SimpleNewsBloc, SimpleNewsState>(
              listener: (context, state) {
                if (state is SimpleNewsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message.length > 100
                            ? '${state.message.substring(0, 100)}...'
                            : state.message,
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  enablePullDown: true,
                  enablePullUp: false,
                  header: ClassicHeader(
                    height: isSmallScreen ? 50 : 60,
                    refreshingText: 'Fetching latest news...',
                    completeText: 'Refresh completed',
                    failedText: 'Refresh failed',
                    idleText: 'Pull down to refresh',
                    releaseText: 'Release to refresh',
                  ),
                  child: _buildContent(state, isSmallScreen, isLargeScreen),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isSmallScreen ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '🔍 Search news...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: isSmallScreen ? 14 : 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey[500],
            size: isSmallScreen ? 20 : 24,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.clear_rounded,
                        size: isSmallScreen ? 16 : 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 14 : 18,
          ),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          color: Colors.black87,
        ),
        onChanged: _debounceSearch,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<SimpleNewsBloc>().add(SearchNewsEvent(value));
          }
        },
      ),
    );
  }

  Widget _buildSearchInfo(bool isSmallScreen) {
    return BlocBuilder<SimpleNewsBloc, SimpleNewsState>(
      builder: (context, state) {
        if (state is SimpleNewsLoaded && _searchController.text.isNotEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: Colors.blue[600],
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    'Showing results for "${_searchController.text}" • ${state.articles.length} articles found',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _clearSearch,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildContent(
    SimpleNewsState state,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    if (state is SimpleNewsInitial || state is SimpleNewsLoading) {
      return _buildLoadingShimmer(isSmallScreen);
    } else if (state is SimpleNewsError && state is! SimpleNewsLoadingMore) {
      return _buildErrorState(state, isSmallScreen);
    } else if (state is SimpleNewsLoaded || state is SimpleNewsLoadingMore) {
      final articles =
          state is SimpleNewsLoaded
              ? state.articles
              : (state as SimpleNewsLoadingMore).articles;
      final hasReachedMax = state is SimpleNewsLoaded && state.hasReachedMax;

      if (articles.isEmpty) {
        return _buildEmptyState(isSmallScreen);
      }

      return _buildNewsList(
        articles,
        hasReachedMax,
        isSmallScreen,
        isLargeScreen,
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildLoadingShimmer(bool isSmallScreen) {
    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: isSmallScreen ? 160 : 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isSmallScreen ? 12 : 16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: isSmallScreen ? 16 : 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Container(
                      height: isSmallScreen ? 14 : 16,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: isSmallScreen ? 20 : 24,
                          width: isSmallScreen ? 60 : 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          height: isSmallScreen ? 14 : 16,
                          width: isSmallScreen ? 80 : 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(SimpleNewsError state, bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isSmallScreen ? 64 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
              ),
              child: Text(
                state.message.contains('No internet')
                    ? 'Please check your internet connection and try again.'
                    : 'We encountered an error while fetching news. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<SimpleNewsBloc>().add(
                  FetchNewsEvent(query: _searchController.text),
                );
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: isSmallScreen ? 64 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            Text(
              'No Articles Found',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Try adjusting your search or check back later for new articles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_all),
              label: Text(
                'Clear Search',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(
    List<Article> articles,
    bool hasReachedMax,
    bool isSmallScreen,
    bool isLargeScreen,
  ) {
    if (isLargeScreen) {
      return GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: articles.length + (hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= articles.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return NewsItem(
            article: articles[index],
            onTap: () {
              _navigateToDetail(articles[index], context);
            },
            isSmallScreen: isSmallScreen,
          );
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: articles.length + (hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= articles.length) {
          return Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return NewsItem(
          article: articles[index],
          onTap: () {
            _navigateToDetail(articles[index], context);
          },
          isSmallScreen: isSmallScreen,
        );
      },
    );
  }

  void _navigateToDetail(Article article, BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ArticleDetailScreen(article: article),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class NewsItem extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const NewsItem({
    super.key,
    required this.article,
    required this.onTap,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Hero animation
              if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                Hero(
                  tag: 'article-image-${article.url}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isSmallScreen ? 12 : 16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      height: isSmallScreen ? 160 : 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            height: isSmallScreen ? 160 : 200,
                            color: Colors.grey[200],
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: isSmallScreen ? 160 : 200,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article,
                                  size: isSmallScreen ? 40 : 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Source
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: isSmallScreen ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(
                              isSmallScreen ? 6 : 8,
                            ),
                          ),
                          child: Text(
                            article.source.name.length > 20
                                ? '${article.source.name.substring(0, 20)}...'
                                : article.source.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Date
                        Hero(
                          tag: 'article-date-${article.url}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              _formatDate(article.publishedAt),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 8 : 12),

                    Hero(
                      tag: 'article-title-${article.url}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          article.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 6 : 8),

                    if (article.description != null &&
                        article.description!.isNotEmpty)
                      Text(
                        article.description!,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: isSmallScreen ? 8 : 12),

                    if (article.author != null && article.author!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isSmallScreen ? 12 : 14,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: isSmallScreen ? 4 : 6),
                          Expanded(
                            child: Text(
                              'By ${article.author!}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 24) {
        if (difference.inHours < 1) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}
