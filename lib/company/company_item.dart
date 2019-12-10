import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/chat/users_screen.dart';
import 'package:stdio/company/home_screen.dart';
import 'package:stdio/company/list_user_in_company.dart';
import 'package:stdio/home/home_company_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stdio/model/group.dart';

class CompanyItem extends StatefulWidget {
  String avatar;
  String companyName;
  String companyId;
  FirebaseUser user;
  CompanyItem(
      {Key key, this.avatar, this.companyName, this.user, this.companyId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CompanyItemState();
  }
}

class CompanyItemState extends State<CompanyItem> {
  DatabaseReference groupRef;
  Color colorBule = Colors.blue;
  ChangeEmail _changeEmail = ChangeEmail();
  //  String _email = _changeEmail.changeEmail(widget.user.email);
  List<Group> listgroups = List();
  Group group;
  _onGroupAdded(Event event) {
    setState(() {
      listgroups.add(Group.fromSnapshot(event.snapshot));
    });
  }

  _onGroupChanged(Event event) {
    var old = listgroups.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      listgroups[listgroups.indexOf(old)] = Group.fromSnapshot(event.snapshot);
    });
  }

  Future onDelete(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                'Are you sure?',
                style: TextStyle(color: colorBule),
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

  Future outGroup() async {
    int lengGroup = listgroups.length;
    for (int i = 0; i < lengGroup; i++) {
      FirebaseDatabase.instance
          .reference()
          .child('Company')
          .child(widget.companyId)
          .child(
              'Group/${listgroups[i].key}/users/${_changeEmail.changeEmail(widget.user.email)}')
          .remove();
    }
  }

  int amount;

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

  Future countMemberCompany() async {
    await FirebaseDatabase.instance
        .reference()
        .child('Company/${widget.companyId}/users')
        .once()
        .then((onValue) {
      setState(() {
        amount = onValue.value.length;
      });
    });
  }

  // String _email = _changeEmail._changeEmail
  Widget buildItem(BuildContext context) {
    return Slidable(
      secondaryActions: <Widget>[
        IconSlideAction(
            icon: Icons.people,
            caption: 'Members',
            color: Colors.grey[300],
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => UserInCompanyScreen(
                        companyId: widget.companyId,
                        user: widget.user,
                      )));
            }),
        IconSlideAction(
            icon: Icons.delete,
            color: Colors.red,
            caption: 'Delete',
            onTap: () async {
              onDelete(context).then((value) {
                if (value) {
                  // print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
                  outGroup().then((_) {
                    FirebaseDatabase.instance
                        .reference()
                        .child('Company')
                        .child(widget.companyId)
                        .child(
                            'users/${_changeEmail.changeEmail(widget.user.email)}')
                        .remove();
                    FirebaseDatabase.instance
                        .reference()
                        .child('Users')
                        .child(_changeEmail.changeEmail(widget.user.email))
                        .child('JoinedCompany/${widget.companyId}')
                        .remove();
                  });
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
                title: Text(widget.companyName,
                    style: TextStyle(color: Colors.blue)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => HomeCompanyScreen(
                          companyId: widget.companyId,
                          user: widget.user,
                          companyName: widget.companyName,
                          companyAvatar: widget.avatar,
                        )))),
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
        .child('Company/${widget.companyId}/infor')
        .once()
        .then((onValue) {
      if (onValue.value['avatar'] != widget.avatar)
        FirebaseDatabase.instance
            .reference()
            .child(
                "Users/${_changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/avatar")
            .set(onValue.value['avatar']);
    });
  }

  @override
  void initState() {
    countMemberCompany();
    setAvatarCompany();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    groupRef = database
        .reference()
        .child('Company')
        .child(widget.companyId)
        .child("Group");
    groupRef.onChildAdded.listen(_onGroupAdded);
    groupRef.onChildChanged.listen(_onGroupChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildItem(context);
  }
}
