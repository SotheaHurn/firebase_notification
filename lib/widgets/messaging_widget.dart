import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications/api/notification_api.dart';
import 'package:firebase_notifications/page/detial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingWidget extends StatefulWidget {
  const MessagingWidget({Key? key}) : super(key: key);

  @override
  State<MessagingWidget> createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  @override
  void initState() {
    super.initState();
    NotificationAPI.init();
    listenNotifications();
  }

  void listenNotifications() =>
      NotificationAPI.onNotification.stream.listen(onClickedNotification);

  void onClickedNotification(RemoteMessage message) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DetialPage(
          message: message,
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Notification'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () => setState(() {
                  NotificationAPI.localNotification.show(
                      0,
                      'Testing',
                      'How are you?',
                      NotificationDetails(
                        android: AndroidNotificationDetails(
                          NotificationAPI.channel.id,
                          NotificationAPI.channel.name,
                          channelDescription:
                              NotificationAPI.channel.description,
                          icon: '@mipmap/ic_launcher',
                          importance: NotificationAPI.channel.importance,
                        ),
                      ),
                      payload: 'sothea.hurn');
                }),
            child: Text('Send Notification')),
      ),
    );
  }
}
