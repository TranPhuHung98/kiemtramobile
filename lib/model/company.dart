import 'package:firebase_database/firebase_database.dart';

class Company {
  String key;
  String avatar;
  String name;
  // Company
  Company(this.avatar, this.name);

  Company.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
      name = snapshot.value["companyName"],
      avatar = snapshot.value["avatar"];
        // infor = snapshot.value['infor'];
}