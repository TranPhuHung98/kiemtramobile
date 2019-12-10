import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/model/comment.dart';
import 'package:stdio/ticket/post_detail.dart';

class PostModel extends StatefulWidget {
  DataSnapshot dataSnaphot;
  Animation animation;
  String companyId;
  String groupId;
  String groupName;
  FirebaseUser user;
  PostModel(
      {Key key,
      this.dataSnaphot,
      this.animation,
      this.groupId,
      this.groupName,
      this.companyId,
      this.user})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PostModelState();
  }
}

class PostModelState extends State<PostModel> {
  ChangeEmail changeEmail = ChangeEmail();
  String timeSeenComment, timeLastComment;
  String timePost, timeSeenPost;
  bool newComment = false;
  bool newPost = false;
  bool canDelete = false;
  bool isLiked = false;
  int numberLiked = 0;
  List<CommentModel> listcomments = List();
  CommentModel comment;
  DatabaseReference commentRef;

  Future seenPost() async {
    FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}')
        .update({"value": 1});
    timePost = widget.dataSnaphot.key.toString();
    await FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}')
        .once()
        .then((onValue) {
      timeSeenPost = onValue.value['timeSeenPost'] ?? "0";
    });
  }

  Future seenComment() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            'Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnaphot.key}')
        .once()
        .then((onValue) =>
            timeLastComment = onValue.value['timeLastComment'] ?? '0');
    await FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}')
        .once()
        .then((onValue) {
      timeSeenComment = onValue.value['timeSeenComment'] ?? '0';
    });
  }

  Future onDeletePost(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                'Are you sure?',
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Yes',
                      style: TextStyle(
                        color: Colors.red[800],
                      )),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                FlatButton(
                  child: Text('No',
                      style: TextStyle(
                        color: Colors.blue,
                      )),
                  onPressed: () => Navigator.of(context).pop(false),
                )
              ],
            ));
  }

  checkEmailPost() {
    FirebaseDatabase.instance
        .reference()
        .child('Company')
        .child(widget.companyId)
        .child('Group/${widget.groupId}/post/${widget.dataSnaphot.key}')
        .once()
        .then((data) {
      if (data.value['email'] == widget.user.email)
        setState(() => canDelete = true);
    });
  }

  Future isUserLiked() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}')
        .once()
        .then((onValue) {
      setState(() {
        onValue.value['isLiked'] == 1 ? isLiked = true : isLiked = false;
      });
    });
  }

  Future quatityPeopleLike() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnaphot.key}/listUserLiked")
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
  void initState() {
    isUserLiked();
    quatityPeopleLike();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    commentRef = database
        .reference()
        .child('Company')
        .child(widget.companyId)
        .child(
            "Group/${widget.groupId}/post/${widget.dataSnaphot.key}/comment");
    commentRef.onChildAdded.listen(_onCommentAdded);
    commentRef.onChildChanged.listen(_onCommentChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    seenComment().then((_) {
      if (timeLastComment.compareTo(timeSeenComment) > 0)
        setState(() => newComment = true);
      else
        setState(() => newComment = false);
    });
    seenPost().then((_) {
      if (timePost.compareTo(timeSeenPost) > 0)
        setState(() {
          newPost = true;
        });
      else
        setState(() {
          newPost = false;
        });
    });
    isUserLiked();
    quatityPeopleLike();
    checkEmailPost();
    return Column(
      children: <Widget>[
        GestureDetector(
          onLongPress: () => canDelete
              ? onDeletePost(context).then((onValue) {
                  if (onValue) {
                    FirebaseDatabase.instance
                        .reference()
                        .child('Company')
                        .child(widget.companyId)
                        .child(
                            'Group/${widget.groupId}/post/${widget.dataSnaphot.key}')
                        .remove();
                    Navigator.of(context).pop();
                  }
                })
              : null,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PostDetail(
                    user: widget.user,
                    companyId: widget.companyId,
                    dataSnapshot: widget.dataSnaphot,
                    animation: widget.animation,
                    groupName: widget.groupName,
                    groupId: widget.groupId,
                    isLiked: isLiked,
                  ))),
          child: Card(
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(0)),
            semanticContainer: true,
            elevation: 0,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        widget.dataSnaphot.value['senderPhotoUrl']),
                    radius: 26,
                  ),
                  title: Text(
                    widget.dataSnaphot.value['senderName'],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: newPost ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: newComment
                      ? Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        )
                      : SizedBox(),
                  subtitle: Text(
                    '${widget.dataSnaphot.value['timePost']}',
                    style: TextStyle(
                        fontWeight:
                            newPost ? FontWeight.bold : FontWeight.normal,
                        color: newPost ? Colors.black : Colors.grey),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 22, right: 20.0),
                  child: Text(
                    '${widget.dataSnaphot.value['content']}',
                    style: TextStyle(
                      fontWeight: newPost ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Container(
                  child: widget.dataSnaphot.value['imageUrl'] != ""
                      ? Image.network(widget.dataSnaphot.value['imageUrl'])
                      : Container(
                          child: SizedBox(),
                        ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        numberLiked > 1
                            ? '${(numberLiked - 1).toString()} people liked'
                            : '',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      listcomments.length > 0
                          ? Text('${listcomments.length.toString()} comment',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12))
                          : SizedBox()
                    ],
                  ),
                  padding: EdgeInsets.only(left: 20, bottom: 5),
                ),
                Divider(height: 0),
                Container(
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
                                    "Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}")
                                .once()
                                .then((onValue) {
                              if (onValue.value["isLiked"] == 1) {
                                FirebaseDatabase.instance
                                    .reference()
                                    .child(
                                        "Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}")
                                    .update({"isLiked": 0});
                                FirebaseDatabase.instance
                                    .reference()
                                    .child(
                                        "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnaphot.key}/listUserLiked/${changeEmail.changeEmail(widget.user.email)}")
                                    .remove();
                              } else {
                                FirebaseDatabase.instance
                                    .reference()
                                    .child(
                                        "Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/post/${widget.dataSnaphot.key}")
                                    .update({"isLiked": 1});
                                FirebaseDatabase.instance
                                    .reference()
                                    .child(
                                        "Company/${widget.companyId}/Group/${widget.groupId}/post/${widget.dataSnaphot.key}/listUserLiked/${changeEmail.changeEmail(widget.user.email)}")
                                    .set({"name": widget.user.displayName});
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        child: FlatButton(
                          splashColor: Colors.white,
                          highlightColor: Colors.white,
                          onPressed: () {},
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
