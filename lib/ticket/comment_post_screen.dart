import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/ticket/comment_onpress.dart';
import 'package:stdio/ticket/list_comment.dart';

class CommentPostScreen extends StatefulWidget {
  String groupName;
  String groupId;
  String companyId;
  DataSnapshot dataSnapshot;
  Animation animation;
  bool isLiked;
  int numberLiked;
  CommentPostScreen(
      {Key key,
      this.dataSnapshot,
      this.animation,
      this.groupName,
      this.groupId,
      this.companyId,
      this.isLiked,
      this.numberLiked})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CommentPostScreenState();
  }
}

class CommentPostScreenState extends State<CommentPostScreen> {
  ChangeEmail changeEmail = ChangeEmail();
  final TextEditingController _textEditingController =
      new TextEditingController();
  Comment postComment = Comment();
  File imageFile;
  String imageUrl;
  bool isLoading = false;
  // bool isLiked = false;
  @override
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  String quantityLiked;
  getUser() async {
    firebaseUser = await _auth.currentUser();
  }

  countLiked() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnapshot.key}/listUserLiked")
        .once()
        .then((onValue) {
      print('dddddddddddddddddddddddddddddddddddddđ $onValue');
      setState(() {
        onValue == null
            ? quantityLiked = "Hãy là người đầu tiên bình luận nội dung này"
            : quantityLiked = onValue.value.lenght.toString();
      });
      print(quantityLiked);
    });
  }

  @override
  void initState() {
    getUser();
    // isLiked = widget.isLiked;
    countLiked();
    super.initState();
  }

  void dispose() {
    FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}')
        .update({
      "timeSeenComment": DateTime.now().millisecondsSinceEpoch.toString()
    });
    FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}')
        .update(
            {"timeSeenPost": DateTime.now().millisecondsSinceEpoch.toString()});
    super.dispose();
  }

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

        postComment.onComment(0, widget.groupId, widget.dataSnapshot.key,
            imageUrl, widget.companyId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    countLiked();
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     "Comment",
        //     style: TextStyle(color: Colors.black),
        //   ),
        //   // centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   actions: <Widget>[
        //     Row(
        //       children: <Widget>[
        //         Text(
        //           '10 ',
        //           style: TextStyle(color: Colors.blue, fontSize: 20),
        //         ),
        //         Icon(
        //           Icons.thumb_up,
        //           color: Colors.blue,
        //           size: 25,
        //         ),
        //       ],
        //     )
        //   ],
        // ),
        body: Card(
      child: Column(
        children: <Widget>[
          Container(
            padding:
                EdgeInsets.only(left: 8.0, right: 8, top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Comment', style: TextStyle(fontSize: 22)),
                Row(
                  children: <Widget>[
                    Text(
                      '${widget.numberLiked.toString()} ',
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                    Icon(
                      Icons.thumb_up,
                      color: Colors.blue,
                      size: 25,
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          Flexible(
            child: new FirebaseAnimatedList(
              query: FirebaseDatabase.instance
                  .reference()
                  .child("Company")
                  .child(widget.companyId)
                  .child('Group')
                  .child('${widget.groupId}')
                  .child('post')
                  .child(widget.dataSnapshot.key)
                  .child('comment'),
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              sort: (a, b) => b.key.compareTo(a.key),
              itemBuilder: (_, DataSnapshot dataSnapshotcm,
                  Animation<double> animation, int index) {
                return CommentItem(
                    dataSnapshot: dataSnapshotcm, animation: animation);
              },
            ),
          ),
          new Divider(height: 1.0),
          new Container(
            padding: EdgeInsets.only(left: 0),
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    ));
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Container(
            // margin: new EdgeInsets.symmetric(horizontal: 0.0),
            // padding: EdgeInsets.only(left: 0),
            // margin: EdgeInsets.only(left: 10),
            child: new IconButton(
                icon: new Icon(
                  Icons.photo_camera,
                  color: Colors.grey,
                  size: 30,
                ),
                onPressed: () async {
                  getImage();
                }),
          ),
          new Flexible(
            child: new TextField(
              controller: _textEditingController,
              decoration: new InputDecoration.collapsed(
                  hintText: "Type your comment..."),
            ),
          ),
          new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: new Icon(
                    Icons.send,
                    color: _textEditingController.text == ""
                        ? Colors.grey
                        : Colors.blue,
                  ),
                  onPressed: () {
                    postComment.onComment(
                        1,
                        widget.groupId,
                        widget.dataSnapshot.key,
                        _textEditingController.text,
                        widget.companyId);
                    _textEditingController.clear();
                  })),
        ],
      ),
    );
  }
}
