import 'package:firebase_database/firebase_database.dart';
import 'package:stdio/change_email.dart';

class AddUser {
  Future onAddUser(String email,String avatar,String name, String groupId, String groupName,
      String groupAvatar, String companyId) async{
    ChangeEmail changeEmail = ChangeEmail();
    bool isJoined = true;
    await FirebaseDatabase.instance
        .reference()
        .child("Company")
        .child(companyId)
        .child("Group")
        .child(groupId)
        .child("users")
        .child(changeEmail.changeEmail(email))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        isJoined = false;
        FirebaseDatabase.instance
            .reference()
            .child("Company")
            .child(companyId)
            .child("Group")
            .child(groupId)
            .child("users")
            .child(changeEmail.changeEmail(email))
            .set({
          "email": email,
          "avatar": avatar,
          "name": name
        });
        FirebaseDatabase.instance
            .reference()
            .child('Users')
            .child(changeEmail.changeEmail(email))
            .child('JoinedCompany')
            .child(companyId)
            .child('JoinedGroup')
            .child(groupId)
            .set({
          "groupName": groupName,
          "avatar": groupAvatar,
          "dateJoined": DateTime.now().millisecondsSinceEpoch,
        });
      }
      // snapshot.
    });
    return isJoined ;
  }

}
