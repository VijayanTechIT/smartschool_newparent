// import 'dart:convert';
// import '../student/StudentModel.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../signinsignup/userapicontrol.dart';
// import '../signinsignup/otpscreen.dart';
//
// import '../student/devfile.dart';
// class Smssendapi{
//
//
//
//
//
//
//   Future generateotp(BuildContext context,String mobile)async{
//     print("SUCCEDNSKJDB");
//
//     UserRecord().getmobileDataValue(mobile).then((onValue)async{
//       print("OnValue : $onValue");
//       if(jsonDecode(onValue) == "success") {
//         var orderUrltt = "http://www.smsalert.co.in/api/mverify.json?apikey=66cd641631e24&sender=VJNTEC&mobileno=$mobile&template=Dear User, [otp] is the OTP for your login at Edu Portal. In case you have not requested this, please contact us at helpdesk@vijayantech.com - Vijayan Tech";
//         final response = await http.post(Uri.parse(orderUrltt));
//
//         print("sms data: ${response.statusCode} ${response.body}");
//         if (response.statusCode == 200) {
//           print("INVOICE ID RESPPONSE: ${response.body}");
//           // var data = json.decode(response.body);
//           Navigator.push(context, MaterialPageRoute(builder:(context) => Otpscreen(mobile: mobile)));
//
//           return "success";
//         } else {
//           showDialog(context: context, builder: (context){
//             return AlertDialog(
//               shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//               shadowColor: const Color(0xFF2d4c9c),
//               title: const Text('Data mismatch error'),
//               titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
//               content:const Text('Try Login with correct credentials ', style: TextStyle(fontSize: 16.0,color: Colors.black),),
//               actions: [
//                 TextButton(onPressed: (){
//                   Navigator.pop(context);
//                 },
//                     style:ButtonStyle(
//                       shape:WidgetStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                       ),alignment: Alignment.bottomRight,
//                       backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
//                     ),child: const Padding(
//                       padding: EdgeInsets.only(left:20.0,right:20.0),
//                       child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
//                     )),
//               ],
//             );
//           });
//           return "null";
//         }
//       }else{
//
//         showDialog(context: context, builder: (context){
//           return AlertDialog(
//             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//             shadowColor: const Color(0xFF2d4c9c),
//             title: const Text('Not Found!'),
//             titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
//             content:const Text('Mobile Number does not exist.Try Login with correct credentials ', style: TextStyle(fontSize: 16.0,color: Colors.black),),
//             actions: [
//               TextButton(onPressed: (){
//                 Navigator.pop(context);
//               },
//                   style:ButtonStyle(
//                     shape:WidgetStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                     ),alignment: Alignment.bottomRight,
//                     backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
//                   ),child: const Padding(
//                     padding: EdgeInsets.only(left:20.0,right:20.0),
//                     child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
//                   )),
//             ],
//           );
//         });
//         return "null";
//       }
//     });
//   }
//
//   Future validateotp(BuildContext context,String otp,String mobile)async {
//     print("SUCCEDNSKJDB: $otp");
//
//       var orderUrldd ="http://www.smsalert.co.in/api/mverify.json?apikey=66cd641631e24&mobileno=$mobile&code=$otp";
//       final response = await http.post(Uri.parse(orderUrldd));
//
//       print("sms data: ${response.statusCode} ${response.body}");
//       if(response.statusCode == 200){
//         print("INVOICE ID RESPPONSE: ${response.body}");
//
//         UserRecord().getmobileData(mobile).then((onValue)async{
//           var userdata = onValue;
//           print("LODUICsd mafn,bvdfjvd  cbasfjkvadfklv: $userdata");
//           StudentWhole student = StudentWhole(id: '1', studentId: 'AKM01ST00001', schoolCode: 'AKM',
//               name: 'Rakshith', fatherName: '', fatherOccupation: '', dob: '', dateOfJoining: '',
//               studyingGrade: '', studyingSection: '',  phoneNumber: '',motherName: '',motherOccupation: '',
//                emisNumber: '',identificationMarks: '',joiningGrade: '',previousSchool: '',siblingId: '',siblingRelationship: '',
//               whatsappNo: '', bloodGroup: '', aadharNo: '', email: '', address: '', remarks: '',
//               status: '', photo: '', aadharPhoto: '');
//
//           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
//               StudentHome(student: student)
//               // HomePage(centerName:userdata['centerName'] ,
//               //     code: userdata['center_code'], username: userdata['username'], emailId: userdata['emailId'],
//               //     userpassword: userdata['userpassword']
//               ));
//
//         });
//         var data = json.decode(response.body);
//
//         return "data";
//       }else{
//         showDialog(context: context, builder: (context){
//           return AlertDialog(
//             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//             shadowColor: const Color(0xFF2d4c9c),
//             title: const Text('SMS Error'),
//             titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
//             content:const Text('SMS validation failed.Try again after sometime', style: TextStyle(fontSize: 16.0,color: Colors.black),),
//             actions: [
//               TextButton(onPressed: (){
//                 Navigator.pop(context);
//               },
//                   style:ButtonStyle(
//                     shape:WidgetStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                     ),alignment: Alignment.bottomRight,
//                     backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
//                   ),child: const Padding(
//                     padding: EdgeInsets.only(left:20.0,right:20.0),
//                     child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
//                   )),
//             ],
//           );
//         });
//         return 0;
//       }
//     }
//   }
//
