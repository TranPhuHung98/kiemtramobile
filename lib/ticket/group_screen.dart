import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/chat/chat_screen.dart';
import 'package:stdio/edit_group_screen.dart';
import 'package:stdio/ticket/post_model.dart';
import 'package:stdio/ticket/post_status.dart';

class GroupScreen extends StatefulWidget {
  String companyId;
  String groupId;
  String groupName;
  String groupAvatar;
  FirebaseUser user;
  GroupScreen(
      {Key key,
      this.groupId,
      this.groupName,
      this.user,
      this.groupAvatar,
      this.companyId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return GroupScreenState();
  }
}

class GroupScreenState extends State<GroupScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  String timeSeenMessage, timeLastMessage;
  bool newMessage = false;

  Widget listPost() {
    return new FirebaseAnimatedList(
      query: FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(widget.companyId)
          .child('Group')
          .child('${widget.groupId}')
          .child('post'),
      padding: const EdgeInsets.all(8.0),
      reverse: true,
      sort: (a, b) => b.key.compareTo(a.key),
      itemBuilder: (_, DataSnapshot dataSnapshot, Animation<double> animation,
          int index) {
        return PostModel(
          companyId: widget.companyId,
          dataSnaphot: dataSnapshot,
          animation: animation,
          groupId: widget.groupId,
          groupName: widget.groupName,
        );
      },
    );
  }

  ChangeEmail changeEmail = ChangeEmail();

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

  @override
  Widget build(BuildContext context) {
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
    var listPost = FirebaseDatabase.instance
        .reference()
        .child("Company")
        .child(widget.companyId)
        .child('Group')
        .child('${widget.groupId}')
        .child('post');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        title: widget.groupName.length <= 15
            ? Text('${widget.groupName}')
            : Text('${widget.groupName.substring(0, 14)}...'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.chat),
            color: newMessage ? Colors.red : Colors.white,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        companyId: widget.companyId,
                        groupName: widget.groupName,
                        user: widget.user,
                        groupId: widget.groupId,
                      )));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingGrpScreen(
                      user: widget.user,
                      companyId: widget.companyId,
                      grpName: widget.groupName,
                      grpAvatar: widget.groupAvatar,
                      grpId: widget.groupId,
                    ))),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            SizedBox(height: 2.0,),
            Expanded(
              flex: 9,
              child: new FirebaseAnimatedList(
                query: listPost,
                // padding: const EdgeInsets.all(8.0),
                reverse: false,
                sort: (a, b) => b.key.compareTo(a.key),
                itemBuilder: (_, DataSnapshot dataSnapshot,
                    Animation<double> animation, int index) {
                  return PostModel(
                    user: widget.user,
                    companyId: widget.companyId,
                    dataSnaphot: dataSnapshot,
                    animation: animation,
                    groupName: widget.groupName,
                    groupId: widget.groupId,
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 35.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          child: RaisedButton(
              color: Colors.blueAccent[100],
              child: Text('Post Status', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PostStatus(
                          companyId: widget.companyId,
                          groupId: widget.groupId,
                          groupName: widget.groupName,
                          user: widget.user,
                        )));
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0))),
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
