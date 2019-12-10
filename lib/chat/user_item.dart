import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/chat/add_user.dart';
import 'package:stdio/chat/dialog.dart';

class BuildItemUserInCompany extends StatefulWidget {
  String companyId;
  DataSnapshot dataSnapshot;
  Animation animation;
  String groupId;
  String groupName;
  String groupAvatar;
  BuildItemUserInCompany(
      {Key key,
      this.dataSnapshot,
      this.animation,
      this.groupId,
      this.groupName,
      this.companyId,
      this.groupAvatar});
  @override
  State<StatefulWidget> createState() {
    return _BuildItemUserInCompanyState();
  }
}

class _BuildItemUserInCompanyState extends State<BuildItemUserInCompany> {
  AddUser addUser = AddUser();
  final googleSignIn = new GoogleSignIn();
  Widget buildItem(BuildContext context) {
    return Container(
      height: 70.0,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
      child: Center(
        child: ListTile(
          title: Text('${widget.dataSnapshot.value['name']}'),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.dataSnapshot.value['avatar']),
          ),
          subtitle: Text('${widget.dataSnapshot.value['email']}'),
          onTap: () {
            if (widget.groupName != null) {
              dialogAddUser(context);
            }
          },
        ),
      ),
    );
  }

  Future<bool> dialogAddUser(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Do you want to add this user ?'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    bool isJoined = true;
                    addUser
                        .onAddUser(
                            widget.dataSnapshot.value['email'],
                            widget.dataSnapshot.value['avatar'],
                            widget.dataSnapshot.value['name'],
                            widget.groupId,
                            widget.groupName,
                            widget.groupAvatar,
                            widget.companyId)
                        .then((onValue) {
                      isJoined = onValue;
                      Navigator.of(context).pop(true);
                      showDialog(
                          context: context,
                          child: AddItemDialog(
                              message: isJoined
                                  ? 'This user has been added.'
                                  : 'Success!!!'));
                    });
                  },
                  child: Text('Yes')),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return buildItem(context);
  }
}
