import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stdio/change_email.dart';
import 'package:stdio/company/home_screen.dart';
import 'package:stdio/home/list_user_screen.dart';
import 'package:stdio/model/group.dart';
// import 'package:stdio/home/home_screen.dart';

class SettingHomeScreen extends StatefulWidget {
  String companyName;
  String companyAvatar;
  String companyId;
  FirebaseUser user;

  SettingHomeScreen(
      {this.companyId, this.user, this.companyAvatar, this.companyName});

  @override
  _SettingHomeScreenState createState() => _SettingHomeScreenState();
}

class _SettingHomeScreenState extends State<SettingHomeScreen> {
  String urlAvatar;
  String nameHome;
  File imageFile;
  bool isLoading = false;
  Color colorBule = Colors.blue;
  Widget showImage;
  Future<File> _imageFile;
  ChangeEmail _changeEmail = ChangeEmail();
  // DatabaseReference itemRef, groupRef;
  // List<Group> listgroups = List();
  // Group group;

  // Future onDelete(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //             title: Text(
  //               'Are you sure?',
  //               style: TextStyle(color: colorBule),
  //             ),
  //             actions: <Widget>[
  //               FlatButton(
  //                 child: Text('Yes'),
  //                 onPressed: () => Navigator.of(context).pop(true),
  //               ),
  //               FlatButton(
  //                 child: Text('No'),
  //                 onPressed: () => Navigator.of(context).pop(false),
  //               )
  //             ],
  //           ));
  // }

  Future getImage() async {
    _imageFile = ImagePicker.pickImage(source: ImageSource.gallery);
    return _imageFile;
  }

  // String changeString(String email) {
  //   String em = email;
  //   for (int i = 0; i < em.length; i++)
  //     if (em[i] == '.') em = em.replaceRange(i, i + 1, '_');
  //   return em;
  // }

  Future uploadFile(File imageFilePut) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(imageFilePut).onComplete.then((onValue) {
      onValue.ref.getDownloadURL().then((dynamic value) {
        FirebaseDatabase.instance
            .reference()
            .child("Company/${widget.companyId}/infor/avatar")
            .set(value.toString());
        FirebaseDatabase.instance
            .reference()
            .child(
                "Users/${_changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/avatar")
            .set(value.toString());
      });
    });
  }

  Widget _previewImage(Future<File> _imageFile) {
    return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return CircleAvatar(
              backgroundImage: FileImage(snapshot.data),
              radius: 80,
            );
            // Image.file(snapshot.data);
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

  // _onGroupAdded(Event event) {
  //   setState(() {
  //     listgroups.add(Group.fromSnapshot(event.snapshot));
  //   });
  // }

  // _onGroupChanged(Event event) {
  //   var old = listgroups.singleWhere((entry) {
  //     return entry.key == event.snapshot.key;
  //   });
  //   setState(() {
  //     listgroups[listgroups.indexOf(old)] = Group.fromSnapshot(event.snapshot);
  //   });
  // }

  @override
  void initState() {
    urlAvatar = widget.companyAvatar;
    nameHome = widget.companyName;
    showImage = CircleAvatar(
      backgroundImage: NetworkImage(
        urlAvatar,
      ),
      radius: 80,
    );
    // final FirebaseDatabase database = FirebaseDatabase.instance;
    // groupRef = database
    //     .reference()
    //     .child('Company')
    //     .child(widget.companyId)
    //     .child("Group");
    // groupRef.onChildAdded.listen(_onGroupAdded);
    // groupRef.onChildChanged.listen(_onGroupChanged);
    super.initState();
  }

  

  ///Out group when user out company
  // Future outGroup() async {
  //   int lengGroup = listgroups.length;
  //   for (int i = 0; i < lengGroup; i++) {
  //     FirebaseDatabase.instance
  //         .reference()
  //         .child('Company')
  //         .child(widget.companyId)
  //         .child(
  //             'Group/${listgroups[i].key}/users/${_changeEmail.changeEmail(widget.user.email)}')
  //         .remove();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    String _email = _changeEmail.changeEmail(widget.user.email);

    return Scaffold(
      appBar: AppBar(
        title: widget.companyName.length <= 6
            ? Text('Setting ${widget.companyName}')
            : Text('Setting ${widget.companyName.substring(0, 5)}...'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.delete_sweep),
        //     onPressed: () async {
        //       onDelete(context).then((value) {
        //         if (value) {
        //           // print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
        //           outGroup().then((_) {
        //             FirebaseDatabase.instance
        //                 .reference()
        //                 .child('Company')
        //                 .child(widget.companyId)
        //                 .child('users/$_email')
        //                 .remove();
        //             FirebaseDatabase.instance
        //                 .reference()
        //                 .child('Users')
        //                 .child(_email)
        //                 .child('JoinedCompany/${widget.companyId}')
        //                 .remove();
        //           });
        //         }
        //       }).then((_) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>HomeScreen(
        //         user: widget.user,
        //       ))));
        //     },
        //     disabledColor: Colors.white,
        //   )
        // ],
      ),
      floatingActionButton: Container(
        height: 35.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          child: RaisedButton(
              color: Colors.blueAccent[100],
              child: Text('Add user',style: TextStyle(color: Colors.white)),
              onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ListUserAddToCompanyScreen(
                      user: widget.user,
                      companyId: widget.companyId,
                      companyName: widget.companyName,
                      companyAvatar: widget.companyAvatar,)));
            },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0))),
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: showImage,
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: RaisedButton(
                    elevation: 0.0,
                    child: Text(
                      'Change image',
                      style: TextStyle(color: Colors.blue[300]),
                    ),
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
                  ),
                ),
                Center(
                  child: Container(
                    padding:
                        EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                    child: TextField(
                      decoration:
                          InputDecoration(hintText: 'Name: $nameHome'),
                      onChanged: (String str) => nameHome = str,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: RaisedButton(
                child: Text('SAVE',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                color: Colors.blue[300],
                onPressed: () async {
                  if (nameHome != widget.companyName) {
                    FirebaseDatabase.instance
                        .reference()
                        .child("Company/${widget.companyId}/infor/name")
                        .set(nameHome);
                    FirebaseDatabase.instance
                        .reference()
                        .child(
                            "Users/${_changeEmail.changeEmail(widget.user.email)}/JoinedCompany/${widget.companyId}/companyName")
                        .set(nameHome);
                  }

                  if (imageFile != null) {
                    uploadFile(imageFile);
                  }

                  //     Scaffold.of(context).showSnackBar(SnackBar(content: Text('Change Complete'),));
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
