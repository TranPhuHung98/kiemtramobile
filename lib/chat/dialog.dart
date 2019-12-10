import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  String message;
  AddItemDialog({Key key, this.message}) : super(key: key);
  @override
  AddItemDialogState createState() {
    return new AddItemDialogState();
  }
}

class AddItemDialogState extends State<AddItemDialog> {
  String itemName;
//  ProductsItem product ;

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      content: Text('''${widget.message}'''),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("Ok")),
      ],
    );
  }
}
