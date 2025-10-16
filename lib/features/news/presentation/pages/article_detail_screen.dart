import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../bloc/simple_news_bloc.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    final isLargeScreen = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: isSmallScreen ? 250 : (isMediumScreen ? 300 : 350),
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'article-image-${article.url}',
                child:
                    article.urlToImage != null && article.urlToImage!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.blue[300]!,
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.article_outlined,
                                      size:
                                          isSmallScreen
                                              ? 48
                                              : (isMediumScreen ? 56 : 64),
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
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
                        )
                        : Container(
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size:
                                    isSmallScreen
                                        ? 48
                                        : (isMediumScreen ? 56 : 64),
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No image',
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
            leading: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    onPressed: () {
                      _shareArticle(context);
                    },
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
            ],
          ),

          // Article Content
          SliverToBoxAdapter(
            child: Container(
              constraints: isLargeScreen ? BoxConstraints(maxWidth: 800) : null,
              margin:
                  isLargeScreen
                      ? EdgeInsets.symmetric(
                        horizontal: (screenWidth - 800) / 2,
                      )
                      : null,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and Published Date
                    _buildSourceAndDateSection(context, isSmallScreen),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Article Title
                    Hero(
                      tag: 'article-title-${article.url}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          article.title,
                          style: TextStyle(
                            fontSize:
                                isSmallScreen ? 22 : (isLargeScreen ? 32 : 28),
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Author section
                    if (article.author != null && article.author!.isNotEmpty)
                      _buildAuthorSection(isSmallScreen),

                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // FULL DESCRIPTION SECTION
                    _buildDescriptionSection(isSmallScreen),

                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // FULL ARTICLE CONTENT - Enhanced to show complete content
                    _buildFullArticleContent(isSmallScreen),

                    // Additional spacing for better layout
                    SizedBox(height: isSmallScreen ? 32 : 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceAndDateSection(BuildContext context, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: isSmallScreen ? 8 : 12,
        runSpacing: isSmallScreen ? 8 : 12,
        children: [
          // Source
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[500]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.article_rounded,
                  size: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * (isSmallScreen ? 0.3 : 0.4),
                  ),
                  child: Text(
                    article.source.name,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Date
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Hero(
              tag: 'article-date-${article.url}',
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: isSmallScreen ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      _formatDate(article.publishedAt),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            ),
            child: Icon(
              Icons.person_rounded,
              size: isSmallScreen ? 16 : 20,
              color: Colors.orange[700],
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Written by',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  article.author!,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isSmallScreen) {
    final hasDescription =
        article.description != null &&
        article.description!.isNotEmpty &&
        article.description!.toLowerCase() != 'null';

    if (!hasDescription) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: Colors.grey[600],
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'Article Summary',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              'No summary available for this article.',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                size: isSmallScreen ? 18 : 20,
                color: Colors.blue[700],
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Article Summary',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              article.description!,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                height: 1.6,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullArticleContent(bool isSmallScreen) {
    final hasContent =
        article.content != null &&
        article.content!.isNotEmpty &&
        article.content!.toLowerCase() != 'null';

    if (!hasContent) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          border: Border.all(color: Colors.amber[200]!),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: isSmallScreen ? 18 : 20,
                  color: Colors.amber[600],
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'Full Content Not Available',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              'The complete article content is not available in the API response. Please check the article summary above.',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                height: 1.5,
                color: Colors.amber[800],
              ),
            ),
          ],
        ),
      );
    }

    // Clean up the content
    String cleanedContent =
        article.content!.replaceAll(RegExp(r'\[\+[\d]+\s*chars\]$'), '').trim();

    List<String> paragraphs = _splitContentIntoParagraphs(cleanedContent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.article_rounded,
              size: isSmallScreen ? 18 : 20,
              color: Colors.green[600],
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'Full Article Content',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...paragraphs.map((paragraph) {
                if (paragraph.trim().isEmpty)
                  return SizedBox(height: isSmallScreen ? 12 : 16);

                return Padding(
                  padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                  child: Text(
                    paragraph.trim(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                );
              }).toList(),

              // Content statistics
              SizedBox(height: isSmallScreen ? 12 : 16),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      size: isSmallScreen ? 14 : 16,
                      color: Colors.blue[600],
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      '${paragraphs.length} paragraphs • ${cleanedContent.length} characters',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _splitContentIntoParagraphs(String content) {
    // Try different paragraph separators
    List<String> paragraphs = content.split('\r\n\r\n');
    if (paragraphs.length == 1 ||
        (paragraphs.length == 1 && paragraphs[0].contains('\n\n'))) {
      paragraphs = content.split('\n\n');
    }
    if (paragraphs.length == 1 ||
        (paragraphs.length == 1 && paragraphs[0].contains('\r\n'))) {
      paragraphs = content.split('\r\n');
    }
    if (paragraphs.length == 1) {
      paragraphs = content.split('. ');
      // Add period back to each sentence except the last one
      for (int i = 0; i < paragraphs.length - 1; i++) {
        paragraphs[i] = paragraphs[i] + '.';
      }
    }

    return paragraphs.where((p) => p.trim().isNotEmpty).toList();
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
      return 'Recent';
    }
  }

  void _shareArticle(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share Article',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      Icons.message_rounded,
                      'Message',
                      Colors.green,
                      isSmallScreen,
                    ),
                    _buildShareOption(
                      Icons.email_rounded,
                      'Email',
                      Colors.blue,
                      isSmallScreen,
                    ),
                    _buildShareOption(
                      Icons.link_rounded,
                      'Copy Link',
                      Colors.purple,
                      isSmallScreen,
                    ),
                    _buildShareOption(
                      Icons.more_horiz_rounded,
                      'More',
                      Colors.grey,
                      isSmallScreen,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 10 : 12,
                        ),
                      ),
                      backgroundColor: Colors.grey[100],
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareOption(
    IconData icon,
    String label,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          ),
          child: Icon(icon, size: isSmallScreen ? 24 : 28, color: color),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
