import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_school_parent/academic_bloc/academic_year_bloc.dart';
import 'package:smart_school_parent/fees_payment/fees_payment_bloc.dart';
import 'package:smart_school_parent/fees_payment/fees_term/fees_term_bloc.dart';
import 'package:smart_school_parent/home_Work/home_work_bloc/home_work_bloc.dart';
import 'package:smart_school_parent/student/class_test_bloc.dart';
import 'package:smart_school_parent/student/devfile.dart';
import 'package:smart_school_parent/student/marks_bloc.dart';
import 'package:smart_school_parent/transport/bus_bloc.dart';
import '../firebase_options.dart';
import '../signinsignup/login.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../student/notification_list_screen.dart';
import 'app_config.dart';
import 'constants.dart';
import 'fees_payment/fees_scholarship/fees_scholarship_list/fees_scholarship_list_bloc.dart';
import 'fees_payment/fees_type/fees_type_bloc.dart';
import 'firebaseApi.dart';
import 'internet_conn/internet_connection_bloc.dart';
import 'login/login_bloc.dart';
final navigatorKey = GlobalKey<NavigatorState>();


@pragma('vm:entry-point') // Fix for AOT compilation
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  try {
    if (message.notification != null) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const NotificationListScreen(),
      ));
    }
  } catch (e) {
    debugPrint("Background notification handling error: $e");
  }
}


Future<void> _initialization() async {
  try {
    await Firebaseapi.localNotiInit();
  } catch (e, stack) {
    debugPrint("Local notification init error: $e\n$stack");
  }

  try {
    // 🔔 Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification?.title ?? '';
        final body = message.notification?.body ?? '';
        final image = message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl ??
            message.data['image'];

        Firebaseapi.showLocalNotification(title, body, imageUrl: image);
      }
      try {
        FirebaseAnalytics.instance.logEvent(name: 'fcm_opened', parameters: {
          'message_id': message.messageId ?? "",
          'screen': 'OwnerNotification',
        });
      } catch (_) {}
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    // Check if the app was launched via a notification tap
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      try {
        FirebaseAnalytics.instance.logEvent(name: 'fcm_opened', parameters: {
          'message_id': initialMessage.messageId ?? "",
          'screen': 'OwnerNotification',
        });
      } catch (_) {}

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationNavigation(initialMessage);
      });
    }
  } catch (e, stack) {
    debugPrint("FCM initialization error: $e\n$stack");
  }
}

void _handleNotificationNavigation(RemoteMessage message) {
  try {
    if (message.notification != null) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final image = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['image'];

      Firebaseapi.showLocalNotification(title, body, imageUrl: image);
    }

    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => const NotificationListScreen(),
    ));
  } catch (e) {
    debugPrint("Notification navigation error: $e");
  }
}

void main({String? flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, stack) {
    debugPrint("Firebase.initializeApp error: $e\n$stack");
  }


  // Determine app settings based on flavor
  String appName = "Smart School";
  String splashImage = "images/splashNew.png"; // Default splash

  if (flavor == "jsAcademy") {
    appName = "Jai ShriRam Parent";
    splashImage = "images/jsAcademySplash.png";
  } else if (flavor == "shreeKamadhenuSchool") {
    appName = "Shree Kamadhenu School";
    splashImage = "images/splashNew.png";
  }
  else if (flavor == "ssv") {
    appName = "SSV Sivagiri";
    splashImage = "images/ssv.png";
  }else if(flavor == 'mrs'){
    appName = "MRS Matric School";
    splashImage = "images/mrsSplash.png";
  }
  else if (flavor == "classConnect") {
    appName = "Class Connect";
    splashImage = "images/classConnect.png";
  }
  else if (flavor == "smartSchool") {
    appName = "Class Connect";
    splashImage = "images/classConnect.png";
  }
  else if (flavor == "kv") {
    appName = "Karunya Vidya Bhavan";
    splashImage = "images/kvSchoolImage.png";
  }
  else if (flavor == "kg") {
    appName = "Komarasamy Gounder MHSS";
    splashImage = "images/kgSplash.png";
  }
  // Set the global config
  AppConfig.setFlavor(flavor ?? appName);
  Constants.init(flavor ?? appName); // initialize URLs once here
  runApp(MyApp(appName: appName, splashImage: splashImage));
  _initialization();
}

class MyApp extends StatelessWidget {
  final String appName;
  final String splashImage;

  const MyApp({super.key, required this.appName, required this.splashImage});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
    providers: [
        BlocProvider(
        create: (context) => LoginBloc()..add(CheckLoginStatus()),),
       BlocProvider(create: (context) => BusBloc()),
      BlocProvider(
        create: (context) => MarksBloc()),
      BlocProvider(
          create: (context) => HomeWorkBloc()),
       BlocProvider(create:(_)=> InternetConnectionBloc()),
      BlocProvider(create:(_)=> StClassTestBloc()),
      BlocProvider(create:(_)=> AcademicYearBloc()),
      BlocProvider(create:(_)=> FeesTermBloc()),
      BlocProvider(create:(_)=> FeesTypeBloc()),
      BlocProvider(create:(_)=> FeesPaymentBloc()),
      BlocProvider(create: (_) => FeesScholarshipListBloc(),)
    ],
  child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(color: Color(0xFF2d4c9c)),
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home:  SplashScreen(splashImage:splashImage),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String splashImage;

  const SplashScreen({super.key, required this.splashImage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        Widget nextScreen = const Login(); // Default to login screen

        if (state is LoginSuccess) {
          nextScreen = StudentHome(student: state.student);
        }

        return AnimatedSplashScreen(
          splashIconSize: 700,
          splash:  Image(
            width: 500.0,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            image: AssetImage(splashImage),
          ),
          duration: 1500,
          splashTransition: SplashTransition.scaleTransition,
          animationDuration: const Duration(milliseconds: 450),
          nextScreen: nextScreen,
        );
      },
    );
  }
}