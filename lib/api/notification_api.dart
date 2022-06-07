import 'package:firebase_core/firebase_core.dart';
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

    final details = await localNotification.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotification.add(messages);
    }

    await localNotification.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotification.add(messages);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messages = message;
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        // show message on banner from firebase messaging
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      messages = message;
      print('a new onMessageOpenedApp event was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        onNotification.add(message);
      }
    });
    String? fcmToken = 'No token';
    await FirebaseMessaging.instance
        .getToken()
        .then((token) => fcmToken = token);
    print(fcmToken);
  }

  Future<void> showNotification(RemoteMessage message) async {
    await Firebase.initializeApp();
    RemoteNotification notification = messages.notification!;
    var androidChannel = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notification',
      channelDescription: 'heello',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosChannel = const IOSNotificationDetails();
    var platformChannel =
        NotificationDetails(android: androidChannel, iOS: iosChannel);

    await localNotification.show(
      0,
      notification.title,
      notification.body,
      platformChannel,
      payload: 'hurn.sothea',
    );
  }
}
