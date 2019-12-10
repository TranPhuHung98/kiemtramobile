import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stdio/home/add_group.dart';

class AddGroupDialog extends StatefulWidget {
  String companyId ;
  @override
  FirebaseUser user;
  AddGroupDialog({Key key, this.user,this.companyId}) : super(key: key);
  AddGroupDialogState createState() {
    return new AddGroupDialogState();
  }
}

class AddGroupDialogState extends State<AddGroupDialog> {
  String groupName;
  AddGroup addGroup = AddGroup();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Group'),
      contentPadding: const EdgeInsets.all(16.0),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            autofocus: true,
            decoration: new InputDecoration(
                labelText: "Group Name", hintText: "Group Name"),
            onChanged: (text) {
              setState(() {
                groupName = text;
              });
            },
          ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("Cancel")),
        new FlatButton(
            onPressed: () {
              addGroup.onAddGroup(widget.companyId, groupName, widget.user);
              Navigator.pop(context);
            },
            child: new Text("Add"))
      ],
    );
  }
}
