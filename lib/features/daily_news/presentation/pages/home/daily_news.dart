import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:flutter_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: _buildBody(),
    );
  }

  _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticles(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.bookmark,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  _buildBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (_, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (state is RemoteArticlesError) {
          return const Center(
            child: Icon(Icons.refresh),
          );
        }

        if (state is RemoteArticlesDone) {
          return RefreshIndicator(
            onRefresh: () async {
              _.read<RemoteArticlesBloc>().add(const GetArticles());
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 24,
              ),
              itemBuilder: (context, index) {
                if (state.articles![index].description != '[Removed]') {
                  return GestureDetector(
                    onTap: () =>
                        _onArticlePressed(context, state.articles![index]),
                    child: ArticleWidget(
                      article: state.articles![index],
                    ),
                  );
                }

                return const SizedBox();
              },
              itemCount: state.articles!.length,
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsView(article: article),
      ),
    );
  }

  void _onShowSavedArticles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedArticles(),
      ),
    );
  }
}
