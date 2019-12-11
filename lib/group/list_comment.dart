import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stdio/model/comment.dart';
import 'package:stdio/watch_image_screen.dart';

class CommentItem extends StatefulWidget {
  DataSnapshot dataSnapshot;
  Animation animation;
  CommentModel comment;
  String companyId;
  String groupId;
  String postId;
  FirebaseUser user;
  CommentItem(
      {Key key,
      this.dataSnapshot,
      this.animation,
      this.comment,
      this.companyId,
      this.groupId,
      this.postId,
      this.user})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CommentItemState();
  }
}

class CommentItemState extends State<CommentItem> {
  bool canDelete = false;

  String setDayToday(String dayTime) {
    String month = DateTime.now().month < 10
        ? '0' + DateTime.now().month.toString()
        : DateTime.now().month.toString();
    String day = DateTime.now().day < 10
        ? '0' + DateTime.now().day.toString()
        : DateTime.now().day.toString();
    String dayNow = DateTime.now().year.toString() + '-' + month + '-' + day;
    return dayTime.substring(0, 10).compareTo(dayNow) == 0
        ? dayTime.substring(11, 16)
        : dayTime;
  }

  checkEmailPost() {
    FirebaseDatabase.instance
        .reference()
        .child('Company')
        .child(widget.companyId)
        .child(
            'Group/${widget.groupId}/post/${widget.postId}/commnet/${widget.comment.key}')
        .once()
        .then((data) {
      if (data.value['email'] == widget.user.email)
        setState(() => canDelete = true);
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

  _commentItem(CommentModel commentItem) {
    return GestureDetector(
      onLongPress: () => canDelete
          ? onDeletePost(context).then((onValue) {
              if (onValue) {
                FirebaseDatabase.instance
                    .reference()
                    .child('Company')
                    .child(widget.companyId)
                    .child(
                        'Group/${widget.groupId}/post/${widget.postId}/comment/${widget.comment.key}')
                    .remove();
                Navigator.of(context).pop();
              }
            })
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  height: 30.0,
                  width: 30.0,
                  margin: const EdgeInsets.only(right: 5.0),
                  child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(commentItem.senderPhotoUrl))),

              commentItem.type == 1
                  ? Flexible(
                      child: Container(
                      child: Text(
                        commentItem.content,
                        style: TextStyle(color: Colors.black),
                      ),
                      padding: EdgeInsets.only(
                          left: 20.0, right: 15.0, bottom: 10.0, top: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.grey[200]),
                      margin: EdgeInsets.all(5.0),
                    ))
                  : Container(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => WatchImageScreen(
                                      url: commentItem.content,
                                    )));
                          },
                          child: Image.network(
                            commentItem.content,
                            fit: BoxFit.cover,
                          )),
                      height: 200.0,
                      width: 200.0,
                    ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 50),
            child: Text(
              setDayToday(commentItem.timePost),
              style: TextStyle(fontSize: 10),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _commentItem(widget.comment),
      margin: EdgeInsets.only(left: 10.0, top: 5.0),
    );
  }
}
