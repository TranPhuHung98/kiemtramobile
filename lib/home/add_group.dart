import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stdio/change_email.dart';

class AddGroup {
  void onAddGroup(String companyId, String groupName, FirebaseUser user) {
    ChangeEmail changeEmail = ChangeEmail();
    if (groupName != null && groupName != " ") {
      int dateCreate = DateTime.now().millisecondsSinceEpoch;
      String groupId = dateCreate.toString();
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child("$companyId")
          .child("Group")
          .child(groupId)
          .child("infor")
          .set({
        "avatar":
            "https://firebasestorage.googleapis.com/v0/b/stdiohihi.appspot.com/o/1546853429162?alt=media&token=72653dbd-7642-48be-9903-d05cf7ffe93b",
        "name": groupName,
      });
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child("Group")
          .child(groupId)
          .child("users")
          .child(changeEmail.changeEmail(user.email))
          .set({
        "email": user.email,
        "avatar": user.photoUrl,
        "name": user.displayName
      });
      FirebaseDatabase.instance.reference().child("Users")
        ..child(changeEmail.changeEmail(user.email))
            .child("JoinedCompany")
            .child(companyId)
            .child("JoinedGroup")
            .child(groupId)
            .set({
          "groupName": groupName,
          "avatar":
              "https://firebasestorage.googleapis.com/v0/b/stdiohihi.appspot.com/o/1546853429162?alt=media&token=72653dbd-7642-48be-9903-d05cf7ffe93b",
          "dateJoined": DateTime.now().millisecondsSinceEpoch
        });
    }
  }
}
