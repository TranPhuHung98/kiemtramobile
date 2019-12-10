import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SendMessage {
  void onSendMessage(
      String content, int type, String groupId, String companyId) async {
    // type: 0 = text, 1 = image
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await _auth.currentUser();
    // ServerValue.timestamp;
    if (content != '') {
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .child('message')
          .push()
          .set({
        'type': type,
        'text': content,
        'email': firebaseUser.email,
        'senderName': firebaseUser.displayName,
        'senderPhotoUrl': firebaseUser.photoUrl,
        'timeSend': DateTime.now().toString().substring(0,16)
      });
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child('Group')
          .child('$groupId')
          .update({
        "timeLastMessage": DateTime.now().millisecondsSinceEpoch.toString()
      });
    } else {
      //
    }
  }
}
