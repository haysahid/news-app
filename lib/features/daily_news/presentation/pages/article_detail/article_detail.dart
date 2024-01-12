import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:flutter_clean_architecture/injection_container.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailsView extends StatelessWidget {
  const ArticleDetailsView({
    super.key,
    required this.article,
  });

  final ArticleEntity? article;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article!.title!,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 14),

          // DateTime
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
              ),
              const SizedBox(width: 14),
              Text(
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(article!.publishedAt!).toLocal()),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.infinity,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      color: Colors.grey.shade300,
      child: article!.urlToImage != null && article!.urlToImage!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: article!.urlToImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                  ),
                );
              },
            )
          : const Center(
              child: Icon(
                Icons.image,
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget _buildArticleDescription() {
    final content = article!.content != null
        ? article!.content!.replaceAll(RegExp(r'(?=\[)(.*?)(?<=\])'), '')
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${article!.description ?? ''}\n\n$content',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 14,
          ),
          if (article!.url != null && article!.url!.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(article!.url!);

                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
              ),
              child: Text(
                'Read more',
                style: TextStyle(
                  color: Colors.blue[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onFloatingActionButtonPressed(context),
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.bookmark,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.black,
      content: Text('Article saved succesfully.'),
    ));
  }
}
