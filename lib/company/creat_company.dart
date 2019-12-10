import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stdio/change_email.dart';

class CreatCompany {
  void onCreatCompany(String companyName, FirebaseUser user) {
    ChangeEmail changeEmail = ChangeEmail();
    if (companyName != null && companyName != " ") {
      int dateCreate = DateTime.now().millisecondsSinceEpoch ;
      String companyId = dateCreate.toString() ;
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child("infor")
          .set({
        "avatar": "https://firebasestorage.googleapis.com/v0/b/stdiohihi.appspot.com/o/1546857481422?alt=media&token=146d7120-d090-4c43-9d75-d0ae58d81df1",
        "name": companyName,
      });
      FirebaseDatabase.instance
          .reference()
          .child("Company")
          .child(companyId)
          .child("users")
          .child(changeEmail.changeEmail(user.email))
          .set({
        "email": user.email,
        "avatar" : user.photoUrl,
        "name" :user.displayName
      });
      FirebaseDatabase.instance
          .reference()
          .child("Users")
          ..child(changeEmail.changeEmail(user.email))
          .child("JoinedCompany")
          .child(companyId)
          .set({
        "companyName": companyName,
        "avatar" : "https://firebasestorage.googleapis.com/v0/b/stdiohihi.appspot.com/o/1546857481422?alt=media&token=146d7120-d090-4c43-9d75-d0ae58d81df1",
        "dateJoined": DateTime.now().millisecondsSinceEpoch 
      });

    }
  }
}
