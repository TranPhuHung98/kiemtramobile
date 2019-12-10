import 'package:firebase_database/firebase_database.dart';

class Group {
  String key;
  // String


  Group.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key;
}