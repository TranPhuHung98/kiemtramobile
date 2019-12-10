import 'package:flutter/material.dart';
import 'package:stdio/splash_screen.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroCha',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
