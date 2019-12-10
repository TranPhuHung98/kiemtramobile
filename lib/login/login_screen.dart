import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/company/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  ChangeEmail changeEmail = ChangeEmail();
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;

  Future<FirebaseUser> _handleSignIn() async {
    setState(() {
      isLoading = true;
    });
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    prefs = await SharedPreferences.getInstance();
    if (user != null) {
      FirebaseDatabase.instance
          .reference()
          .child('Users')
          .child(changeEmail.changeEmail(user.email))
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value == null)
          FirebaseDatabase.instance
              .reference()
              .child("Users")
              .child(changeEmail.changeEmail(user.email))
              .set({
            "name": user.displayName,
            "avatar": user.photoUrl,
            "email": user.email,
          });
      });
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)));
    } else {
      setState(() {
        isLoading = false;
      });
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Stack(
      children: <Widget>[
        Image.asset(
          'images/login.jpg',
          fit: BoxFit.fill,
        ),
        // Container(height: 20.0),
        // Container(
        //   alignment: Alignment(0, -0.6),
        //   child: Image.asset(
        //     'images/logo_stdiohue.png',
        //     height: 25.0,
        //   ),
        // ),
        Container(
          alignment: Alignment(0, 0.8),
          child: Material(
            child: RaisedButton(
                padding: EdgeInsets.only(
                    left: 60.0, right: 60.0, top: 0.0, bottom: 0.0),
                color: Colors.red,
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
                onPressed: () {
                  _handleSignIn();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0))),
          ),
        ),
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),
      ],
    ));
  }
}
