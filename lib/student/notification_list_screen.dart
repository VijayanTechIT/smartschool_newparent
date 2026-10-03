import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_school_parent/internet_conn/internet_connection_bloc.dart';
import 'package:smart_school_parent/student/no_internet_screen.dart';

import '../constants.dart';
import '../firebaseApi.dart';
import '../helper/notificationApi.dart';
import '../helper/notification_model.dart';
import '../helper/push_notification_service.dart';
import '../utilis/loader.dart';
import 'full_screen_image.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});
  @override
  State<NotificationListScreen> createState() => NotificationListScreenState();
}

class NotificationListScreenState extends State<NotificationListScreen> {
  List<NotificationModel> notifications = [];
  late SharedPreferences prefs;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    var schoolCode = prefs.getString("schoolCode");
    var studentId = prefs.getString("studentId");

    // Fetch notifications and subscribe to the topic
    NotificationApi()
        .getAllNotificationStudent(schoolCode ?? "JS",
        studentId ?? "")
        .then((value) {
      setState(() {
        notifications = value;
        isLoading = false;
      });
    });
  }

  void _showDiagnosticsDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    String? apnsToken;
    if (Platform.isIOS) {
      try {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      } catch (_) {}
    }
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    final schoolCode = prefs.getString("schoolCode") ?? "Not Set";
    final studentId = prefs.getString("studentId") ?? "Not Set";

    if (mounted) {
      Navigator.pop(context);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        bool isReSubscribing = false;
        String? statusMessage;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentApns = apnsToken;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Push Diagnostics",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2d4c9c)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // APNs Status
                    if (Platform.isIOS) ...[
                      const Text("Apple APNs Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            currentApns != null ? Icons.check_circle : Icons.error,
                            color: currentApns != null ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentApns != null
                                  ? "Active (${currentApns.length > 20 ? '${currentApns.substring(0, 10)}...${currentApns.substring(currentApns.length - 8)}' : currentApns})"
                                  : "NOT SET (Apple APNs token is null - Push capability may be missing in provision profile)",
                              style: TextStyle(
                                color: currentApns != null ? Colors.green.shade800 : Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // FCM Token
                    const Text("FCM Device Token:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fcmToken ?? "No FCM token available",
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (fcmToken != null)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2d4c9c),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text("Copy FCM Token for Testing"),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: fcmToken!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("FCM Token copied to clipboard!")),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Topics
                    const Text("Subscribed Topics:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("• School Code: $schoolCode", style: const TextStyle(fontSize: 13)),
                    Text("• Student ID: $studentId", style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 16),

                    if (statusMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(statusMessage!, style: TextStyle(fontSize: 12, color: Colors.blue.shade900)),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text("Re-Subscribe"),
                            onPressed: isReSubscribing
                                ? null
                                : () async {
                                    setModalState(() {
                                      isReSubscribing = true;
                                      statusMessage = "Subscribing to topics...";
                                    });
                                    final res = await PushNotificationService.subscribeTopicsSafely(
                                      schoolCode: schoolCode,
                                      studentId: studentId,
                                    );
                                    if (Platform.isIOS) {
                                      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
                                    }
                                    fcmToken = await FirebaseMessaging.instance.getToken();
                                    setModalState(() {
                                      isReSubscribing = false;
                                      statusMessage = res["success"] == true
                                          ? "Successfully subscribed to: ${(res["subscribed"] as List).join(", ")}"
                                          : "Subscription result: ${res["error"] ?? (res["failed"] as List).join(", ")}";
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(color: Color(0xFF2d4c9c)),
                            ),
                            icon: const Icon(Icons.notifications_active, size: 18, color: Color(0xFF2d4c9c)),
                            label: const Text("Test Banner", style: TextStyle(color: Color(0xFF2d4c9c))),
                            onPressed: () {
                              Firebaseapi.showLocalNotification(
                                "Test Push Alert",
                                "Push notification banner is working on iPhone 17!",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Triggered local notification test banner!")),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
          backgroundColor: const Color(0xFF2d4c9c),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left:10.0),
            child: IconButton(
              onPressed: (){Navigator.pop(context);},
              icon: const Icon(Icons.arrow_back_ios,color:Colors.white),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: 'Push Notification Diagnostics',
              onPressed: _showDiagnosticsDialog,
            ),
          ],
          title: const Text('Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )
      ),
      body: isLoading?Center(
        child:Loader()
      ):BlocBuilder<InternetConnectionBloc, InternetConnectionState>(
      builder: (context, state) {
        if(state is InternetDisconnected && notifications.isEmpty){
          return NoInternetScreen(shouldPopOnReconnect: true);
        }else{
          if (notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'No notifications available.',
                  style: TextStyle(


                      fontSize:16  ),
                ),
              ),
            );
          }
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: ((context,index){

            NotificationModel paymentData = notifications[index];


            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: screenWidth* 0.95,
                child: Card(
                  elevation: 8.0,
                  color: Colors.white,
                  shadowColor: const Color(0xFFefc042),
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            SizedBox(width:180,
                              child: Text(paymentData.notificationTitle!,
                                  style:const TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: 18.0,color: Colors.black)),
                            ),
                            Text(paymentData.date!,  style:const TextStyle(fontWeight: FontWeight.w500,
                                fontSize: 12.0,color: Colors.black)),

                          ]
                        ),


                        const Padding(
                          padding: EdgeInsets.fromLTRB(0,2,8,2),
                          child: Divider(),

                        ),
                        Text(paymentData.notificationMessage!,
                            style:const TextStyle(fontWeight: FontWeight.w400,fontSize: 14.0,color: Colors.black)),
                        if (paymentData.imagePath != "" && paymentData.imagePath!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImage(
                                      imageUrl: "${Constants.url}/${paymentData.imagePath!}",
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Image.network(
                                    "${Constants.url}/${paymentData.imagePath!}",
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Loader();
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Text(
                                        '⚠️ Failed to load image',
                                        style: TextStyle(color: Colors.red),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )

                      ],
                    ),
                  ),
                ),
              ),
            );

          }));}
  },
),
    );
  }
}
