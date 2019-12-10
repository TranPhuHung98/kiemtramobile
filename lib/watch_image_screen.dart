import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class WatchImageScreen extends StatelessWidget {

  String url;
  WatchImageScreen({this.url});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment(-1.0, -0.95),
      children: <Widget>[
        PhotoView(
          imageProvider: NetworkImage(url),
          loadingChild: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.maybePop(context);
          },
          iconSize: 40.0,
          color: Colors.white,
        )
      ],
    ));
  }
}