import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_school_parent/app_config.dart';

import '../constants.dart';
import '../helper/sibling_api_loca.dart';
import '../signinsignup/login.dart';
import '../student/devfile.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../signinsignup/userapicontrol.dart';
import '../student/studentapi.dart';
import '../utilis/urlref.dart';

class ParentLogin extends StatefulWidget {
  const ParentLogin({super.key});

  @override
  State<ParentLogin> createState() => _ParentLoginState();
}

class _ParentLoginState extends State<ParentLogin> {
  bool isForgotPasswordMode = false;
  bool isLoginLoading = false;
  bool isLoading = false;
  String loadingMessage = "";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final formkey = GlobalKey<FormState>();
  bool passwordVisible = true;


  Future <void> autosendemail(String email,String subject)async{
    String username = 'cashflw247@gmail.com';
    String password = 'mshplyacksqmqnlf';
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Student App Password Reset')
      ..recipients.add(email)
      ..subject = 'NewPassword to login'
      ..text =  'This is a system generated password.\nUse this password to login for Cash Flow App.'
      ..html = '<p>Smart School Student App new login password: <h3>$subject</h3></p>\n<p>Thank you\n</p><p>\nStudent App Admin</p>';

    // final sendReport =
    await send(message, smtpServer);
  }



  Future<void> _handleButtonPress(BuildContext context,String forgotpass) async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        loadingMessage = "Loading, please wait...";
      });
      String subject = forgotpass;
      try {
        await autosendemail(phoneController.text, subject);
        await UserRecord().forgotPass(phoneController.text, forgotpass).then((value){
          if (value == "success") {  showDialog(context: context, builder: (context){
            return AlertDialog(
              shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              shadowColor: const Color(0xFF1f0fc2),
              title: const Text('New Password Sent'),
              titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
              content:const Text('Login with the password send to registered mail id.  ', style: TextStyle(fontSize: 16.0,color: Colors.black),),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> const Login()));
                },
                    style:ButtonStyle(
                      shape:WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),alignment: Alignment.bottomRight,
                      backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF1f0fc2)),
                    ),child: const Padding(
                      padding: EdgeInsets.only(left:20.0,right:20.0),
                      child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                    )),
              ],
            );
          });
          } else {
            showDialog(context: context, builder: (context){
              return AlertDialog(
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                shadowColor: const Color(0xFF1f0fc2),
                title: const Text('Invalid email address'),
                titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
                content:const Text('Contact Admin ', style: TextStyle(fontSize: 16.0,color: Colors.black),),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> const Login()));
                  },
                      style:ButtonStyle(
                        shape:WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),alignment: Alignment.bottomRight,
                        backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF1f0fc2)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(left:20.0,right:20.0),
                        child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                      )),
                ],
              );
            });
          }

        });
      } catch (e) {
        setState(() {
          loadingMessage = "An error occurred";
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  final String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  final Random _rnd = Random();
  final formKey = GlobalKey<FormState>();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  // String forgotpass = getRandomString(7);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body:Form(
          key:formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40.0,10,40,10),
            child: Column(
                children:[
                  const SizedBox(height: 30,),
                  SizedBox(
                    child: Column(
                      children: [
                        const Align(
                            alignment:Alignment.topLeft,child: Text('Student Id',style: TextStyle(
                            color: Colors.grey
                        ),)),
                        const SizedBox(height: 5,),

                        TextFormField(
                          controller:phoneController,
                          style: const TextStyle(fontSize: 14.0),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            fillColor: const Color(0xFFe3e3e5),
                            filled:true,
                            hintText: 'Enter StudentId',
                            hintStyle: const TextStyle(fontSize: 14.0,color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none  // Change this to the desired bottom line color
                            ),    ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter StudentId";
                            }
                            else {
                              return null;
                            }
                          }, ),

                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 15,),
                        const Align(
                            alignment:Alignment.topLeft,
                            child: Text('Password(dob - ddMMyyyy)',style:TextStyle(fontSize: 14.0,color: Colors.grey),)),
                        const SizedBox(height: 5,),
                        TextFormField(
                          controller:passwordController,
                          style: const TextStyle(fontSize: 14.0),
                          keyboardType: TextInputType.name,obscureText:passwordVisible,
                          decoration: InputDecoration(
                            fillColor: const Color(0xFFe3e3e5),
                            filled:true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none  // Change this to the desired bottom line color
                            ),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(fontSize: 14.0,color: Colors.grey),
                            suffixIcon: IconButton(onPressed: (){
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                              icon: Icon(passwordVisible? Icons.visibility: Icons.visibility_off),color: const Color(0xFF2d4c9c),
                            ),

                          ),
                          validator: (password) {
                            if (password == null || password.isEmpty) {
                              return "Enter Password";
                            } else if (password.length < 8) {
                              return "Password must be at least 8 characters";
                            } else {
                              return null;
                            }
                          },  ),
                        // Align(
                        //     alignment:Alignment.topRight,child: TextButton(onPressed: (){
                        //   setState(() {
                        //     isForgotPasswordMode = true;
                        //   });
                        //   if(formkey.currentState!.validate()){
                        //
                        //     _handleButtonPress(context,forgotpass);
                        //
                        //
                        //
                        //   }
                        //
                        //   // _sendingSMS();
                        //
                        // }, child:isLoading? const Text('Loading,Please wait..'):  const Text('Forgot Password?',
                        //   style: TextStyle(color: Color(0xFF3f4a77)),))),

                        const SizedBox(height: 15,),
                        ElevatedButton(onPressed: isLoginLoading?(){}:()async{

                          if(formKey.currentState!.validate()){

                            setState((){
                              isLoginLoading = true;
                            });
                           try{
                             // Extract day, month, year
                             int day = int.parse(passwordController.text.substring(0, 2));
                             int month = int.parse(passwordController.text.substring(2, 4));
                             int year = int.parse(passwordController.text.substring(4, 8));

                             // Create DateTime object
                             DateTime dateTime = DateTime(year, month, day);

                             // Format to yyyy-MM-dd
                             String formattedDate = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

                             // String formattedDate = '${dateTime.day.toString().padLeft(2,'0')}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.year}';
                             StudentApi().signinstudent(formattedDate,phoneController.text.toUpperCase(),
                                 AppConfig.
                                 schoolCode
                             ).then((value) async {
                               if(value != null){
                                 await DatabaseHelper().addSibling(
                                     value.name,value.studentId,
                                     "student",formattedDate

                                 );
                                 setState((){
                                   isLoginLoading = false;
                                 });
                                 print("User Data ${value.transport}: $value");
                                 SharedPreferences prefs = await SharedPreferences.getInstance();
                                 prefs.setString('role', 'student');
                                 prefs.setString('studentId', value.studentId);
                                 prefs.setString('dob', value.dob);
                                 prefs.setString('StudentData', json.encode(value));
                                 prefs.setString('center_code', value.schoolCode);
                                 Navigator.pushReplacement(context,
                                     MaterialPageRoute(

                                         builder: (context) => StudentHome(student: value,)));

                                 // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> StudentHome(student: value)));

                               }else{
                                 setState((){
                                   isLoginLoading = false;
                                 });

                                 showDialog(context: context, builder: (context){
                                   return AlertDialog(
                                     shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                     shadowColor: const Color(0xFF2d4c9c),
                                     title: const Text('Incorrect Credentials'),
                                     titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
                                     content:const Text('Try Login with correct credentials ', style: TextStyle(fontSize: 16.0,color: Colors.black),),
                                     actions: [
                                       TextButton(onPressed: (){
                                         Navigator.pop(context);
                                       },
                                           style:ButtonStyle(
                                             shape:WidgetStateProperty.all(
                                               RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(20.0),
                                               ),
                                             ),alignment: Alignment.bottomRight,
                                             backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                                           ),child: const Padding(
                                             padding: EdgeInsets.only(left:20.0,right:20.0),
                                             child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                                           )),
                                     ],
                                   );
                                 });
                               }
                             });

                           }catch(e){
                             setState((){
                               isLoginLoading = false;
                             });
                             showDialog(context: context, builder: (context){
                               return AlertDialog(
                                 shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                 shadowColor: const Color(0xFF2d4c9c),
                                 title: const Text('Incorrect Credentials'),
                                 titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
                                 content:const Text('Try Login with correct credentials', style: TextStyle(fontSize: 16.0,color: Colors.black),),
                                 actions: [
                                   TextButton(onPressed: (){
                                     Navigator.pop(context);
                                   },
                                       style:ButtonStyle(
                                         shape:WidgetStateProperty.all(
                                           RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(20.0),
                                           ),
                                         ),alignment: Alignment.bottomRight,
                                         backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                                       ),child: const Padding(
                                         padding: EdgeInsets.only(left:20.0,right:20.0),
                                         child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                                       )),
                                 ],
                               );
                             });
                           }
                          }

                        },
                            style: ButtonStyle(
                                fixedSize: WidgetStateProperty.all(const Size(350.0,30.0)),
                                backgroundColor: WidgetStateProperty.all(const Color(0xFFe71f2a))
                            ), child:isLoginLoading? const Text('Verifying...',style: TextStyle(color:Colors.white
                            ),): const Text('Login',style: TextStyle(color:Colors.white
                            ),)),

                        const Expanded(flex:1,child: SizedBox(
                          child:Center(
                            child:Text('"Listen. Learn. Lead.”',
                            textAlign: TextAlign.center,)
                          )
                        ),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child:Text('App Version : ${Constants.appVersion}',
                                textAlign: TextAlign.center,)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: GestureDetector(
                            onTap: (){
                              showModalBottomSheet(context: context,
                                  backgroundColor:const Color(0xFF2d4c9c),
                                  builder: (context){
                                    return BottomSheet(onClosing: (){}, backgroundColor: const Color(0xFF2d4c9c),builder: (context){
                                      return Container(
                                        height: 200,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color:Color(0xFF2d4c9c),
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(80),topRight: Radius.circular(80)),

                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.center,

                                            children: [
                                              const Text(' FOR SUPPORT',style: TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Colors.white),),
                                              GestureDetector(
                                                onTap: (){
                                                  CallUtils.makePhoneCall();
                                                },
                                                child: Row( mainAxisAlignment: MainAxisAlignment.center,

                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(4), // Adjust padding as needed
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white, // Border color
                                                          width: 2, // Border width
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.phone,
                                                        color: Colors.white, // Icon color
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10,),
                                                    const Text('Call',style: TextStyle(color:Colors.white),),
                                                  ],
                                                ),
                                              ),
                                              Center(
                                                child: TextButton(onPressed: (){
                                                  CallUtils().sendWhatsAppMessage('Hello',AppConfig.appName,'9840962424');
                                                }, child: const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image(image: AssetImage('images/whatsapp.png'),height: 30,width:30,),
                                                    SizedBox(width: 10,),
                                                    Text('Whatsapp',style: TextStyle(color:Colors.white),)
                                                  ],
                                                )),
                                              ),

                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  });
                            },
                            child: Container(

                                height: 50,width:300,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color:Color(0xFF2d4c9c),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60),topRight: Radius.circular(60)),
                                ),
                                child:const Center(child: Text(' Support ',style: TextStyle(fontWeight:FontWeight.w600,color: Colors.white),))
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ]
            ),
          ),
        )
    );
  }
 }
