import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/chat/user_item.dart';
import 'package:stdio/home/build_item_user.dart';

class UserScreen extends StatefulWidget {
  FirebaseUser user;
  String companyId;
  String companyName;
  UserScreen({Key key, this.user,this.companyId,this.companyName}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return UserScreenState();
  }
}

class UserScreenState extends State<UserScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Users'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Stack(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: FirebaseAnimatedList(
                      query:
                          FirebaseDatabase.instance.reference().child('Users'),
                      itemBuilder: (BuildContext context,
                          DataSnapshot companySnapshot,
                          Animation<double> animation,
                          int index) {
                        return companySnapshot.value['email'] != widget.user.email
                            ? BuildUserItem(
                                dataSnapshot: companySnapshot,
                                animation: animation,
                                companyId: widget.companyId,
                                companyName: widget.companyName,
                              )
                            : Container();
                      })),
            ],
          ),
        ]));
  }
}
