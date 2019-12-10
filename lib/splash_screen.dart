import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/company/home_screen.dart';
import 'package:stdio/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  FirebaseUser firebaseUser  ;
  void isSignedIn() async {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      firebaseUser = await _auth.currentUser();
  }
  startTime() async {
    var _duration = new Duration(seconds: 5);
    return Timer(_duration, navigationPage);
  }

  Future navigationPage() async {
    firebaseUser == null
        ? Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()))
        : Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(user: firebaseUser,)));
  }

  @override
  void initState() {
    super.initState();
    startTime();
    isSignedIn();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Image.asset(
      "images/splash.png",
      fit: BoxFit.fill,
      width: 500.0,
    ));
  }
}
