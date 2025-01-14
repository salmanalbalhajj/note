import 'package:note/db/db_helper.dart';
import 'package:note/ui/home.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DbHelper.initDB();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'helwoo',
      home: Home(),
    );
  }
}
