import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_school_parent/constants.dart';

import '../models/exams_model_class.dart';

class ExamsApi{
  var url = Constants.url;
  Future<List<ExamsModelClass>> getExamsData(String schoolCode)async{
    var getpayurl = "$url/getExams.php";
    final response = await http.post(Uri.parse(getpayurl),body: {"school_code":schoolCode});
    if(response.statusCode==200){
      var dataJson = json.decode(response.body);
      List<ExamsModelClass> datalist = [];
      try{
        for(var datasjson in dataJson){
          datalist.add(ExamsModelClass.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;
    }else{
      return <ExamsModelClass>[];
    }
  }
}