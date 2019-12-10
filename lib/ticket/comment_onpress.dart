import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Comment{
  void onComment(int type,String groupId , String postId ,String content,String companyId) async {
     final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (content != '') {
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .child('post')
          .child(postId)
          .child('comment')
          .push()
          .set({
        'type' : type,
        'content': content,
        'email': firebaseUser.email,
        'senderName': firebaseUser.displayName,
        'senderPhotoUrl': firebaseUser.photoUrl,
        'timePost' : DateTime.now().toString().substring(0,16)
      });
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .child('post')
          .child(postId)
          .update({
        "timeLastComment": DateTime.now().millisecondsSinceEpoch.toString()
      });
      //  FirebaseDatabase.instance
      //     .reference()
      //     .child("Company")
      //     .child(companyId)
      //     .child('Group')
      //     .update({
      //   "timeLastCommentAllPost": DateTime.now().millisecondsSinceEpoch.toString()
      // });
    }
  }
}