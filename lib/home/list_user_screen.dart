import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/chat/user_item.dart';
import 'package:stdio/home/build_item_user.dart';

class ListUserAddToCompanyScreen extends StatefulWidget {
  FirebaseUser user;
  String companyId;
  String companyName;
  String companyAvatar;
  ListUserAddToCompanyScreen({Key key, this.user,this.companyId,this.companyName,this.companyAvatar}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ListUserAddToCompanyScreenState();
  }
}

class ListUserAddToCompanyScreenState extends State<ListUserAddToCompanyScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Users'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: FirebaseAnimatedList(
            query:
                FirebaseDatabase.instance.reference().child('Users'),
            itemBuilder: (BuildContext context,
                DataSnapshot companySnapshot,
                Animation<double> animation,
                int index) {
              return companySnapshot.value['email'] != widget.user.email
                  ? BuildUserItem(
                      dataSnapshot: companySnapshot,
                      companyId: widget.companyId,
                      companyName: widget.companyName,
                      companyAvatar: widget.companyAvatar,
                    )
                  : Container();
            }));
  }
}
