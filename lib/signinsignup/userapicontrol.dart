import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRecord{
  var url = Constants.url;
  Future dbConnect() async{
    var dbUrl = "$url/db.php";
    var response = await http.post(Uri.parse(dbUrl));
    var data = json.decode(response.body);
    if(data == "connected"){
   return "Server Connected";
    }else{
    return "Server not Connected";
    }
  }

 Future login(Signin signin)async{
   var loginUrl = "$url/signincenter.php";
   var response = await http.post(Uri.parse(loginUrl),body:signin.toJsonSignin());
   var data = json.decode(response.body);
    if(data == "success" ) {
     Fluttertoast.showToast(backgroundColor:const Color(0xFFefefef),textColor:Colors.black,msg:"Login Success");
     return "success";
      }
   else{
     Fluttertoast.showToast(backgroundColor:const Color(0xFFefefef),textColor:Colors.black,msg: "Incorrect email and password");
   }

 }


  Future<Userdatas> getcenterData(String center_code) async {
    var orderUrl = "$url/getcenterwithcode.php";
    final response = await http.post(Uri.parse(orderUrl), body: {
      "center_code": center_code});

    if (response.statusCode == 200) {
      var center = json.decode(response.body);


      if (center is List && center.isNotEmpty) {
        // Assuming you want the first item in the list
        return Userdatas.fromJson(center[0]);
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load student data');
    }
  }


  Future getmobileDataValue(String contactNumber) async {
    var orderUrl = "$url/getcenterwithmobile.php";
    final response = await http.post(Uri.parse(orderUrl), body: {"contactNumber": contactNumber});

    if (response.statusCode == 200) {
      var center = json.decode(response.body);


        return response.body;

    } else {
      throw Exception('Failed to load student data');
    }
  }




  Future<Map<String, dynamic>> getmobileData(String contactNumber) async {
    var orderUrl = "$url/getcenterwithmobiledata.php";
    final response = await http.post(Uri.parse(orderUrl), body: {"contactNumber": contactNumber});

    if (response.statusCode == 200) {
      // Decode the response body as a list
      List<dynamic> userdataList = json.decode(response.body);

      // Check if the list is not empty
      if (userdataList.isNotEmpty) {
        // Get the first item from the list
        var userdata = userdataList[0];

        // Print the response body for debugging

        // Save user data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', userdata['emailId'] ?? '');
        prefs.setString('username', userdata['username'] ?? '');
        prefs.setString('upi_id', userdata['upi_id'] ?? '');
        prefs.setString('centerName', userdata['centerName'] ?? '');
        prefs.setString('center_code', userdata['center_code'] ?? '');
        prefs.setString('password', userdata['userpassword'] ?? '');
        prefs.setString('id', userdata['id'].toString());
        prefs.setString('userData', json.encode(userdata));


        return userdata;
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load student data');
    }
  }




//   Future centerData(Signin signin)async{
//   var geturl = "$url/getdata.php";
//   final response = await http.post(Uri.parse(geturl),body:signin.toJsonSignin());
//   if(response.statusCode==200){
//     var userdata = json.decode(response.body);
//     var centerCode = userdata['centerCode'];
//     return centerCode;
//   }else{
//     return "null";
//   }
// }
//
//  Future signin(Signin signin)async{
//    var geturl = "$url/signinforcenter.php";
//
//     final response = await http.post(Uri.parse(geturl),body:signin.toJsonSignin());
//     if(response.statusCode==200){
//       var userdata = json.decode(response.body);
//       if (userdata['emailId'] == null){
//         // Return an error message if any of the required fields are missing
//         return "Incomplete user data received from server";
//       }
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('email',userdata['emailId']);
//       prefs.setString('role','admin');
//       prefs.setString('username',userdata['username']);
//       prefs.setString('upi_id', userdata['upi_id']);
//       prefs.setString('centerName', userdata['schoolName']);
//       prefs.setString('center_code', userdata['school_code']);
//       prefs.setString('password', userdata['userpassword']);
//       prefs.setString('id',userdata['id'].toString());
//       prefs.setString('userData', json.encode(userdata));
//       var username = userdata['username'];
//       return "success";
//     }else{
//       return "null";
//     }
//   }
//
// Future<String> adduser(User user) async {
//   var inserturl = "$url/insertcenter.php";
//   final response = await http.post(Uri.parse(inserturl), body: user.toJsonAdd());
//   if (response.statusCode == 200) {
//     print("RESPONSE REGISTER: ${response.statusCode} ${response.body}");
//     final result = json.decode(response.body); // Parse the JSON response
//     if (result == "success") {
//       return "success";
//     } else if (result == "CodeExist") {
//       return "Code";
//     } else if (result == "EmailExist") {
//       return "Email";
//     } else if(result == "entryExist"){
//       return "entryExist";
//     }else{
//       return "Error: Unexpected response";
//     }
//   } else {
//     return "Error: HTTP request failed";
//   }
// }
//
//  Future deleteUser(Signin user)async{
//     var deleteurl = "$url/delete.php";
//     final response = await http.delete(Uri.parse(deleteurl),body: user.toJsonSignin());
//     if(response.statusCode == 200){
//       return response.body;
//     }else{
//       return "Error";
//     }
//  }

// Future shared()async{
//
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var centerName = prefs.getString('centerName');
//    return centerName;
// }




//
// Future <String> updateProfile(String emailId,String center_code, String centerName,String centerAddress,
//     String username,String contactNumber,String upi_id)async{
//
//     var updateurl = "$url/updateprofile.php";
//   final response = await http.post(Uri.parse(updateurl),body:{
//     "center_code" : center_code,
//     "centerName": centerName,
//     "centerAddress": centerAddress,
//     "emailId":emailId,
//     "username" : username,
//     "contactNumber": contactNumber,
//     "upi_id":upi_id
//   });
//   var userdata = jsonDecode(response.body);
//   if(response.statusCode==200){
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('email',userdata['emailId']);
//     prefs.setString('username',userdata['username']);
//     prefs.setString('upi_id', upi_id);
//     prefs.setString('centerName', userdata['centerName']);
//     prefs.setString('center_code', userdata['center_code']);
//     prefs.setString('password', userdata['userpassword']);
//     prefs.setString('id',userdata['id'].toString());
//     prefs.setString('userData', json.encode(userdata));
//     Fluttertoast.showToast(backgroundColor:const Color(0xFFefefef),textColor:Colors.black,msg:"Profie Updated");
//     return "success";
//   }else{
//     return "Error";
//   }
// }
//
//  Future <String> updatePass(String emailId, String userpassword,String newpassword)async{
//     var updateurl = "$url/updatepasscenter.php";
//
//     final response = await http.post(Uri.parse(updateurl),body:{
//       "emailId" : emailId,
//       "userpassword": userpassword,
//       "newpassword": newpassword,
//     });
//     var Status = jsonDecode(response.body);
//     if(Status == "success"){
//       return "success";
//     }else{
//       return "Error";
//     }
//  }

Future <String> forgotPass(String emailId, String userpassword)async{
  var forgoturl = "$url/forgotpasscenter.php";
  final response = await http.post(Uri.parse(forgoturl),body:{
    "emailId" : emailId,
    "userpassword": userpassword,
  });
  var status = jsonDecode(response.body);
  if(status == "success"){

    return "success";
  }else{
    return "Error";
  }
}

}
