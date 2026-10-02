import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'student/notification_list_screen.dart';

class Firebaseapi {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      announcement: true,
      alert: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(
        message.notification?.title,
        message.notification?.body,
        imageUrl: message.data['image'],
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationNavigation(message);
    });

    final token = await _firebaseMessaging.getToken();
  }

  static void _handleNotificationNavigation(RemoteMessage message) {
    final payload = message.data;

    if (payload.isNotEmpty) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const NotificationListScreen()),
      );
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  static Future localNotiInit() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_notification');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    final LinuxInitializationSettings linuxSettings =
    LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );


    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();


    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
    );
  }

  @pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse notificationResponse) {
    try {
      final payload = notificationResponse.payload;
      if (payload != null && payload.isNotEmpty) {
        _openFile(payload);
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationListScreen()),
        );
      }
    } catch (e) {
      debugPrint("Error handling notification tap: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      showLocalNotification(message.notification?.title, message.notification?.body);
    } catch (e) {
      debugPrint("Error in FCM background handler: $e");
    }
  }

  static void showLocalNotification(String? title, String? body, {String? imageUrl}) async {
    String? bigPicturePath;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final filePath =
              '${tempDir.path}/notif_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          bigPicturePath = file.path;
        } else {
        }
      } catch (e) {
      }
    }

    final styleInformation = bigPicturePath != null
        ? BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      contentTitle: title,
      summaryText: body,
    )
        : null;

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: styleInformation,
      icon: '@drawable/ic_notification',
      playSound: true,
      color: const Color(0xFF2d4c9c),
    );

    NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: imageUrl,
    );
  }

  Future<void> showLocalNotificationLocal(String? title, String? body, String? filePath) async {

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      Random.secure().nextInt(100000).toString(),
      'High Importance Notification',
      importance: Importance.max,
      icon: '@drawable/ic_notification',
      priority: Priority.high,
      playSound: true,
      color: const Color(0xFF2d4c9c),
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification'),
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      ledColor: const Color(0xFF2d4c9c),
    );

    NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: filePath,
    );
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "smart-school-3f62a",
      "private_key_id": "7703fcfbcea09bf46dc924a620a93abbd0f29440",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADAN...END PRIVATE KEY-----\n",
      "client_email": "smart-school@smart-school-3f62a.iam.gserviceaccount.com",
      "client_id": "102784367706634291305",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/smart-school%40smart-school-3f62a.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }
}

Future<void> _openFile(String filePath) async {
  final result = await OpenFilex.open(filePath);
}

@pragma('vm:entry-point')
void onNotificationTapBackground(NotificationResponse notificationResponse) {
  final payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    _openFile(payload);
  }
}
