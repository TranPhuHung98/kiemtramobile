import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/model/comment.dart';
import 'package:stdio/ticket/comment_onpress.dart';
import 'package:stdio/ticket/comment_post_screen.dart';
import 'package:stdio/ticket/list_comment.dart';

class PostDetail extends StatefulWidget {
  String groupName;
  String groupId;
  String companyId;
  DataSnapshot dataSnapshot;
  Animation animation;
  bool isLiked;
  FirebaseUser user;
  PostDetail(
      {Key key,
      this.dataSnapshot,
      this.animation,
      this.groupName,
      this.groupId,
      this.companyId,
      this.user,
      this.isLiked})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PostDetailState();
  }
}

class PostDetailState extends State<PostDetail> {
  ChangeEmail changeEmail = ChangeEmail();
  final TextEditingController _textEditingController =
      new TextEditingController();
  Comment postComment = Comment();
  File imageFile;
  String imageUrl;
  bool isLoading = false;
  bool isLiked = false;
  int numberLiked = 0;
  List<CommentModel> listcomments = List();
  CommentModel comment;
  DatabaseReference commentRef;
  @override
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  getUser() async {
    firebaseUser = await _auth.currentUser();
  }

  @override
  void initState() {
    getUser();
    isLiked = widget.isLiked;
    quatityPeopleLike();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    commentRef = database
        .reference()
        .child('Company')
        .child(widget.companyId)
        .child(
            "Group/${widget.groupId}/post/${widget.dataSnapshot.key}/comment");
    commentRef.onChildAdded.listen(_onCommentAdded);
    commentRef.onChildChanged.listen(_onCommentChanged);
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

  Future quatityPeopleLike() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnapshot.key}/listUserLiked")
        .once()
        .then((onValue) {
      if (onValue.value != null)
        setState(() {
          numberLiked = onValue.value.length;
        });
    });
  }

  _onCommentAdded(Event event) {
    setState(() {
      listcomments.add(CommentModel.fromSnapshot(event.snapshot));
    });
  }

  _onCommentChanged(Event event) {
    var old = listcomments.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      listcomments[listcomments.indexOf(old)] =
          CommentModel.fromSnapshot(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    quatityPeopleLike();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
          backgroundColor: Colors.blue,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            widget.dataSnapshot.value['senderPhotoUrl']),
                      )),
                  Container(
                    child: Text(
                      '${widget.dataSnapshot.value['senderName']}\n${widget.dataSnapshot.value['timePost']}',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 15.0, 10.0),
                    margin: EdgeInsets.only(left: 10.0),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: Container(
                  child: Text(
                    '''${widget.dataSnapshot.value['content']}''',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(bottom: 10),
                child: widget.dataSnapshot.value['imageUrl'] != ""
                    ? Image.network(widget.dataSnapshot.value['imageUrl'])
                    : Container(
                        child: SizedBox(),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      numberLiked > 1
                          ? '${(numberLiked - 1).toString()} people liked'
                          : '',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      listcomments.length > 0
                          ? '${listcomments.length.toString()} comment'
                          : '',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(left: 20,bottom: 5),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(left: 8.0, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      child: FlatButton(
                        splashColor: Colors.white,
                        highlightColor: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.thumb_up,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                            Text(
                              '   Like',
                              style: TextStyle(
                                  color: isLiked ? Colors.blue : Colors.grey),
                            )
                          ],
                        ),
                        onPressed: () {
                          setState(() => isLiked = !isLiked);
                          FirebaseDatabase.instance
                              .reference()
                              .child(
                                  "Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}")
                              .once()
                              .then((onValue) {
                            if (onValue.value["isLiked"] == 1) {
                              FirebaseDatabase.instance
                                  .reference()
                                  .child(
                                      "Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}")
                                  .update({"isLiked": 0});
                              FirebaseDatabase.instance
                                  .reference()
                                  .child(
                                      "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnapshot.key}/listUserLiked/${changeEmail.changeEmail(firebaseUser.email)}")
                                  .remove();
                            } else {
                              FirebaseDatabase.instance
                                  .reference()
                                  .child(
                                      "Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}")
                                  .update({"isLiked": 1});
                              FirebaseDatabase.instance
                                  .reference()
                                  .child(
                                      "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnapshot.key}/listUserLiked/${changeEmail.changeEmail(firebaseUser.email)}")
                                  .set({"name": firebaseUser.displayName});
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      child: FlatButton(
                        splashColor: Colors.white,
                        highlightColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => CommentPostScreen(
                                    companyId: widget.companyId,
                                    groupId: widget.groupId,
                                    groupName: widget.groupName,
                                    dataSnapshot: widget.dataSnapshot,
                                    numberLiked: numberLiked - 1,
                                  )));
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.mode_comment,
                              color: Colors.grey,
                            ),
                            Text(
                              '   Comment',
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(left: 0),
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
              return CommentItem(
                comment: listcomments[listcomments.length - index - 1],
                companyId: widget.companyId,
                groupId: widget.groupId,
                user: widget.user,
              );
            }, childCount: listcomments.length)),
          ],
        )
        // : Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: <Widget>[
        //       Row(
        //         children: <Widget>[
        //           Container(
        //               margin: const EdgeInsets.only(left: 8.0),
        //               child: CircleAvatar(
        //                 backgroundImage: NetworkImage(
        //                     widget.dataSnapshot.value['senderPhotoUrl']),
        //               )),
        //           Container(
        //             child: Text(
        //               '${widget.dataSnapshot.value['senderName']}\n${widget.dataSnapshot.value['timePost']}',
        //               style: TextStyle(
        //                   color: Colors.black, fontWeight: FontWeight.bold),
        //             ),
        //             padding: EdgeInsets.fromLTRB(5.0, 10.0, 15.0, 10.0),
        //             margin: EdgeInsets.only(left: 10.0),
        //           ),
        //         ],
        //       ),
        //       Container(
        //         margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        //         child: Container(
        //           child: Text(
        //             '''${widget.dataSnapshot.value['content']}''',
        //             style: TextStyle(fontSize: 18.0),
        //           ),
        //         ),
        //       ),
        //       Divider(
        //         height: 0,
        //       ),
        //       Container(
        //         padding: EdgeInsets.only(left: 8.0, right: 8),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceAround,
        //           children: <Widget>[
        //             Container(
        //               child: FlatButton(
        //                 splashColor: Colors.white,
        //                 highlightColor: Colors.white,
        //                 child: Row(
        //                   children: <Widget>[
        //                     Icon(
        //                       Icons.thumb_up,
        //                       color: isLiked ? Colors.blue : Colors.grey,
        //                     ),
        //                     Text(
        //                       '   Like',
        //                       style: TextStyle(
        //                           color: isLiked ? Colors.blue : Colors.grey),
        //                     )
        //                   ],
        //                 ),
        //                 onPressed: () {
        //                   setState(() => isLiked = !isLiked);
        //                   FirebaseDatabase.instance
        //                       .reference()
        //                       .child(
        //                           "Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}")
        //                       .once()
        //                       .then((onValue) {
        //                     if (onValue.value["isLiked"] == 1) {
        //                       FirebaseDatabase.instance
        //                           .reference()
        //                           .child(
        //                               "Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}")
        //                           .update({"isLiked": 0});
        //                       FirebaseDatabase.instance
        //                           .reference()
        //                           .child(
        //                               "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnapshot.key}/listUserLiked/${changeEmail.changeEmail(firebaseUser.email)}")
        //                           .remove();
        //                     } else {
        //                       FirebaseDatabase.instance
        //                           .reference()
        //                           .child(
        //                               "Users/${changeEmail.changeEmail(firebaseUser.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnapshot.key}")
        //                           .update({"isLiked": 1});
        //                       FirebaseDatabase.instance
        //                           .reference()
        //                           .child(
        //                               "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnapshot.key}/listUserLiked/${changeEmail.changeEmail(firebaseUser.email)}")
        //                           .set({"name": firebaseUser.displayName});
        //                     }
        //                   });
        //                 },
        //               ),
        //             ),
        //             Container(
        //               child: FlatButton(
        //                 splashColor: Colors.white,
        //                 highlightColor: Colors.white,
        //                 onPressed: () {},
        //                 child: Row(
        //                   children: <Widget>[
        //                     Icon(
        //                       Icons.mode_comment,
        //                       color: Colors.grey,
        //                     ),
        //                     Text(
        //                       '   Comment',
        //                       style: TextStyle(color: Colors.grey),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Flexible(
        //         child: ListView.builder(
        //           itemCount: listcomments.length,
        //           itemBuilder: (BuildContext context, int index) {
        //             return CommentItem(
        //               comment: listcomments[index],
        //               companyId: widget.companyId,
        //               groupId: widget.groupId,
        //               user: widget.user,
        //             );
        //           },
        //         ),
        //       ),
        //       Divider(height: 1.0),
        //       Container(
        //         padding: EdgeInsets.only(left: 0),
        //         decoration:
        //             new BoxDecoration(color: Theme.of(context).cardColor),
        //         child: _buildTextComposer(),
        //       ),
        //     ],
        //   ),
        );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Container(
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
