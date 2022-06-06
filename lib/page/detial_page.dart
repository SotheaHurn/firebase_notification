import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class DetialPage extends StatelessWidget {
  final RemoteMessage? message;
  final String? payload;
  const DetialPage({Key? key, this.message, this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detial Page'),
      ),
      body: message != null
          ? Column(
              children: [
                Text(message!.notification!.title.toString()),
                Text(message!.notification!.body.toString()),
              ],
            )
          : SizedBox(
              child: Text(payload!),
            ),
    );
  }
}
