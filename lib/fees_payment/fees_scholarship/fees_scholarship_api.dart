import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants.dart';
import 'fees_scholarship_model.dart';

class StudentScholarshipApi {

  var url = Constants.url;


  Future<String> addScholarshipType(StudentScholarship subject) async {
    var insertUrl = "$url/insert_student_scholarship.php";

    // 1. Prepare the Map body
    final Map<String, String> formData = {
      'school_code': subject.schoolCode,
      'student_id':subject.studentId,
      'fee_type':subject.feeType!, 'discount_type':subject.discountType,
      'discount_value':subject.discountValue.toString(),
      'remarks' : subject.remarks ?? '',
      'scholarship_type':subject.scholarshipType ?? '',
      'created_by': subject.createdBy ?? '',
    };


    // ⭐️ DEBUG PRINT 1: Check the final URL and the payload being sent

    try {
      final response = await http.post(
        Uri.parse(insertUrl),
        body: formData,
      );

      // ⭐️ DEBUG PRINT 2: Check the response status code immediately

      if (response.statusCode == 200) {
        // ⭐️ DEBUG PRINT 3: Check the raw response body from the server

        final result = json.decode(response.body);

        // ⭐️ DEBUG PRINT 4: Check the decoded JSON object

        if (result is Map && result['status'] == "success") {
          return "success";
        } else if (result is Map && result['status'] == "duplicate") {
          return "duplicate";
        } else if (result is Map && result['status'] == "error") {
          return "error: ${result['message'] ?? 'Unknown DB error'}";
        } else {
          return "Error: Unexpected response";
        }
      } else {
        return "Error: HTTP request failed with status: ${response.statusCode}";
      }
    } catch (e) {
      // ⭐️ DEBUG PRINT 5: Catch any exception (like network error, timeout, or JSON decode issue)
      return "error";
    }
  }

  Future<String> editScholarshipType(StudentScholarship subject) async {
    var insertUrl = "$url/update_student_scholarship.php";

    // 1. Prepare the Map body
    final Map<String, String> formData = {
      'id': subject.id.toString(),
      'school_code': subject.schoolCode,
      'student_id': subject.studentId,
      'fee_type': subject.feeType!,
      'discount_type': subject.discountType,
      'discount_value': subject.discountValue.toString(),
      'remarks': subject.remarks ?? '',
      'scholarship_type': subject.scholarshipType ?? '',
      'created_by': subject.createdBy ?? '',
      'isActive': subject.isActive == true ? '1' : '0',
    };

    // ⭐️ DEBUG PRINT 1: Final Url + Payload

    try {
      final response = await http.post(
        Uri.parse(insertUrl),
        body: formData,
      );

      // ⭐️ DEBUG PRINT 2: Response status

      // ⭐️ DEBUG PRINT 3: Raw body from server

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        // ⭐️ DEBUG PRINT 4: Decoded JSON

        if (result is Map && result['status'] == "success") {
          return "success";
        } else if (result is Map && result['status'] == "duplicate") {
          return "duplicate";
        } else if (result is Map && result['status'] == "error") {
          return "error: ${result['message'] ?? 'Unknown DB error'}";
        } else {
          return "Error: Unexpected response";
        }
      } else {
        return "Error: HTTP request failed with status: ${response.statusCode}";
      }
    } catch (e) {
      // ⭐️ DEBUG PRINT 5: Exception
      return "error";
    }
  }



  Future<List<StudentScholarship>> getScholarshipTypeData(String schoolCode) async {
    // Assuming 'url' is defined in the scope.
    var getpayurl = "$url/get_student_scholarship.php";

    // Define the request body
    final Map<String, String> formData = {"school_code": schoolCode};

    // ⭐️ DEBUG PRINT 1: Check the URL and the payload being sent

    try { // Re-enabling the try-catch block for robustness
      final response = await http.post(
        Uri.parse(getpayurl),
        body: formData,
      );


      // ⭐️ DEBUG PRINT 2: Check the response status code

      if (response.statusCode == 200) {
        // ⭐️ DEBUG PRINT 3: Check the raw response body

        var dataJson = json.decode(response.body);

        // ⭐️ DEBUG PRINT 4: Check the type of the decoded object (it should be List)

        List<StudentScholarship> datalist = [];

        // Check if the decoded data is actually a List before proceeding
        if (dataJson is List) {
          try {
            // Iterate through the list of JSON objects
            for (var datasjson in dataJson) {
              // DEBUG PRINT 5 (Optional - only use for deep debugging, can be verbose)
              // print('DEBUG 5 - Processing JSON Object: $datasjson');

              datalist.add(StudentScholarship.fromJson(datasjson));
            }

            // ⭐️ DEBUG PRINT 6: Show the final count of successfully parsed models

            // **CRITICAL CHECK FOR 'NO DATA'**
            if (datalist.isEmpty) {
            }

          } catch (e, stacktrace) {
            // If a single item fails to parse, the whole list might be cleared
            datalist.clear();
            // ⭐️ DEBUG PRINT 7: Catch and report parsing errors (e.g., incorrect data type in JSON)
          }
        } else {
          // Handle cases where the server returns a single object or an error map instead of a List
        }

        return datalist;
      } else {
        // Return empty list if network status code is not 200
        return <StudentScholarship>[];
      }
    } catch (e, stacktrace) {
      // ⭐️ DEBUG PRINT 8: Catch network errors, timeout errors, or initial JSON decoding failures
      return <StudentScholarship>[];
    }
  }


}