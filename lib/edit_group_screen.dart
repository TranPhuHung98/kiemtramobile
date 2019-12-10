import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stdio/chat/users_screen.dart';
import 'package:stdio/company/home_screen.dart';
import 'package:stdio/home/home_company_screen.dart';
import 'package:stdio/ticket/group_screen.dart';

class SettingGrpScreen extends StatefulWidget {
  String companyId;
  String grpAvatar;
  String grpName;
  String grpId;
  FirebaseUser user;

  SettingGrpScreen(
      {this.grpAvatar, this.grpName, this.grpId, this.companyId, this.user});

  @override
  _SettingGrpScreenState createState() => _SettingGrpScreenState();
}

class _SettingGrpScreenState extends State<SettingGrpScreen> {
  String urlAvatar;
  String nameGrp;
  File imageFile;
  bool isLoading = false;
  Color colorBule = Colors.blue;
  Future<File> _imageFile;
  Widget showImage;

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

  String changeString(String email) {
    String em = email;
    for (int i = 0; i < em.length; i++)
      if (em[i] == '.') em = em.replaceRange(i, i + 1, '_');
    return em;
  }

  Future uploadFile(File imageFilePut) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(imageFilePut).onComplete.then((onValue) {
      onValue.ref.getDownloadURL().then((dynamic value) {
        FirebaseDatabase.instance
            .reference()
            .child(
                "Company/${widget.companyId}/Group/${widget.grpId}/infor/avatar")
            .set(value.toString());
        FirebaseDatabase.instance
            .reference()
            .child(
                "Users/${changeString(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.grpId}/avatar")
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

  @override
  void initState() {
    urlAvatar = widget.grpAvatar;
    nameGrp = widget.grpName;
    showImage = CircleAvatar(
      backgroundImage: NetworkImage(
        urlAvatar,
      ),
      radius: 80,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _email = changeString(widget.user.email);

    return Scaffold(
      appBar: AppBar(
        title: widget.grpName.length <= 6
            ? Text('Setting ${widget.grpName}')
            : Text('Setting ${widget.grpName.substring(0, 5)}...'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.delete_sweep),
        //     onPressed: () {
        //       onDelete(context).then((value) {
        //         if (value) {
        //           FirebaseDatabase.instance
        //               .reference()
        //               .child('Company')
        //               .child(widget.companyId)
        //               .child('Group/${widget.grpId}/users/$_email')
        //               .remove();
        //           FirebaseDatabase.instance
        //               .reference()
        //               .child('Users')
        //               .child(_email)
        //               .child(
        //                   'JoinedCompany/${widget.companyId}/JoinedGroup/${widget.grpId}')
        //               .remove();
        //           Navigator.of(context).pushReplacement(MaterialPageRoute(
        //               builder: (_) => HomeScreen(
        //                     user: widget.user,
        //                   )));
        //         }
        //       });
        //     },
        //     // color: Colors.white,
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
                    builder: (_) => UserScreen(
                          user: widget.user,
                          companyId: widget.companyId,
                          groupId: widget.grpId,
                          groupName: widget.grpName,
                          groupAvatar: widget.grpAvatar,
                        )));
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
                          InputDecoration(hintText: 'Name: $nameGrp'),
                      onChanged: (String str) => nameGrp = str,
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
                  if (nameGrp != widget.grpName)
                    FirebaseDatabase.instance
                        .reference()
                        .child(
                            "Company/${widget.companyId}/Group/${widget.grpId}/infor/name")
                        .set(nameGrp);
                  FirebaseDatabase.instance
                      .reference()
                      .child(
                          "Users/${changeString(widget.user.email)}/JoinedCompany/${widget.companyId}/JoinedGroup/${widget.grpId}/groupName")
                      .set(nameGrp);

                  if (imageFile != null) {
                    uploadFile(imageFile);
                  }

                  //  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Change Complete'),));
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
