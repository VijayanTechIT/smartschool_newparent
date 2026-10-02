import 'dart:convert';

import '../constants.dart';
import '../helper/attendancemodel.dart';
import 'package:http/http.dart' as http;


class AttendanceRecord{

  var url = Constants.url;


  Future<String> insertAttendance(List<AttendanceWhole> attendance) async {
    var insertpayurl = "${Constants.url}/attendanceupdateinsertnew.php";
    List<Map<String, dynamic>> jsonList = attendance.map((attend) => attend.toJsonAdd()).toList();
    String jsonString = json.encode(jsonList);

    final response = await http.post(
      Uri.parse(insertpayurl),    body: jsonString,
    );
    if (response.statusCode == 200) {
      return "success";
    } else {
      return "Error adding data";
    }
  }


  Future<List<AttendanceWhole>>attendancedateRange(String center_code,String sdate,String edate)async{
    var getpayurl = "$url/getattendancedaterange.php";
    final response = await http.post(Uri.parse(getpayurl),body:{
      "center_code":center_code,"sdate":edate,"edate":sdate
    });
    if(response.statusCode==200){
      var dataJson = json.decode(response.body);
      List<AttendanceWhole> datalist = [];
      try{
        for(var datasjson in dataJson){
          datalist.add(AttendanceWhole.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;
    }else{
      return <AttendanceWhole>[];
    }
  }

  Future<List<AttendanceWhole>> attendancebycourse(String center_code, String date,String edate, String course) async {

    var getpayurl = "$url/getattendancedaterange.php";
    final response = await http.post(Uri.parse(getpayurl), body: {
      "center_code": center_code,
      "course": course,
      "sdate":edate,"edate":date
    });

    if (response.statusCode == 200) {
      var dataJson = json.decode(response.body);
      List<AttendanceWhole> datalist = [];

      try {
        for (var data in dataJson) {
          var attendance = AttendanceWhole.fromJson(data);
          // Assu ming AttendanceWhole has a 'courseIds' or similar property which is a List<String> or List<int>
          if (attendance.course!.contains(course)) {
            datalist.add(attendance);
          }
        }
      } catch (e) {
        datalist.clear();
      }
      return datalist;
    } else {
      return <AttendanceWhole>[];
    }
  }


  Future<List<AttendanceWhole>> attendancebystudent(String student_id,String center_code,
      String date,String edate) async {

    var getpayurl = "$url/getstudentAttendancebyId.php";
    final response = await http.post(Uri.parse(getpayurl), body: {
      "school_code": center_code,
      "student_id":student_id,
      "sdate":edate,"edate":date
    });
    if (response.statusCode == 200) {

      var dataJson = json.decode(response.body);
      List<AttendanceWhole> datalist = [];


      try {
        for (var data in dataJson) {
          var attendance = AttendanceWhole.fromJson(data);
          // Assu ming AttendanceWhole has a 'courseIds' or similar property which is a List<String> or List<int>

            datalist.add(attendance);

        }
      } catch (e) {
        datalist.clear();
      }
      return datalist;
    } else {
      return <AttendanceWhole>[];
    }
  }




  Future<List<AttendanceWhole>> getAllAttendance(String centerCode,String date) async {
    var inserturl = "$url/getattendance.php";
    final response = await http.post(Uri.parse(inserturl), body:{
      "centerCode": centerCode,
      "date":date,
    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      // Parse the JSON response
      List<AttendanceWhole> datalist = [];
      try{
        for(var datasjson in result){
          datalist.add(AttendanceWhole.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;
    } else {
      return <AttendanceWhole>[];
    }
  }



}