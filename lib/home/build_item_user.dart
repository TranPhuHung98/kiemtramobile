import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stdio/chat/dialog.dart';
import 'package:stdio/home/add_user_to_company.dart';

class BuildUserItem extends StatefulWidget {
  DataSnapshot dataSnapshot;
  Animation animation;
  String companyId;
  String companyName;
  String companyAvatar;
  BuildUserItem(
      {Key key,
      this.dataSnapshot,
      this.animation,
      this.companyId,
      this.companyName,
      this.companyAvatar});
  @override
  State<StatefulWidget> createState() {
    return _BuildUserItemState();
  }
}

class _BuildUserItemState extends State<BuildUserItem> {
  AddUserToCompany addUser = AddUserToCompany();
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
            dialogAddUser(context);
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
                        .onAddUserToCompany(
                            widget.dataSnapshot.value['email'],
                            widget.companyId,
                            widget.companyName,
                            widget.companyAvatar,
                            widget.dataSnapshot.value['avatar'],
                            widget.dataSnapshot.value['name'])
                        .then((values) {
                      isJoined = values;
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
