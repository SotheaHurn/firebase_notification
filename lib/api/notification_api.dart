import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationAPI {
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
      print('getNotificationAppLaunchDetails');
      onNotification.add(messages);
    }

    await localNotification.initialize(
      settings,
      onSelectNotification: (payload) async {
        print('localNotification.initialize');
        onNotification.add(messages);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messages = message;
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        // show message on banner from firebase messaging
        print('onMessage.listen');
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
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: 'hurn.sothea',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('a new onMessageOpenedApp event was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        onNotification.add(messages);
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
    RemoteNotification notification = message.notification!;
    print('showNotification');
    messages = message;
    var androidChannel = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notification',
      channelDescription: 'heello',
      importance: Importance.high,
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

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
