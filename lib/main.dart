import 'package:flutter/material.dart';
import 'package:smarthome/views/LightControlPage.dart';
import 'package:smarthome/views/MainPage.dart';
import 'package:smarthome/views/RegisterPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스마트홈',
      theme: ThemeData(
          primarySwatch: Colors.orange,
          secondaryHeaderColor: Colors.deepOrangeAccent),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/register/': (context) => RegisterPage(),
        '/light/': (context) => LightControlPage(),
      },
      darkTheme: ThemeData.dark(),
    );
  }
}