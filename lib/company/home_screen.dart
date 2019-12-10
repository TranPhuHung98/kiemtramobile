import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/company/company_item.dart';
import 'package:stdio/company/creat_company_dialog.dart';
import 'package:stdio/home/add_group.dart';
import 'package:stdio/login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.user}) : super(key: key);
  FirebaseUser user;
  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  ChangeEmail changeEmail = ChangeEmail();
  AddGroup addGroup = AddGroup();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  Drawer buildDrawer() {
    return Drawer(
        child: ListView(children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text(
          widget.user.displayName,
          style: TextStyle(fontSize: 17.0),
        ),
        accountEmail: Text(
          widget.user.email,
          style: TextStyle(fontSize: 15.0),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage(widget.user.photoUrl),
          radius: 60.0,
        ),
      ),
      ListTile(
          trailing: Icon(
            Icons.exit_to_app,
            color: Colors.red,
          ),
          title: Text("Log out"),
          onTap: () {
            handleSignOut();
          }),
      FirebaseAnimatedList(
                        query: FirebaseDatabase.instance
                            .reference()
                            .child('Users')
                            .child(changeEmail.changeEmail(widget.user.email))
                            .child("JoinedCompany"),
                        itemBuilder: (BuildContext context,
                            DataSnapshot groupSnapshot,
                            Animation<double> animation,
                            int index) {
                          return CompanyItem(
                            avatar: groupSnapshot.value['avatar'],
                            companyName: groupSnapshot.value['companyName'],
                            companyId: groupSnapshot.key,
                            user: widget.user,
                          );
                        })   
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Home'),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: FirebaseAnimatedList(
                        query: FirebaseDatabase.instance
                            .reference()
                            .child('Users')
                            .child(changeEmail.changeEmail(widget.user.email))
                            .child("JoinedCompany"),
                        itemBuilder: (BuildContext context,
                            DataSnapshot groupSnapshot,
                            Animation<double> animation,
                            int index) {
                          return CompanyItem(
                            avatar: groupSnapshot.value['avatar'],
                            companyName: groupSnapshot.value['companyName'],
                            companyId: groupSnapshot.key,
                            user: widget.user,
                          );
                        })),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 35.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          child: RaisedButton(
              color: Colors.blueAccent[100],
              child: Text('New Workspace',style: TextStyle(color: Colors.white),),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => CreatCompanyDialog(
                          user: widget.user,
                        ));
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0))),
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  _openAddItemDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => CreatCompanyDialog(
              user: widget.user,
            ));
  }
}
