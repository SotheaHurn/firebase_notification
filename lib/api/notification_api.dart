import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationAPI {
  static RemoteMessage messages = const RemoteMessage(
      notification: RemoteNotification(title: 'Null', body: 'Null'));

  static const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notification',
    description: 'This channel is used for important notification',
    importance: Importance.max,
  );

  static final onNotification = BehaviorSubject<RemoteMessage>();

  static final localNotification = FlutterLocalNotificationsPlugin();

  static Future init() async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messages = message;
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        //show message on banner from firebase messaging
        localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: channel.importance,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: 'hurn.sothea',
        );
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) =>
        messages.messageId!.isNotEmpty
            ? onNotification.add(message!)
            : print('object'));

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      messages = message;
      print('a new onMessageOpenedApp event was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        onNotification.add(message);
      }
    });

    final details = await localNotification.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotification.add(
        RemoteMessage(
            notification: RemoteNotification(
                title: 'details',
                body: 'localNotification.getNotificationAppLaunchDetails()')),
      );

      FirebaseMessaging.instance.getInitialMessage().then((message) =>
          messages.messageId!.isNotEmpty
              ? onNotification.add(message!)
              : onNotification.add(message!));
    }

    await localNotification.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotification.add(RemoteMessage(
            notification: RemoteNotification(
                title: 'localNotification.initialize', body: payload)));
      },
    );
  }
}
