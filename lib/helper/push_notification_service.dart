import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  /// Ensures that notification permissions are granted and waits for the APNs token
  /// on iOS before attempting to subscribe to Firebase Cloud Messaging topics.
  /// On Android, topic subscription proceeds immediately.
  static Future<Map<String, dynamic>> subscribeTopicsSafely({
    String? schoolCode,
    String? studentId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    schoolCode ??= prefs.getString("schoolCode");
    studentId ??= prefs.getString("studentId");

    debugPrint("PushNotificationService: Subscribing topics: schoolCode=$schoolCode, studentId=$studentId");

    String? apnsToken;
    if (Platform.isIOS) {
      try {
        NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        debugPrint("PushNotificationService: iOS permission status = ${settings.authorizationStatus}");

        // Wait up to 20 seconds for the APNs token from iOS
        int retries = 0;
        while (retries < 20) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) {
            debugPrint("PushNotificationService: APNs token ready after $retries retries: $apnsToken");
            break;
          }
          await Future.delayed(const Duration(seconds: 1));
          retries++;
        }
      } catch (e) {
        debugPrint("PushNotificationService: Error requesting APNs token: $e");
      }

      if (apnsToken == null) {
        debugPrint("PushNotificationService: APNs token still null. Cannot subscribe topics on iOS yet.");
        return {
          "success": false,
          "error": "APNs token is not ready yet from Apple. Please ensure Notifications are allowed in iOS Settings.",
          "apnsToken": null,
          "subscribed": <String>[],
          "failed": <String>[],
        };
      }
    }

    List<String> subscribed = [];
    List<String> failed = [];

    if (schoolCode != null && schoolCode.trim().isNotEmpty) {
      final topic = schoolCode.trim();
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        subscribed.add(topic);
        debugPrint("PushNotificationService: Successfully subscribed to topic '$topic'");
      } catch (e) {
        failed.add("$topic: $e");
        debugPrint("PushNotificationService: Failed subscribing to '$topic': $e");
      }
    }

    if (studentId != null && studentId.trim().isNotEmpty) {
      final topic = studentId.trim();
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        subscribed.add(topic);
        debugPrint("PushNotificationService: Successfully subscribed to topic '$topic'");
      } catch (e) {
        failed.add("$topic: $e");
        debugPrint("PushNotificationService: Failed subscribing to '$topic': $e");
      }
    }

    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await prefs.setString("fcm_token", fcmToken);
      }
    } catch (e) {
      debugPrint("PushNotificationService: Error getting FCM token: $e");
    }

    return {
      "success": failed.isEmpty && subscribed.isNotEmpty,
      "subscribed": subscribed,
      "failed": failed,
      "apnsToken": apnsToken,
      "fcmToken": fcmToken,
    };
  }
}
