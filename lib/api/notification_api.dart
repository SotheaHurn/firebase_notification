import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messages = message;
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        //show message on banner from firebase messaging
        // localNotification.show(
        //   notification.hashCode,
        //   notification.title,
        //   notification.body,
        //   NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       channel.id,
        //       channel.name,
        //       channelDescription: channel.description,
        //       importance: channel.importance,
        //       icon: '@mipmap/ic_launcher',
        //     ),
        //   ),
        //   payload: 'hurn.sothea',
        // );

        localNotification.zonedSchedule(
            notification.hashCode,
            notification.title,
            notification.body,
            tz.TZDateTime.from(
                DateTime.now().add(const Duration(seconds: 12)), tz.local),
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                importance: channel.importance,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
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
  }
}
