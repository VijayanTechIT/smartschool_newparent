import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import 'package:smart_school_parent/models/marks_model_class.dart';
class MarksApi{

  var url = Constants.url;

  Future<List<MarksModelClass>> getMarks(String center_code,String studentId) async {
    var getpayurl = "$url/getMarksByStudentId.php";
    final response = await http.post(Uri.parse(getpayurl), body: {
      "school_code": center_code,
      "student_id": studentId,
    },
    );
    if (response.statusCode == 200) {
      var dataJson = json.decode(response.body);
      List<MarksModelClass> datalist = [];
      try {
        for (var datasjson in dataJson) {
          datalist.add(MarksModelClass.fromJson(datasjson));
        }
      } catch (e) {
        datalist.clear();
      }
      return datalist;
    } else {
      return <MarksModelClass>[];
    }
  }

  Future<List<MarksModelClass>> getStudentMarks(String examId,String center_code,String studentId) async {
    var getpayurl = "$url/get_student_marks.php";
    final response = await http.post(Uri.parse(getpayurl), body: {
      "school_code": center_code,
      "student_id": studentId,
      "exam_id":examId
    },
    );
    if (response.statusCode == 200) {
      var dataJson = json.decode(response.body);
      List<MarksModelClass> datalist = [];
      try {
        for (var datasjson in dataJson) {
          datalist.add(MarksModelClass.fromJson(datasjson));
        }
      } catch (e) {
        datalist.clear();
      }
      return datalist;
    } else {
      return <MarksModelClass>[];
    }
  }
}

