import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/academic_year_model.dart';

class AcademicApi{

  var url = Constants.url;

  Future<String> addAcademicYear(AcademicYearModel subject) async {
    var inserturl = "$url/insert_academic_year.php";

    final response = await http.post(Uri.parse(inserturl), body:subject.toJson());
    print(":Resposne: ${response.statusCode}  ${response.body}");

    if (response.statusCode == 200) {
      final result = json.decode(response.body); // Parse the JSON response
      if (result is Map && result['status'] == "success") {
        return "success";
      } else if (result is Map && result['status'] == "duplicate") {
        return "duplicate";
      } else if (result is Map && result['status'] == "error") {
        return "error: ${result['message'] ?? 'Unknown DB error'}";
      }else{
        return "Error: Unexpected response";
      }
    } else {
      return "Error: HTTP request failed";
    }
  }

  Future<String> editAcademicYear(AcademicYearModel subject) async {
    var inserturl = "$url/update_academic_year.php";

    final response = await http.post(Uri.parse(inserturl), body:subject.toJsonUpdate());
    print("Response Body:${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      final result = json.decode(response.body); // Parse the JSON response
      if (result == "success") {
        return "success";
      }else{
        return "Error: Unexpected response";
      }
    } else {
      return "Error: HTTP request failed";
    }
  }


  Future<List<AcademicYearModel>> getAcademicYearData(String schoolCode)async{
    var getpayurl = "$url/getAcademicYear.php";
    final response = await http.post(Uri.parse(getpayurl),body: {"school_code":schoolCode});
    if(response.statusCode==200){
      var dataJson = json.decode(response.body);
      List<AcademicYearModel> datalist = [];
      try{
        for(var datasjson in dataJson){
          datalist.add(AcademicYearModel.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;
    }else{
      return <AcademicYearModel>[];
    }
  }

}