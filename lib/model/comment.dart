import 'package:firebase_database/firebase_database.dart';

class CommentModel {
  String key;
  String content;
  String email;
  String senderName;
  String senderPhotoUrl;
  String timePost;
  int type;
  // Company
  CommentModel(this.content,this.email,this.senderName,this.senderPhotoUrl,this.timePost,this.type);

  CommentModel.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
      content = snapshot.value["content"],
      email = snapshot.value["email"],
      senderName = snapshot.value["senderName"],
      senderPhotoUrl = snapshot.value["senderPhotoUrl"],
      type = snapshot.value["type"],
      timePost = snapshot.value["timePost"];

        // infor = snapshot.value['infor'];
}