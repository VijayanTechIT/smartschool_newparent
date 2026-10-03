import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_parent/academic_bloc/academic_year_bloc.dart';
import 'package:smart_school_parent/fees_payment/fees_payment_screen.dart';
import 'package:smart_school_parent/fees_payment/fees_term/fees_term_bloc.dart';
import 'package:smart_school_parent/fees_payment/fees_type/fees_type_bloc.dart';
import 'package:smart_school_parent/helper/attendancemodel.dart';
import 'package:smart_school_parent/helper/marksApi.dart';
import 'package:smart_school_parent/home_Work/home_work_bloc/home_work_bloc.dart';
import 'package:smart_school_parent/internet_conn/internet_connection_bloc.dart';
import 'package:smart_school_parent/models/exams_model_class.dart';
import 'package:smart_school_parent/models/marks_model_class.dart';
import 'package:smart_school_parent/parent_settings/parent_app_model.dart';
import 'package:smart_school_parent/parent_settings/parent_settings_api.dart';
import 'package:smart_school_parent/student/attScreen.dart';
import 'package:smart_school_parent/student/class_test_bloc.dart';
import 'package:smart_school_parent/student/marksScreen.dart';
import 'package:smart_school_parent/student/switch_sibling.dart' show SwitchSibling;
import 'package:lottie/lottie.dart';
import 'package:smart_school_parent/transport/bus_event.dart';
import '../fees_payment/fees_payment_bloc.dart';
import '../fees_payment/fees_scholarship/fees_scholarship_list/fees_scholarship_list_bloc.dart';
import '../helper/exam_api.dart';
import '../home_Work/home_work.dart';
import '../student/notification_list_screen.dart';

import '../helper/notificationApi.dart';
import '../helper/notification_model.dart';
import '../helper/sibling_api_loca.dart';
import '../models/siblings_model.dart';
import '../student/profile_information.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../helper/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../constants.dart';
import '../helper/attendanceapi.dart';
import '../signinsignup/login.dart';
import '../student/StudentModel.dart';
import '../student/student_home_card.dart';
import '../student/studentapi.dart';

