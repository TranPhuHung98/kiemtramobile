import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/chat/user_item.dart';

class UserInCompanyScreen extends StatefulWidget {
  String companyId;
  FirebaseUser user;
  UserInCompanyScreen({
    Key key,
    this.user,
    this.companyId,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return UserInCompanyScreenState();
  }
}

class UserInCompanyScreenState extends State<UserInCompanyScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Users in Company'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Stack(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: FirebaseAnimatedList(
                      query: FirebaseDatabase.instance
                          .reference()
                          .child('Company')
                          .child(widget.companyId)
                          .child('users'),
                      itemBuilder: (BuildContext context,
                          DataSnapshot groupSnapshot,
                          Animation<double> animation,
                          int index) {
                        return BuildItemUserInCompany(
                          companyId: widget.companyId,
                          dataSnapshot: groupSnapshot,
                        );
                      })),
            ],
          ),
        ]));
  }
}
