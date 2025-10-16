import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/news/presentation/bloc/news_bloc.dart';
import 'features/news/presentation/bloc/simple_news_bloc.dart';
import 'features/news/presentation/pages/news_screen.dart';
import 'injection_container.dart' as di;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => SimpleNewsBloc(),
        child: const NewsScreen(),
      ),
    );
  }
}