import '../transport/bus_bloc.dart';
import '../transport/bus_state.dart';
import '../transport/bus_transport.dart';
import 'add_siblings_page.dart';
import 'class_test_screen.dart';
import 'document_page.dart';
import 'marks_bloc.dart';
import 'no_internet_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key,required this.student});

  final StudentWhole student;

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {

  final PageController pageController = PageController();
  Future<void> fetchSiblings() async {
    final data = await DatabaseHelper().getSiblings();
    setState(() {
      siblings = data.map((e) => SiblingModel.fromMap(e)).toList();
    });
  }
  var imagepath = Constants.imagePath;
  String attrows = "0";
  double attrow = 0.0;
  String attValues = '0';
  double attValue = 0.0;
  int notification = 0;
  List<NotificationModel> notifications = [];
  var oneonone = 0;
  List<MarksModelClass> marksList = [];

  List<SiblingModel> siblings = [];

  List<AttendanceWhole> attendance = [];
  var totalMarks = 0;
  var marksScored = 0;
  ParentSettingsModel parentSettingsModel = ParentSettingsModel(
      schoolCode: '',
      notification: 'deny',
      notificationPriority: 0,
      marks: 'deny',
      marksPriority: 0,
      attendance: 'deny',
      attendancePriority: 0,
      transport: 'deny',
      transportPriority: 0,
      classTest: 'deny',
      classTestPriority: 0,
      feesPayment: 'deny',
      feesPaymentPriority: 0,
      homework: 'deny',
      homeworkPriority: 0,
      payButtonShow: 'deny',
      myAchievements: 'deny',
      myAchievementsPriority: 0,
      createdBy: '',
      updatedBy: '');
  String schoolName = '';
  String schoolAddress = '';
  var examName = "";
  List<ExamsModelClass> exams = [];
  late Timer _timer;
  @override
  void initState() {
    schoolName = widget.student.schoolName ;
    schoolAddress = widget.student.schoolAddress ;
    // Initialize the timer to auto-scroll the pages;
    _timer = Timer.periodic(const Duration(milliseconds:2500), (Timer timer) {
      if (pageController.hasClients) {
        int nextPage = pageController.page!.toInt() + 1;

        if (nextPage >= imagePaths.length) {
          nextPage = 0; // Loop back to the first page
        }

        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    _fetchData();
    PushNotificationService.subscribeTopicsSafely(
      schoolCode: widget.student.schoolCode,
      studentId: widget.student.studentId,
    );
    super.initState();
  }
  bool isLoading = false;
  bool isFetchLoading = false;
  List<dynamic> documents = [];
  bool payButtonStatus = false;
  void _fetchData(){
    setState(() {
      isLoading = true;
      isFetchLoading = true;
    });
    fetchSiblings();
    // Get the current date
    final DateTime now = DateTime.now();

    final DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);


    final String startDate = DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
    // Compute the last date of the current month
    final DateTime lastDateOfMonth = DateTime(now.year, now.month + 1, 0);


   final String endDate = DateFormat('yyyy-MM-dd').format(lastDateOfMonth);
    // Student Api get doc
    StudentApi().getDocumentsByStudentId(widget.student.studentId,
        widget.student.schoolCode).then((value) async {

      if(value == null){}else {
        // Assign null if value is null, otherwise assign the value
        documents = value;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("schoolCode", widget.student.schoolCode);
      prefs.setString("studentId", widget.student.studentId);
      context.read<HomeWorkBloc>().add(FetchHomework(
          schoolCode: widget.student.schoolCode,
          sectionName: widget.student.studyingSection,
          gradeName: widget.student.studyingGrade));
      setState((){
         isFetchLoading = false;
      });
    });

// Student Api get doc
    NotificationApi().getAllNotificationStudent(widget.student.schoolCode,widget.student.studentId).then((value){

      // Assign null if value is null, otherwise assign the value
      notifications = value;
      notification = value.length;

      setState((){});
    });

    context.read<StClassTestBloc>().
    add(FetchStClassTest(
        widget.student.schoolCode,
        widget.student.studentId));
    // Example of processing the attendance data
    AttendanceRecord().attendancebystudent(widget.student.studentId, widget.student.schoolCode, startDate,endDate,).then((attendanceData) {
      // Assuming each record has a 'status' field to indicate attendance


      attendance = attendanceData;
      attrow = 0;
      attValue = 0;
      attValues = '0';
      attrows = '0';
      for (var record in attendanceData) {
        bool isMorningValue = record.morning == "" || record.morning == null;

        bool isEveningValue = record.evening == "" || record.morning == null;

        if (!isMorningValue && !isEveningValue) {
          attrow += 1;
        }
        else if (!isMorningValue || !isEveningValue) {
          attrow += 0.5;
        }
      }
      for (var record in attendanceData) {
        bool isMorningPresent = record.morning == 'Present';
        bool isEveningPresent = record.evening == 'Present';
        if (isMorningPresent && isEveningPresent) {
          attValue += 1;
        }
        else if (isMorningPresent || isEveningPresent) {
          attValue += 0.5;
        }
      }
      // Round values like 2.0, 3.0 to integers
      if (attValue % 1 == 0) {
        attValues = attValue.toInt().toString();
      }else{
        attValues = attValue.toString();
      }
      if (attrow % 1 == 0) {
        attrows = attrow.toInt().toString();
      }else{
        attrows = attrow.toString();
      }

      setState((){});

      // Perform additional actions with presentCount if needed
    }).catchError((error) {

    });
    ExamsApi().getExamsData(widget.student.schoolCode).then((onValue){
      exams = onValue;
    });
    ParentSettingApi()
        .getParentSettings(widget.student.schoolCode)
        .then((value) {
      if (value != null) {
        payButtonStatus = value.payButtonShow.toLowerCase() != 'deny';
        homeConfig = {
          HomeItem.notification: HomeItemConfig(
            priority: value.notificationPriority,
            visible: isView(value.notification),
          ),
          HomeItem.attendance: HomeItemConfig(
            priority: value.attendancePriority,
            visible: isView(value.attendance),
          ),
          HomeItem.homework: HomeItemConfig(
            priority: value.homeworkPriority,
            visible: isView(value.homework),
          ),
          HomeItem.marks: HomeItemConfig(
            priority: value.marksPriority,
            visible: isView(value.marks),
          ),
          HomeItem.classTest: HomeItemConfig(
            priority: value.classTestPriority,
            visible: isView(value.classTest),
          ),
          HomeItem.transport: HomeItemConfig(
            priority: value.transportPriority,
            visible: isView(value.transport),
          ),
          HomeItem.feesPayment: HomeItemConfig(
            priority: value.feesPaymentPriority,
            visible: isView(value.feesPayment),
          ),
          HomeItem.achievements: HomeItemConfig(
            priority: value.myAchievementsPriority,
            visible: isView(value.myAchievements),
          ),
        };
      }

      setState(() {
        isLoading = false;
      });
    });

    context.read<MarksBloc>().add(FetchInitialMarks(
      widget.student.schoolCode,
      widget.student.studentId,
    ));


    MarksApi().getMarks(widget.student.schoolCode,widget.student.studentId).then((val){
      marksList = val;
      marksScored = val.fold<int>(0, (sum, item) => sum + (int.tryParse(item.mark.toString()) ?? 0));
      totalMarks = val.fold<int>(0, (sum, item) => sum + (int.tryParse(item.maxMarks.toString()) ?? 0));
      examName = val.first.examName ?? '';

    });
     final transport = widget.student.transport;

     if (transport != null &&
         transport.isNotEmpty &&
         transport.toLowerCase() != 'null' &&
         int.tryParse(transport) != null) {
       context.read<BusBloc>().add(
         FetchBusById(
           widget.student.schoolCode,
           int.parse(widget.student.transport!),
    ),
       );
     }

   }

  Future sharedData() async{
    DatabaseHelper().deleteAllSiblings();
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    prefs.clear();
  }

  List<String> imagePaths = [
    'images/student4.jpg',
    'images/student5.jpg',
    'images/student3.jpeg',
    'images/student1.jpg',
    'images/student2.webp',
  ];
  final Map<HomeItem, HomeItemConfig> defaultConfig = {
    HomeItem.notification: HomeItemConfig(priority: 1, visible: true),
    HomeItem.attendance: HomeItemConfig(priority: 2, visible: true),
    HomeItem.homework: HomeItemConfig(priority: 3, visible: true),
    HomeItem.marks: HomeItemConfig(priority: 4, visible: true),
    HomeItem.classTest: HomeItemConfig(priority: 5, visible: true),
    HomeItem.transport: HomeItemConfig(priority: 6, visible: true),
    HomeItem.feesPayment: HomeItemConfig(priority: 7, visible: true),
    HomeItem.achievements: HomeItemConfig(priority: 8, visible: true),
  };

  bool isView(String? value) {
    return value?.toLowerCase() != 'deny';
  }
  Map<HomeItem, HomeItemConfig> homeConfig = {};

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = 600.0; // Your defined max width
    double effectiveWidth = screenWidth > maxWidth ? maxWidth : screenWidth;

    return BlocBuilder<InternetConnectionBloc, InternetConnectionState>(

    builder: (context, state) {
    if(state is InternetConnected){
    return BlocListener<InternetConnectionBloc, InternetConnectionState>(
      listener: (context, state) {
        if (state is InternetConnected) {
          setState(() {
            _fetchData(); // Reload when internet reconnects
          });
        }
      },
  child: Center(
    child: Container(
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Set your desired max width

        child: Center(
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 0) {

                _fetchData();
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Text('Welcome ${widget.student.name} !!',
                  style: const TextStyle(fontSize:16,color:Colors.white),),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                drawer: Drawer(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    backgroundColor: Colors.white,
                    child:SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 170,
                            child: DrawerHeader(
                                child: Row(
                                  children: [
                                    CircleAvatar(radius:40,backgroundColor:Color(0xFF2d4c9c),
                                      child:

                                      (widget.student.photo != '')? ClipOval(
                                        clipBehavior: Clip.antiAliasWithSaveLayer,



                                        child: Image(
                                          height: 75,width:75,
                                          fit: BoxFit.cover,
                                          image: NetworkImage('$imagepath/${widget.student.photo}'),
                                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace){
                                            return const Icon(Icons.person);
                                          },
                                        ),
                                      ) :Icon(Icons.person,size: 40,color:Colors.white)
                                      ,),
                                    SizedBox(width: 30,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.student.name,textAlign: TextAlign.left,style: const TextStyle(fontSize: 18,color:Colors.black),),
                                        Text(widget.student.studentId,style: const TextStyle(fontSize: 14,color: Colors.black),),
                                        Text("${widget.student.studyingGrade} - ${widget.student.studyingSection}",
                                          style: const TextStyle(fontSize: 14,color: Colors.black),)
                                      ],
                                    ),



                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Column(
                                children:[

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(height: 40,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.home_outlined,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left:8.0),
                                              child: Text('Home',style: TextStyle(fontSize: 16,),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(height: 35,
                                      child: GestureDetector(
                                        onTap: (){

                                          Navigator.push(context, MaterialPageRoute(builder: (
                                              context)=> StudentProfileInformation(student: widget.student)));

                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.person_outline_sharp,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left:8.0),
                                              child: Text('Profile Information',style: TextStyle(fontSize: 16,),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(height: 35,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=> const AddSiblingsPage())).then((val){
                                            fetchSiblings();
                                          });

                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.people_alt_outlined,size: 20,),

                                            Padding(
                                              padding: EdgeInsets.only(left:8.0),
                                              child: Text('Add Sibling',style: TextStyle(fontSize: 16,),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(height: 35,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=> SwitchSibling(
                                            siblings: siblings,
                                            studentId: widget.student.studentId,
                                            schoolCode: widget.student.schoolCode,
                                          )));
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.account_tree_outlined,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left:8.0),
                                              child: Text('Switch Account',style: TextStyle(fontSize: 16,),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(height: 35,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DocumentPage(
                                                documents: documents,
                                                student: widget.student,

                                              ),
                                            ),
                                          ).then((onValue){
                                            _fetchData();
                                          });       },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.book_outlined,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left:8.0),
                                              child: Text('Documents',style: TextStyle(fontSize: 16,),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(color: Colors.grey,),
                                  const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Padding(
                                      padding: EdgeInsets.only(right:180.0),
                                      child: Text('GENERAL',style: TextStyle(color:Colors.grey),),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(height: 35,
                                      child: GestureDetector(
                                        onTap: ()async{
                                          await sharedData().then((onValue){

                                            // Also unsubscribe from all siblings
                                            for (final sibling in siblings) {
                                              FirebaseMessaging.instance.unsubscribeFromTopic(sibling.studentId);
                                            }

                                            Navigator.pushReplacement(context,MaterialPageRoute(
                                                builder:(context)=> const Login()));
                                          });


                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.logout,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left:8.0),
                                              child: Text('Logout',style: TextStyle(fontSize: 16,),),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 50,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child:Text('App Version : ${Constants.appVersion}',
                                          textAlign: TextAlign.center,)
                                    ),
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    )

                ),
                body:SizedBox(
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                           _fetchData();
                        },

                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: <Widget>[
                                  SizedBox(height: 6,),
                                  // Constrain the height of the PageView
                                  SizedBox(
                                    height: 250, // Adjust the height as per your requirement
                                    child: PageView.builder(
                                      controller: pageController,
                                      itemCount: imagePaths.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              ClipRRect(
                                                  borderRadius: BorderRadius.circular(15), child: Image(
                                                width:effectiveWidth * 0.9,
                                                image: AssetImage(imagePaths[index]),height: 220,fit: BoxFit.fill,)),
                                              const SizedBox(height: 5),
                                              SmoothPageIndicator(
                                                controller: pageController,
                                                count: 5,
                                                effect: const ScrollingDotsEffect(
                                                  activeDotColor: Colors.blue,
                                                  dotColor: Colors.grey,
                                                  dotHeight: 5,
                                                  dotWidth: 5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 5,
                                children: getOrderedItems()
                                    .map((item) => buildHomeItem(item,effectiveWidth))
                                    .toList(),
                              ),




                              const SizedBox(height:60),
                            ],
                          ),
                        ),
                      ),
                                // ✅ Overlay Loader
                                if (isLoading  || isFetchLoading) ...[
                          Positioned.fill(
                          child: Container(
                          color: Colors.black.withOpacity(0.3), // dim background
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF2d4c9c),
                            ),
                          ),
                        ),
                      ),
                    ],
                      // if (isFetchLoading) ...[
                      //   Positioned.fill(
                      //     child: Container(
                      //       color: Colors.black.withOpacity(0.3), // dim background
                      //       child: const Center(
                      //         child: CircularProgressIndicator(
                      //           strokeWidth: 3,
                      //           color: Color(0xFF2d4c9c),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                            ]      ),
                ),
              ),
          ),
        ),
      ),
    ),
  ),
);
    }
    else{
      return NoInternetScreen(shouldPopOnReconnect: false);
    }
  },
);
  }

  Widget notificationCard(double effectiveWidth){

    return   GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationListScreen()));
      },
      child: StudentHomeCard(
        text: 'Notification',
        image: const CircleAvatar(
          backgroundColor: Color(0xFFFFECDF),
          radius: 25,
          child: Icon(Icons.notifications_active_outlined,
              color: Color(0xFFFF5722), size: 24),
        ),
        valueText: notification.toString(),
        height: 110,
        width: effectiveWidth * 0.43,
        bottomText: 'Last 30',
        bottomText2: 'Notifications',
        btColor: Colors.blue,
      ),
    );
  }

 Widget attendanceCard(double effectiveWidth){
    return   GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => AttendanceScreen(name: widget.student.name,
              student: widget.student,attendance: attendance),
        ));
      },
      child: StudentHomeCard(
        text: 'Attendance',
        image: const CircleAvatar(
          backgroundColor: Color(0xFFE0F8E9),
          radius: 25,
          child: Icon(Icons.calendar_today_rounded,
              color: Color(0xFF4CAF50), size: 24),
        ),
        valueText: "$attValues/$attrows",
        height: 110,
        width: effectiveWidth * 0.43,
        bottomText: 'This Month',
        bottomText2: 'Days',
        text3: 'Present',
        btColor: Colors.green,
      ),
    );
 }

  Widget homeworkCard(double effectiveWidth){

    return  GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HomeworkHistoryPage(
              gradeName: widget.student.studyingGrade,
              sectionName: widget.student.studyingSection,
              schoolCode: widget.student.schoolCode,
            ),
          ),
        );
      },
      child: BlocBuilder<HomeWorkBloc, HomeWorkState>(
        builder: (context, state) {
          int valueLength = 0;
          if(state is HomeWorkLoaded){
            valueLength = state.homeworks.length;
          }

          return StudentHomeCard(
            text: 'Homework',
            image: CircleAvatar(
              backgroundColor: Color(0xFFE8EAF6),
              radius: 25,

              child:  ClipOval(
                clipBehavior: Clip.antiAliasWithSaveLayer,

                child: Image.asset(
                  'images/homework.gif',
                  width: 30, // Adjust size if needed
                  height: 30,
                  fit: BoxFit.fill,
                ),
              ),   ),
            valueText: valueLength.toString(),
            height: 110,
            width: effectiveWidth * 0.43,
            bottomText: 'Recent',
            bottomText2: 'Homework',
            btColor: Colors.indigo,
          );
        },
      ),
    );
  }

  Widget marksCard(double effectiveWidth){
    return    GestureDetector(
      onTap: (){
        if(marksList.isEmpty){}else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => MarksBloc(initialMarks: marksList),
                child: MarksScreen(marksList: marksList, examList: exams,
                  examName:examName, student: widget.student,),
              ),
            ),
          );}
      },
      child: Card(

        child: Container(
            height:110,
            width:effectiveWidth * 0.45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Row(
                          children: [
                            Text("Marks",
                              style: TextStyle(fontSize:16),),
                            Text(' (Term-wise)', style: TextStyle(fontSize: 10)),

                          ],
                        ),
                      ),

                      SizedBox(height: 5,),
                      Row(
                        children: [
                          CircleAvatar(
                              backgroundColor: Color(0xFFE0F8E9),
                              radius: 25,
                              child:Center(child:Icon(
                                Icons.school,
                                color: Colors.black, // Change the color
                                size: 24,           // Adjust the size
                              ))

                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                totalMarks == 0
                                    ? Text("No data found", style: TextStyle(fontSize: 12,
                                ))
                                    : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$marksScored/$totalMarks',
                                        style: TextStyle(fontSize: 18)),
                                    Row(
                                      children: [
                                        Text("scored in",
                                            style: TextStyle(color: Colors.black,
                                                fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text(examName, style: TextStyle(fontSize: 12)),
                                  ],
                                )


                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  // Lottie.asset('images/lottie.json'),
                  // Image(
                  //     height:100,
                  //     image:AssetImage("images/graph.png"))
                ],
              ),
            )
        ),
      ),
    );
  }

  Widget classTestCard(double effectiveWidth){
    return  GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IndividualClassTestReport(
              student: widget.student,
            ),
          ),
        ).then((onValue){
          _fetchData();
        });
      },
      child: BlocBuilder<StClassTestBloc, StClassTestState>(
        builder: (context, state) {
          int classTestCount = 0;
          if(state is StClassTestLoaded){
            classTestCount = state.classTestList
                .where((s)=> s.mark.toLowerCase() != 'ab').length;
          }
          return  Card(

            child: Container(
                height:110,
                width:effectiveWidth * 0.45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left:10),
                            child:Row(
                              children: [
                                Text("Class Test",
                                  style: TextStyle(fontSize:16),),

                              ],
                            ),
                          ),

                          SizedBox(height: 5,),
                          Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Color(0xFFE0F8E9),
                                  radius: 25,
                                  child:Center(child:Icon(
                                    Icons.edit_note,
                                    color: Colors.black, // Change the color
                                    size: 24,           // Adjust the size
                                  ))

                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    classTestCount == 0
                                        ? Text("No test records\nfound", style: TextStyle(fontSize: 12,
                                    ))
                                        : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$classTestCount',
                                            style: TextStyle(fontSize: 18)),
                                        Row(
                                          children: [
                                            Text("Test Records",
                                                style: TextStyle(color: Colors.black,
                                                    fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Text('Found', style: TextStyle(fontSize: 12)),
                                      ],
                                    )


                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),

                    ],
                  ),
                )
            ),
          );

        },
      ),
    );
  }
  Widget transportCard(double effectiveWidth){
    return   BlocBuilder<BusBloc, BusState>(
      builder: (context, state) {

        return GestureDetector(  onTap: () {
          if(widget.student.transport != '' ) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BusTransportScreen(
                      student: widget.student,
                    ),
              ),
            ).then((onValue) {
              _fetchData();
            });
          }   else{
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BusTransportScreen(
                      student: widget.student,
                    ),
              ),
            ).then((onValue) {
              _fetchData();
            });
          }                      },

          child: Card(
            child: Container(
                height: 110,
                width: effectiveWidth * 0.43,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      Column(

                        children: [

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 50),
                              child: Text(
                                'Transport',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Image centered
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Lottie.asset(
                                'images/MovingBus.json',
                                height: 70,
                                width: 127,
                              ),
                            ),
                          ),
                        ],
                      )


                    ],
                  ),
                )
            ),
          ),
        );
      },
    );
  }
  Widget feesPaymentCard(double effectiveWidth){
    return  GestureDetector(
      onTap: (){
        context.read<AcademicYearBloc>().add(
            FetchAcademicYears(widget.student.schoolCode));

        context.read<FeesTermBloc>().add(
            FetchFeeTerm(schoolCode:widget.student.schoolCode));

        context.read<FeesTypeBloc>().add(
            FetchFeeType(schoolCode:widget.student.schoolCode));
        context.read<FeesScholarshipListBloc>().add(
            FetchStudentScholarship(schoolCode: widget.student.schoolCode)
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  BlocProvider(
              create: (context) => FeesPaymentBloc()
                ..add(LoadInitialFeesPaymentData(
                    student: widget.student,
                    schoolCode: widget.student.schoolCode,
                    studentId:widget.student.id)), // Start loading
              child:  FeesPaymentScreen(
                schoolName : widget.student.schoolName,
                schoolAddress: widget.student.schoolAddress,
                student: widget.student,
                payButtonStatus: payButtonStatus,
                schoolCode: widget.student.schoolCode,
              ),
            ),
          ),
        );
      },
      child: Card(

        child: Container(
            height:110,
            width:effectiveWidth * 0.45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Row(
                          children: [
                            Text("Fee Payment",
                              style: TextStyle(fontSize:16),),
                            // Text(' (Term-wise)', style: TextStyle(fontSize: 10)),

                          ],
                        ),
                      ),

                      SizedBox(height: 5,),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10,
                              left: 30.0),
                          child: Image.asset( // Replaced Lottie.asset with Image.asset
                            'images/feesPayment.jpeg',
                            height: 60, // Retained height
                            width: 100, // Retained width
                            fit: BoxFit.contain, // Added a common fit property for images
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Lottie.asset('images/lottie.json'),
                  // Image(
                  //     height:100,
                  //     image:AssetImage("images/graph.png"))
                ],
              ),
            )
        ),
      ),
    );
  }
  Widget achievementsCard(double effectiveWidth){
    return  GestureDetector(

      child: Card(

        child: Container(
            height:110,
            width:effectiveWidth * 0.45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left:10),
                        child:Row(
                          children: [
                            Text("Achievements",
                              style: TextStyle(fontSize:16),),
                            // Text(' (Term-wise)', style: TextStyle(fontSize: 10)),

                          ],
                        ),
                      ),

                      SizedBox(height: 5,),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Image.asset( // Replaced Lottie.asset with Image.asset
                            'images/award.png',
                            height: 70, // Retained height
                            width: 127, // Retained width
                            fit: BoxFit.contain, // Added a common fit property for images
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            )
        ),
      ),
    );
  }

  Widget buildHomeItem(HomeItem item,double effectiveWidth) {
    switch (item) {
      case HomeItem.notification:
        return notificationCard(effectiveWidth);

      case HomeItem.attendance:
        return attendanceCard(effectiveWidth);

      case HomeItem.homework:
        return homeworkCard(effectiveWidth);

      case HomeItem.marks:
        return marksCard(effectiveWidth);

      case HomeItem.classTest:
        return classTestCard(effectiveWidth);

      case HomeItem.transport:
        return transportCard(effectiveWidth);

      case HomeItem.feesPayment:
        return feesPaymentCard(effectiveWidth);

      case HomeItem.achievements:
        return achievementsCard(effectiveWidth);
    }
  }

  List<HomeItem> getOrderedItems() {
    if (homeConfig.isEmpty) {
      return [];
    }
    final source = homeConfig.isEmpty ? defaultConfig : homeConfig;


    source.forEach((key, value) {
    });

    final entries = source.entries
        .where((e) => e.value.visible)
        .toList();


    entries.sort((a, b) {
      final pa = a.value.priority;
      final pb = b.value.priority;

      // 🔴 Both zero → keep order
      if (pa == 0 && pb == 0) return 0;

      // 🔴 Only a is zero → a goes last
      if (pa == 0) return 1;

      // 🔴 Only b is zero → b goes last
      if (pb == 0) return -1;

      // 🟢 Normal priority sort
      return pa.compareTo(pb);
    });


    for (var e in entries) {
    }

    final result = entries.map((e) => e.key).toList();


    return result;
  }



}

class HomeItemConfig {
  final int priority;
  final bool visible;

  HomeItemConfig({
    required this.priority,
    required this.visible,
  });
}

enum HomeItem {
  notification,
  attendance,
  homework,
  marks,
  classTest,
  transport,
  feesPayment,
  achievements,
}

