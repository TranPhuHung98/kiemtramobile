import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/company/setting_home_screen.dart';
import 'package:stdio/home/add_group_dialog.dart';
import 'package:stdio/home/group_item.dart';

class HomeCompanyScreen extends StatefulWidget {
  String companyAvatar;
  String companyName ;
  String companyId ;
  HomeCompanyScreen({Key key, this.user,this.companyId,this.companyName,this.companyAvatar}) : super(key: key);
  FirebaseUser user;
  @override
  HomeCompanyScreenState createState() {
    return HomeCompanyScreenState();
  }
}

class HomeCompanyScreenState extends State<HomeCompanyScreen> {
ChangeEmail  changeEmail = ChangeEmail();
  @override
  Widget build(BuildContext context) {
    String _email = changeEmail.changeEmail(widget.user.email);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: widget.companyName.length <= 15
            ? Text('${widget.companyName}')
            : Text('${widget.companyName.substring(0, 14)}...'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingHomeScreen(
                  user: widget.user,
                    companyId: widget.companyId,
                    companyAvatar: widget.companyAvatar,
                    companyName: widget.companyName,
                    ))),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top:10.0),
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
                            .child(_email)
                            .child("JoinedCompany")
                            .child(widget.companyId)
                            .child('JoinedGroup'),
                        itemBuilder: (BuildContext context,
                            DataSnapshot groupSnapshot,
                            Animation<double> animation,
                            int index) {
                          return GroupItem(
                            companyId : widget.companyId,
                            avatar: groupSnapshot.value['avatar'],
                            groupName: groupSnapshot.value['groupName'],
                            groupId: groupSnapshot.key,
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
              child: Text('New Group',style: TextStyle(color: Colors.white)),
              onPressed: () {
                _openAddItemDialog(context);
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
        builder: (context) => AddGroupDialog(companyId: widget.companyId,
              user: widget.user,
            ));
  }
}
