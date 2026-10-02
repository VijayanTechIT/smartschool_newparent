// import 'package:flutter/material.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'package:http/http.dart' as http;
// import '../helper/smssendapi.dart';
//
// class Otpscreen extends StatefulWidget {
//   const Otpscreen({super.key, required this.mobile});
//
//   final String mobile;
//
//   @override
//   State<Otpscreen> createState() => _OtpscreenState();
// }
//
// class _OtpscreenState extends State<Otpscreen> with CodeAutoFill {
//   final TextEditingController _otpController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     listenForCode();
//   }
//
//   @override
//   void dispose() {
//     _otpController.dispose();
//     cancel();
//     super.dispose();
//   }
//
//   @override
//   void codeUpdated() {
//     setState(() {
//       _otpController.text = code!;
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar:   AppBar(
//           backgroundColor: Color(0xFF2d4c9c),
//           centerTitle: true,
//           leading: Padding(
//             padding: const EdgeInsets.only(left:10.0),
//             child: IconButton(
//               onPressed: (){Navigator.pop(context);},
//               icon: Icon(Icons.arrow_back_ios,color:Colors.white),
//             ),
//           ),
//           // height:screenHeight*0.13,
//           title: const Text('ENTER OTP',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16.0,
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           )
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left:50.0,right: 50),
//               child: PinFieldAutoFill(
//                 controller: _otpController,
//                 codeLength: 4,
//                 onCodeSubmitted: (code) async {
//                   // await Smssendapi().validateotp(context,_otpController.text, widget.mobile);
//                 },
//                 onCodeChanged: (code) {
//                   if (code!.length == 4) {
//                     // Smssendapi().validateotp(context,_otpController.text, widget.mobile);
//
//                   }
//                 },
//                 decoration:UnderlineDecoration(
//                   textStyle: TextStyle(
//                     fontSize: 24, // Increased text size
//                     color: Colors.black,
//                     // fontWeight: FontWeight.bold,
//                   ),
//                   colorBuilder: FixedColorBuilder(Colors.black), // Bottom line color
//                   lineHeight: 1.0,
//                   gapSpace: 20.0, // Reduced line height (thickness of the underline)
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed:(){
//                 Smssendapi().validateotp(context,_otpController.text,widget.mobile).then((value){
//
//
//                 });
//               },
//               style: ButtonStyle(
//                 backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF2d4c9c)), // Button background color
//                 foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Icon color
//                 padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(12)), // Padding around the icon
//                 shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10), // Rounded corners
//                   ),
//                 ),
//                 shadowColor: WidgetStateProperty.all<Color>(Colors.grey), // Shadow color
//                 elevation: WidgetStateProperty.all<double>(5), // Elevation (shadow depth)
//               ),
//               child:Text('  Confirm  '),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
