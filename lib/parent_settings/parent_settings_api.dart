import 'dart:convert';

import 'package:http/http.dart' as http;
import 'parent_app_model.dart';
import '../constants.dart';

class ParentSettingApi{
  var url = Constants.url;

  // Future<RoleSettingModel> getRoleid(String id,String centerCode) async {
  //   var getaurl = "$url/getroleid.php";print("id:$id");
  //   final response = await http.post(Uri.parse(getaurl), body: {"center_code":centerCode,
  //     "role_id":id});
  //
  //   if (response.statusCode == 200) {
  //     print("Response:${response.body}");
  //     // Assuming the response body is a JSON object that matches the StudentWhole class
  //     return RoleSettingModel.fromJson(jsonDecode(response.body));
  //   } else {
  //
  //     throw Exception('Failed to load student data');
  //   }
  // }


  Future<ParentSettingsModel> getParentSettings(String centerCode) async {
    var getaurl = "$url/get_parent_settings.php";

    final response = await http.post(Uri.parse(getaurl), body: {"center_code":centerCode});

    print("Role Setting response : ${response.body}");
    if (response.statusCode == 200) {

      // Check if the response body is a String

      // Assuming the response body is a JSON object that matches the RoleSettingModel class
      var jsonResponse = jsonDecode(response.body);

      // Optionally, check if the jsonResponse is a Map
      if (jsonResponse is Map<String, dynamic>) {
        return ParentSettingsModel.fromJson(jsonResponse);
      } else {
        return ParentSettingsModel(
            schoolCode: '',
            notification: 'View',
            notificationPriority: 0,
            marks: 'View',
            marksPriority: 0,  myAchievements: 'View',myAchievementsPriority: 0,
            attendance: 'View', attendancePriority: 0,
            transport: 'View', transportPriority: 0,
            classTest: 'View', classTestPriority: 0,
            feesPayment: 'View',payButtonShow: 'View',
            feesPaymentPriority: 0, homework: 'View',
            homeworkPriority: 0, createdBy: '', updatedBy: ''
        );
      }

    } else {
      return ParentSettingsModel(
          schoolCode: '',
          notification: 'View',
          notificationPriority: 0,
          marks: 'View',
          marksPriority: 0,
          myAchievements: 'View',myAchievementsPriority: 0,
          attendance: 'View', attendancePriority: 0,
          transport: 'View', transportPriority: 0,
          classTest: 'View', classTestPriority: 0,
          feesPayment: 'View',payButtonShow: 'View',
          feesPaymentPriority: 0, homework: 'View',
          homeworkPriority: 0, createdBy: '', updatedBy: ''
      );
    }
  }




  Future<String> insertParentSetting(ParentSettingsModel rolesetting) async {
    var inserturl = "$url/insert_parent_settings.php";
    print("Role Seetting: ${rolesetting.toJson()}");
    // var inserturl = "http://192.168.1.7/smart_school/insert_parent_settings.php";
    final response = await http.post(Uri.parse(inserturl), body:rolesetting.toJson());

    print("Response Add Role ${response.statusCode}Setting: ${response.body}");
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


}