import 'package:firebase_database/firebase_database.dart';
import 'package:stdio/change_email.dart';

class AddUserToCompany {
  Future onAddUserToCompany( String email, String companyId, String companyName, String companyAvatar, String avatar, String name) async{
    ChangeEmail changeEmail = ChangeEmail();
    bool isJoined = true ;
     await FirebaseDatabase.instance
        .reference()
        .child("Company")
        .child(companyId)
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
            .child("users")
            .child(changeEmail.changeEmail(email))
            .set({"email": email, "avatar": avatar, "name": name});
        FirebaseDatabase.instance
            .reference()
            .child('Users')
            .child(changeEmail.changeEmail(email))
            .child('JoinedCompany')
            .child(companyId)
            .set({
          "companyName": companyName,
          "avatar": companyAvatar,
          "dateJoined": DateTime.now().millisecondsSinceEpoch,
        });
      }
      // snapshot.
    });
      return isJoined ;
  }
}
