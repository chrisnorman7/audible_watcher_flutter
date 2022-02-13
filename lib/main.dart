import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'authors_loader.dart';

/// The main entry point.
void main() {
  runApp(const MyApp());
}

/// The main app.
class MyApp extends StatelessWidget {
  /// Create an instance.
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    RendererBinding.instance.setSemanticsEnabled(true);
    return MaterialApp(
      title: 'Audible Checker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: AuthorsLoader.routeName,
      routes: {
        AuthorsLoader.routeName: (context) => const AuthorsLoader(),
      },
    );
  }
}
