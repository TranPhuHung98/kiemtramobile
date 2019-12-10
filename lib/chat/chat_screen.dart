import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/chat/add_user.dart';
import 'package:stdio/chat/list_message.dart';
import 'package:stdio/chat/send_mess.dart';
import 'package:stdio/chat/users_screen.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  String companyId;
  String groupName;
  String groupId;
  FirebaseUser user;
  SendMessage sendMess = SendMessage();
  ChatScreen({Key key, this.groupName, this.user, this.groupId, this.companyId})
      : super(key: key);

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  AddUser addUser = AddUser();
  SendMessage sendMessage = SendMessage();
  File imageFile;
  String imageUrl;
  bool isLoading = false;
  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imageFile = image;
        isLoading = true;
      });
    }
    await uploadFile();
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    reference.putFile(imageFile).onComplete.then((_) {
      reference.getDownloadURL().then((dynamic value) {
        imageUrl = value.toString();
        setState(() {
          isLoading = false;
        });

        sendMessage.onSendMessage(
            imageUrl, 1, widget.groupId, widget.companyId);
      });
    });
  }

  ChangeEmail changeEmail =ChangeEmail();
  @override
  void dispose() {
    FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}')
        .update({"timeSeenMessage": DateTime.now().millisecondsSinceEpoch.toString()});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.group_add),
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (_) => UserScreen(
          //             companyId: widget.companyId,
          //             user: widget.user,
          //             groupId: widget.groupId,
          //             groupName: widget.groupName)));
          //   },
          // )
        ],
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new FirebaseAnimatedList(
                query: FirebaseDatabase.instance
                    .reference()
                    .child("Company")
                    .child(widget.companyId)
                    .child('Group')
                    .child('${widget.groupId}')
                    .child('message'),
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                sort: (a, b) => b.key.compareTo(a.key),
                itemBuilder: (_, DataSnapshot messageSnapshot,
                    Animation<double> animation, int index) {
                  return new ChatMessageListItem(
                    messageSnapshot: messageSnapshot,
                    animation: animation,
                    currentUserEmail: widget.user.email,
                  );
                },
              ),
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                icon: new Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () async {
                  getImage();
                }),
          ),
          new Flexible(
            child: new TextField(
              autofocus: true,
              controller: _textEditingController,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () {
                    sendMessage.onSendMessage(_textEditingController.text, 0,
                        widget.groupId, widget.companyId);
                    _textEditingController.clear();
                  })),
        ],
      ),
    );
  }
}
