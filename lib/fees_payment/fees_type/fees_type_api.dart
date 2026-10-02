import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'fee_type_model.dart';

class FeesTypeApi{

  var url = Constants.url;



  Future<String> addFeesType(FeeCategory subject) async {
    var insertUrl = "$url/insert_fees_type.php";

    // 1. Prepare the Map body (must contain only String values for $_POST to work reliably)
    // Use subject.toFormData() (a new method) or convert the existing Map to a Map<String, String>
    // We'll use the existing toJson, but ensure all values are strings for $_POST
    final Map<String, String> formData = {
      'school_code': subject.schoolCode,
      'category_name': subject.categoryName,
      'description': subject.description ?? '',
      'status': subject.status,
      'created_by': subject.createdBy ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse(insertUrl),

        body: formData,
      );


      // ... (rest of your response handling code - remains correct)
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is Map && result['status'] == "success") {
          return "success";
        } else if (result is Map && result['status'] == "duplicate") {
          return "duplicate";
        } else if (result is Map && result['status'] == "error") {
          // Use the null-aware operator '??' just in case 'message' is null
          return "error: ${result['message'] ?? 'Unknown DB error'}";
        } else {
          return "Error: Unexpected response";
        }
      } else {
        return "Error: HTTP request failed with status: ${response.statusCode}";
      }
    } catch (e) {
      return "error";
    }
  }

  Future<String> editFeesType(FeeCategory subject) async {
    var inserturl = "$url/update_fees_type.php";


    final response = await http.post(Uri.parse(inserturl),
        body:subject.toJsonUpdate());



    if (response.statusCode == 200) {
      final result = json.decode(response.body); // Parse the JSON response
      if (result['status'] == "success") {
        return "success";
      }else if(result['status'] == "duplicate"){
        return "duplicate";
      }else{
        return "Error: Unexpected response";
      }
    } else {
      return "Error: HTTP request failed";
    }
  }


  Future<void> updateFeesTypePriorities(List<FeeCategory> feeTypes) async {
    final vurl = Uri.parse("$url/update_fees_type_priority.php");

    final feesTypesList = feeTypes.map((feeTypes) => {
      "category_id": feeTypes.categoryId,
      "priority": feeTypes.priority,
    }).toList();

    final response = await http.post(
      vurl,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({"feeCategories": feesTypesList}),
    );

    json.decode(response.body);
  }

  Future<List<FeeCategory>> getFeesTypeData(String schoolCode)async{
    var getpayurl = "$url/get_fees_type.php";
    final response = await http.post(Uri.parse(getpayurl),body:
                     {"school_code":schoolCode});

    if(response.statusCode==200){
      var dataJson = json.decode(response.body);
      List<FeeCategory> datalist = [];
      try{
        for(var datasjson in dataJson){
          datalist.add(FeeCategory.fromJson(datasjson));
        }


      }catch(e){
        datalist.clear();
      }
      return datalist;
    }else{
      return <FeeCategory>[];
    }
  }

}