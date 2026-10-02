import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../constants.dart';
import 'fees_term_model.dart';

class FeesTermApi{

  var url = Constants.url;



  Future<String> addFeesTerm(TermModel term) async {
    var insertUrl = "$url/insert_term.php";
    final _dateFormat = DateFormat('yyyy-MM-dd');
    String formatDate(String? dateStr, String fieldName) {
      print('📅 [DEBUG] Raw $fieldName value: $dateStr');
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        print('⚠️ [$fieldName] Invalid or empty date, defaulting to 0000-00-00');
        return "0000-00-00";
      }
      try {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed == null) {
          print('❌ [$fieldName] Failed to parse date: $dateStr');
          return "0000-00-00";
        }
        final formatted = DateFormat('yyyy-MM-dd').format(parsed);
        print('✅ [$fieldName] Formatted date: $formatted');
        return formatted;
      } catch (e) {
        print('🚨 [$fieldName] Exception while formatting: $e');
        return "0000-00-00";
      }
    }

    final formattedStart = formatDate(term.startDate, 'start_date');
    final formattedEnd = formatDate(term.endDate, 'end_date');

    final Map<String, String> formData = {
      'school_code': term.schoolCode,
      'term_name': term.termName,
      'priority': term.priority.toString(),
      if (term.academicYearId != null)
        'academic_year_id': term.academicYearId.toString(),
      'start_date': formattedStart,
      'end_date': formattedEnd,
      'created_by': term.createdBy ?? '',
    };

    print('📦 Final formData being sent to backend: $formData');

    try {
      final response = await http.post(
        Uri.parse(insertUrl),
        // 🚨 CRITICAL CHANGE: Send the Map<String, String> directly.
        // The http package will automatically encode this as application/x-www-form-urlencoded
        // and populate PHP's $_POST superglobal.
        body: formData,
      );

     print("Save Trm Response: ${response.statusCode} - ${response.body}");
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

  Future<String> editFeesTerm(TermModel subject) async {
    print("Edit Term id:  ${subject.termId}");
    var inserturl = "$url/update_term.php";


    final response = await http.post(Uri.parse(inserturl),
        body:subject.toJsonUpdate());

  print("UPdate Term response:${response.statusCode} ${response.body}");

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


  Future<void> updateFeesTermPriorities(List<TermModel> feeTerms) async {
    final vurl = Uri.parse("$url/update_term_priority.php");

    final feesTermsList = feeTerms.map((feeTerms) => {
      "term_id": feeTerms.termId,
      "priority": feeTerms.priority,
    }).toList();

    final response = await http.post(
      vurl,
      headers: {
        "Content-Term": "application/json",
      },
      body: json.encode({"terms": feesTermsList}),
    );

    json.decode(response.body);

    print("Save Term Priority: ${response.body}");
  }

  Future<List<TermModel>> getFeesTermData(String schoolCode)async{
    var getpayurl = "$url/get_term.php";
    final response = await http.post(Uri.parse(getpayurl),body:
    {"school_code":schoolCode});
    print("Get Term Response: ${response.statusCode} - ${response.body}");

    if(response.statusCode==200){
      var dataJson = json.decode(response.body);
      List<TermModel> datalist = [];
      try{
        for(var datasjson in dataJson){
          datalist.add(TermModel.fromJson(datasjson));
        }


      }catch(e){
        datalist.clear();
      }
      return datalist;
    }else{
      return <TermModel>[];
    }
  }

}