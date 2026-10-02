import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_school_parent/internet_conn/internet_connection_bloc.dart';
import 'package:smart_school_parent/student/no_internet_screen.dart';

import '../constants.dart';
import '../helper/notificationApi.dart';
import '../helper/notification_model.dart';
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
        studentId!)
        .then((value) {
      setState(() {
        notifications = value;
        isLoading = false;
      });
              });
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
          // height:screenHeight*0.13,
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
