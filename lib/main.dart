import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stdio/my_app.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(new MyApp());
} 