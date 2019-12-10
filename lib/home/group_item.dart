import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/company/home_screen.dart';
import 'package:stdio/home/list_user_in_group.dart';
import 'package:stdio/ticket/group_screen.dart';

class GroupItem extends StatefulWidget {
  String companyId;
  String avatar;
  String groupName;
  String groupId;
  FirebaseUser user;
  GroupItem(
      {Key key,
      this.avatar,
      this.groupName,
      this.user,
      this.groupId,
      this.companyId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _GroupItemState();
  }
}

class _GroupItemState extends State<GroupItem> {
  static SlidableDelegate _getDelegate(int index) {
    switch (index % 4) {
      case 0:
        return new SlidableBehindDelegate();
      case 1:
        return new SlidableStrechDelegate();
      case 2:
        return new SlidableScrollDelegate();
      case 3:
        return new SlidableDrawerDelegate();
      default:
        return null;
    }
  }

  String timeSeenComment, timeLastCommentAllPost;
  bool newComment = false;
  int amount;

  Future seenComment() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}')
        .once()
        .then((onValue) {
      timeSeenComment = onValue.value['timeSeenComment'] ?? '0';
    });
  }

  ChangeEmail changeEmail = ChangeEmail();
  String timeSeenMessage, timeLastMessage;
  bool newMessage = false;

  Future seenMessage() async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            'Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}')
        .once()
        .then((onValue) {
      timeSeenMessage = onValue.value['timeSeenMessage'] ?? '0';
    });
    await FirebaseDatabase.instance
        .reference()
        .child('Company/${widget.companyId}/Group/${widget.groupId}')
        .once()
        .then((onValue) =>
            timeLastMessage = onValue.value['timeLastMessage'] ?? '0');
  }

  Future countMemberCompany() async {
    await FirebaseDatabase.instance
        .reference()
        .child('Company/${widget.companyId}/Group/${widget.groupId}/users')
        .once()
        .then((onValue) {
      setState(() {
        amount = onValue.value.length;
      });
    });
  }

  Widget buildItem(BuildContext context) {
    // print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    seenMessage().then((_) {
      if (timeLastMessage.compareTo(timeSeenMessage) > 0)
        setState(() {
          newMessage = true;
        });
      else
        setState(() {
          newMessage = false;
        });
    });

    Future onDelete(BuildContext context) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(
                  'Are you sure?',
                  style: TextStyle(color: Colors.blue),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  FlatButton(
                    child: Text('No'),
                    onPressed: () => Navigator.of(context).pop(false),
                  )
                ],
              ));
    }

    return Slidable(
      secondaryActions: <Widget>[
        IconSlideAction(
          icon: Icons.people,
          caption: 'Members',
          color: Colors.grey[300],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => UserInGroupScreen(
                    companyId: widget.companyId,
                    groupId: widget.groupId,
                    user: widget.user,
                  ))),
        ),
        IconSlideAction(
            icon: Icons.delete,
            color: Colors.red,
            caption: 'Delete',
            onTap: () {
              onDelete(context).then((value) {
                if (value) {
                  FirebaseDatabase.instance
                      .reference()
                      .child('Company')
                      .child(widget.companyId)
                      .child(
                          'Group/${widget.groupId}/users/${changeEmail.changeEmail(widget.user.email)}')
                      .remove();
                  FirebaseDatabase.instance
                      .reference()
                      .child('Users')
                      .child('${changeEmail.changeEmail(widget.user.email)}')
                      .child(
                          'JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}')
                      .remove();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => HomeScreen(
                            user: widget.user,
                          )));
                }
              });
            }),
      ],
      child: Card(
        margin: EdgeInsets.only(right: 10.0, left: 10.0, top: 2, bottom: 2),
        child: Container(
          height: 70.0,
          child: Center(
            child: ListTile(
              subtitle: Text(
                'Members: ${amount.toString()}',
                style: TextStyle(fontSize: 11),
              ),
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(widget.avatar),
              ),
              title: Text(
                widget.groupName,
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GroupScreen(
                        companyId: widget.companyId,
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        user: widget.user,
                        groupAvatar: widget.avatar,
                      ))),
              trailing: (newComment || newMessage)
                  ? Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    )
                  : SizedBox(),
            ),
          ),
        ),
      ),
      delegate: _getDelegate(1),
    );
  }

  setAvatarCompany() {
    // String avatar =
    FirebaseDatabase.instance
        .reference()
        .child('Company/${widget.companyId}/Group/${widget.groupId}/infor')
        .once()
        .then((onValue) {
      if (onValue.value['avatar'] != widget.avatar)
        FirebaseDatabase.instance
            .reference()
            .child(
                "Users/${changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.groupId}/avatar")
            .set(onValue.value['avatar']);
    });
  }

  @override
  void initState() {
    countMemberCompany();
    setAvatarCompany();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildItem(context);
  }
}
