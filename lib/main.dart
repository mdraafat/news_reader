import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'articles/data/article_local_datasource_impl.dart';
import 'articles/data/article_remote_datasource_impl.dart';
import 'articles/data/article_repository_impl.dart';
import 'articles/domain/article_local_datasource.dart';
import 'articles/domain/article_remote_datasource.dart';
import 'articles/domain/article_repository.dart';
import 'articles/presentation/bloc/article_bloc.dart';
import 'articles/presentation/view/articles_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatelessWidget {

  final SharedPreferences prefs;
  const MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<http.Client>(
          create: (context) => http.Client(),
        ),
        RepositoryProvider<ArticleRemoteDatasource>(
          create: (context) => ArticleRemoteDatasourceImpl(
            client: context.read<http.Client>(),
          ),
        ),
        RepositoryProvider<ArticleLocalDatasource>(
          create: (context) => ArticleLocalDatasourceImpl(prefs: prefs),
        ),
        RepositoryProvider<ArticleRepository>(
          create: (context) => ArticleRepositoryImpl(
            remoteDatasource: context.read<ArticleRemoteDatasource>(), localDatasource: context.read<ArticleLocalDatasource>(),
    ),
        ),
      ],
      child: BlocProvider(
        create: (context) => ArticleBloc(
          repository: context.read<ArticleRepository>(),
        ),
        child: MaterialApp(
          title: 'News Reader',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              elevation: 0,
            ),
          ),
          home: const ArticlesPage(),
        ),
      ),
    );
  }
}