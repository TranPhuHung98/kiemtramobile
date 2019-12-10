import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stdio/company/creat_company.dart';
import 'package:stdio/home/add_group.dart';

class CreatCompanyDialog extends StatefulWidget {
  @override
  FirebaseUser user;
  CreatCompanyDialog({Key key, this.user}) : super(key: key);
  CreatCompanyDialogState createState() {
    return new CreatCompanyDialogState();
  }
}

class CreatCompanyDialogState extends State<CreatCompanyDialog> {
  String companyName;
  CreatCompany creatCompany = CreatCompany();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Creat Workspace'),
      contentPadding: const EdgeInsets.all(16.0),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            autofocus: true,
            decoration: new InputDecoration(
                labelText: "Workspace Name", hintText: "Workspace Name"),
            onChanged: (text) {
              setState(() {
                companyName = text;
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
              creatCompany.onCreatCompany(companyName, widget.user);
              Navigator.pop(context);
            },
            child: new Text("Add"))
      ],
    );
  }
}
