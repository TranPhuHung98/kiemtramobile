import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Post {
  void onPost(
      String content, String groupId, String companyId, String imageUrl) async {
        print('oooooooooooooooooooookkkkkkkkkkkkkkkkkkkkkk $imageUrl');
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (content != '' || imageUrl != "") {
      DateTime time = DateTime.now();
      String abc = DateFormat.jm().add_yMMMMd().format(time).toString();
      String timePost = time.millisecondsSinceEpoch.toString();
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .child('post')
          .child(timePost)
          .set({
        'content': content,
        'email': firebaseUser.email,
        'senderName': firebaseUser.displayName,
        'senderPhotoUrl': firebaseUser.photoUrl,
        'imageUrl': imageUrl,
        'timePost': abc
      });
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .update({
        "timeLastPost": DateTime.now().millisecondsSinceEpoch.toString()
      });
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .child('post')
          .child(timePost)
          .child('listUserLiked')
          .set({
        'a': 1,
      });
    }
  }
}
