import 'dart:convert';

import '../constants.dart';
import 'notification_model.dart';
import 'package:http/http.dart' as http;
class NotificationApi{


  var url = Constants.url;


  Future<List<NotificationModel>> getAllNotificationStudent(String centerCode,String student_id) async {
    var inserturl = "$url/get_notification.php";

    final response = await http.post(Uri.parse(inserturl), body:{
      "school_code": centerCode,
      "student_id":student_id

    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      // Parse the JSON response

      List<NotificationModel> datalist = [];

      try{
        for(var datasjson in result){
          datalist.add(NotificationModel.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;

    } else {
      return <NotificationModel>[];
    }
  }



}