import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/ticket/post_onpress.dart';

class PostStatus extends StatefulWidget {
  String groupId;
  String groupName;
  String companyId;
  FirebaseUser user;
  PostStatus({Key key, this.groupId, this.groupName, this.user, this.companyId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PostStatusState();
  }
}

class PostStatusState extends State<PostStatus> {
  TextEditingController _textTextController = new TextEditingController();
  Post post = Post();
  Future<File> _imageFile;
  File imageFile;
  ChangeEmail _changeEmail = ChangeEmail();
  var showImage;

  Future<String> uploadFile(File imageFilePut) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    return await reference.putFile(imageFilePut).onComplete.then((onValue) {
      return onValue.ref.getDownloadURL().then((url) {
        return url.toString();
      });
      // onValue.ref.getDownloadURL().then((dynamic value) {
      //   FirebaseDatabase.instance
      //       .reference()
      //       .child("Company/${widget.companyId}/infor/avatar")
      //       .set(value.toString());
      //   FirebaseDatabase.instance
      //       .reference()
      //       .child(
      //           "Users/${_changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/avatar")
      //       .set(value.toString());
      // });
    });
  }

  Future getImage() async {
    _imageFile = ImagePicker.pickImage(source: ImageSource.gallery);
    return _imageFile;
  }

  Widget _previewImage(Future<File> _imageFile) {
    return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            // return CircleAvatar(
            //   backgroundImage: FileImage(snapshot.data),
            //   radius: 80,
            // );
            return Image.file(snapshot.data);
          } else if (snapshot.error != null) {
            return const Text(
              'Error picking image.',
              textAlign: TextAlign.center,
            );
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Text(
              'You have not yet picked an image.',
              textAlign: TextAlign.center,
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  @override
  void initState() {
    showImage = SizedBox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue,
          title: Text(widget.groupName),
        ),
        body: new ListView(
          children: <Widget>[
            new Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: new Card(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: 5.0, left: 5.0, bottom: 20.0, top: 10.0),
                        child: new Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(5.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 50.0,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        widget.user.photoUrl,
                                      ),
                                      radius: 25.0,
                                    ),
                                  ),
                                  Container(
                                    width: 20.0,
                                  ),
                                  Flexible(
                                    child: Column(
                                      children: <Widget>[
                                        TextField(
                                          autofocus: true,
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          controller: _textTextController,
                                          decoration: InputDecoration.collapsed(
                                            hintText: 'What do you think?',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: showImage,
                            ),
                            Container(
                              height: 10.0,
                            ),
                            new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Container(
                                    height: 30.0,
                                    margin: EdgeInsets.only(
                                        left: 5.0,
                                        right: 5.0,
                                        bottom: 5.0,
                                        top: 5.0),
                                    child: Material(
                                        child: MaterialButton(
                                          color: Colors.blueAccent[100],
                                          minWidth: 20.0,
                                          padding: EdgeInsets.only(
                                            left: 80.0,
                                            right: 80.0,
                                          ),
                                          child: Text(
                                            'Post',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            if (imageFile != null) {
                                              uploadFile(imageFile)
                                                  .then((onValue) {
                                                post.onPost(
                                                    _textTextController.text,
                                                    widget.groupId,
                                                    widget.companyId,
                                                    onValue);
                                              }).then((_) {
                                                _textTextController.clear();
                                                if (_textTextController != '')
                                                  Navigator.pop(context);
                                              });
                                            } else {
                                              post.onPost(
                                                  _textTextController.text,
                                                  widget.groupId,
                                                  widget.companyId,
                                                  "");
                                              _textTextController.clear();
                                              if (_textTextController != '')
                                                Navigator.pop(context);
                                            }
                                            // imageFile != null
                                            //     ? uploadFile(imageFile)
                                            //         .then((onValue) {
                                            //         post.onPost(
                                            //             _textTextController
                                            //                 .text,
                                            //             widget.groupId,
                                            //             widget.companyId,
                                            //             onValue);
                                            //       }).then((_) {
                                            //         _textTextController.clear();
                                            //         if (_textTextController !=
                                            //             '')
                                            //           Navigator.pop(context);
                                            //       })
                                            //     : {
                                            //       post.onPost(
                                            //         _textTextController.text,
                                            //         widget.groupId,
                                            //         widget.companyId,
                                            //         "");
                                            //         _textTextController.clear();
                                            //         if (_textTextController !=
                                            //             '')
                                            //           Navigator.pop(context);
                                            //     };
                                          },
                                        ),
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    15.0))),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.photo_camera),
                                    color: Colors.blueAccent[100],
                                    onPressed: () {
                                      getImage().then((value) {
                                        setState(() {
                                          showImage = _previewImage(_imageFile);
                                        });
                                        setState(() {
                                          imageFile = value;
                                        });
                                      });
                                    },
                                  )
                                ])
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ],
        ));
  }
}
