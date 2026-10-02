import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../helper/sibling_api_loca.dart';
import '../student/StudentModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class StudentApi{
  var url = Constants.url;

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
           return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }


  Future<String> insertStudentDoc(String category,String student_id, String center_code, String file_description, File? photo) async {
     var vurl = Constants.url;

    var updateUrl = "$vurl/insertDocument.php";

    // Create a MultipartRequest
    var request = http.MultipartRequest('POST', Uri.parse(updateUrl));

    // Add fields to the request
    request.fields['student_id'] = student_id;
    request.fields['category'] = category;
    request.fields['school_code'] = center_code;
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
    var responseString = await http.Response.fromStream(response);

    // Check the response
    if (response.statusCode == 200) {
      // Read the response body

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

  Future deletePhoto(String id)async{
    var deleteurl = "$url/deletePhotoStudent.php";
    final response = await http.post(Uri.parse(deleteurl), body: {
      "id": id,
    });
    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      return "Error";
    }
  }

  Future<StudentWhole?> signinstudent(String dob, String StudentId, String schoolCode) async {
    // First: extract the prefix before "ST"
    String prefix = '';
    if (StudentId.contains("ST")) {
      prefix = StudentId.split("ST").first.trim();
    }


    if (prefix != schoolCode) {
      return null;
    }

    var geturl = "$url/studentSignIn.php";

    final response = await http.post(
      Uri.parse(geturl),
      body: {
        "student_id": StudentId,
        "dob": dob,
        "school_code": schoolCode
      },
    );
    print("Response Data: ${response.statusCode}parsed data ${response.body}");

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);


      if (jsonData is Map && jsonData.containsKey("message")) {
        if (jsonData["message"].toString().toLowerCase() == "no records found") {
          return null;
        }
      } else {
        // try {
        print("Response Data: $jsonData");
          StudentWhole userdata = StudentWhole.fromJson(jsonData);

          return userdata;
        // } catch (e) {
        //   return null;
        // }
      }
    } else {
      return null;
    }
  }

  Future<String> addSiblingStudent(String relationship, String dob,
      String studentId) async {
    final String getUrl = "$url/addSibling.php";


      // Convert studentId to lowercase for case-insensitive check
      String lowerCaseStudentId = studentId.toLowerCase();

      // Check if the student ID already exists in the local database
      List<Map<String, dynamic>> existingSiblings = await
      DatabaseHelper().getSiblings();

      bool studentExists = existingSiblings.any(
            (sibling) => (sibling['studentId'] as String).
            toLowerCase() == lowerCaseStudentId,
      );
      if (studentExists) {
        FirebaseMessaging.instance.subscribeToTopic(studentId);
        return "exists";
      }

      // If not found, proceed with API request
      final response = await http.post(
        Uri.parse(getUrl),
        body: {
          "student_id": studentId,
          "dob": dob,
        },
      );


      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey("status")) {
          if (jsonData["status"] == "active") {

            await DatabaseHelper().addSibling(
              jsonData['name'],
              studentId,
              relationship,
              dob,
            );
            FirebaseMessaging.instance.subscribeToTopic(studentId);


            return "success";
          } else {
            return "[${jsonData["name"]}] is inactive";
          }
        } else if (jsonData == "Incorrect dob") {
          return "mismatch";
        } else if (jsonData == "Student ID not found") {
          return "not found";
        } else if (jsonData == "Fields missing") {
          return "missing fields";
        } else {
          return "failed";
        }
      } else {
        return "failed";
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