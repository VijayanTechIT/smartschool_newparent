import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../student/StudentModel.dart';

class StudentRecord{
  var url = Constants.url;



  Future<Map<String, dynamic>> uploadPhoto(String studentId, File photo) async {
    var inserturl = "${Constants.url}/update_photo_student.php";

    var request = http.MultipartRequest('POST', Uri.parse(inserturl));
    request.fields['student_id'] = studentId;
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    var photoResponse = await request.send();
    var responseBody = await utf8.decodeStream(photoResponse.stream);

    if (photoResponse.statusCode == 200) {
      final result = json.decode(responseBody);
      if (result['status'] == "success") {
        return result;
      } else {
        return {'status': 'error', 'message': result['message'] ?? 'Unexpected response'};
      }
    } else {
      return {'status': 'error', 'message': 'Unexpected response from server'};
    }
  }


  Future<List<dynamic>?> getDocumentsByStudentId(String studentId, String centerCode) async {
    // Replace with your server's URL where the PHP file is hosted
    // const String apiUrl = "https://yourserver.com/get_documents.php";

     String apiUrl = "${Constants.url}/getDocument.php";

    try {
      // Make a POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'student_id': studentId,
          'center_code': centerCode,
        },
      );
      // Check the status of the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['documents'] as List<dynamic>;
        } else {
          // Handle error message
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }


  Future<String> insertStudentDoc(String student_id, String center_code, String file_description, File? photo) async {
     var vurl = Constants.url;

    var updateUrl = "$vurl/insertDocument.php";

    // Create a MultipartRequest
    var request = http.MultipartRequest('POST', Uri.parse(updateUrl));

    // Add fields to the request
    request.fields['student_id'] = student_id;
    request.fields['center_code'] = center_code;
    request.fields['file_description'] = file_description;

    // Attach the photo file if it is not null
    if (photo != null) {
      var photoStream = http.ByteStream(Stream.castFrom(photo.openRead()));
      var photoLength = await photo.length();
      request.files.add(
        http.MultipartFile(
          'documents',
          photoStream,
          photoLength,
          filename: photo.path.split('/').last,
        ),
      );
    }

    // Send the request
    var response = await request.send();

    // Check the response
    if (response.statusCode == 200) {
      // Read the response body
      var responseString = await http.Response.fromStream(response);
      var userdata = jsonDecode(responseString.body);
      return "success";
    } else {
      return "Error: ${response.statusCode}";
    }
  }

  Future<String> deleteStudentDoc(String student_id,String file_id)async {
    var vurl = Constants.url;

    var updateUrl = "$vurl/deleteDocument.php";

    // Create a MultipartRequest
    var request = http.MultipartRequest('POST', Uri.parse(updateUrl));

    // Add fields to the request
    request.fields['student_id'] = student_id;
    request.fields['file_id'] = file_id;

    // Send the request
    var response = await request.send();

    // Check the response
    if (response.statusCode == 200) {
      // Read the response body
      var responseString = await http.Response.fromStream(response);
      var userdata = jsonDecode(responseString.body);
      return "success";
    } else {
      return "Error: ${response.statusCode}";
    }
  }
// static const url ="http://192.168.1.10/student";

  Future deleteStudent(String id)async{
    var deleteurl = "$url/deleteStudent.php";
    final response = await http.post(Uri.parse(deleteurl), body: {
      "id": id,
    });
    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      return "Error";
    }
  }

  Future deletePhoto(String studentId)async{
    var deleteurl = "$url/delete_photo.php";
    final response = await http.post(Uri.parse(deleteurl), body: {
      "student_id": studentId,
    });
    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      return "Error";
    }
  }


  Future<StudentWhole?> signinstudent(String dob, String StudentId,String schoolCode) async {
    var geturl = "$url/studentSignIn.php";

    final response = await http.post(
      Uri.parse(geturl),
      body: {
        "student_id": StudentId,
        "dob": dob,
        "school_code":schoolCode
      },
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      try {
        // Parse the JSON into a StudentWhole object
        StudentWhole userdata = StudentWhole.fromJson(jsonData);

        // Save data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('role','student');
        prefs.setString('studentId', userdata.studentId);
        prefs.setString('dob', userdata.dob);
        // prefs.setString('StudentData', userdata);
        prefs.setString('StudentData', json.encode(jsonData));
        prefs.setString('center_code', userdata.schoolCode);

        return userdata; // Return the parsed object
      } catch (e) {
        return null; // Return null if there's an error
      }
    } else {
      return null; // Return null if the response status is not 200
    }
  }




  Future studentIdData(String center_code)async{
    var orderUrl = "$url/studentidcount.php";
    final response = await http.post(Uri.parse(orderUrl),body:{"centerCode":center_code});
    if (response.statusCode == 200) {
      if(response.body != 'null'){
        // Assuming the response body is a JSON object that matches the StudentWhole class
        return StudentWhole.fromJson(jsonDecode(response.body));
      }
      else{
      return null;
    }} else {
      return null;
    }
  }


  Future<StudentWhole> getAStudent(String id) async {
    var getaurl = "$url/getdatawithidstudent.php";
    final response = await http.post(Uri.parse(getaurl), body: {"id": id});

    if (response.statusCode == 200) {
      // Assuming the response body is a JSON object that matches the StudentWhole class
      return StudentWhole.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load student data');
    }
  }



  Future<List<StudentWhole>> getAllStudentbyCourse(String centerCode, String course) async {
    var inserturl = "$url/getallstudent.php";

    final response = await http.post(Uri.parse(inserturl), body: {
      "centerCode": centerCode,

    });


    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      List<StudentWhole> datalist = [];

      try {
        for (var dataJson in result) {
          var student = StudentWhole.fromJson(dataJson);

          // Check if 'course' exists in student.coaching_for list
          if (student.studyingGrade.contains(course)) {
            datalist.add(student);
          }
        }
      } catch (e) {
        datalist.clear();
      }
      return datalist;
    } else {
      return <StudentWhole>[];
    }
  }

  Future<List<StudentWhole>> getAllStudent(String centerCode) async {
    var inserturl = "$url/getallstudent.php";

    final response = await http.post(Uri.parse(inserturl), body:{
      "centerCode": centerCode,

    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      // Parse the JSON response

      List<StudentWhole> datalist = [];

      try{
        for(var datasjson in result){
          datalist.add(StudentWhole.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;

    } else {
      return <StudentWhole>[];
    }
  }


}