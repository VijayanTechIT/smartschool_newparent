import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants.dart';
import 'fees_invoice_model.dart';
import 'fees_payment_model.dart';

class FeeRepository{

  final String baseUrl = Constants.url; // 🔁 change this



  Future<List<FeesInvoiceModel>> getFeesInvoiceData(
      String schoolCode,
      String studentId,
      ) async {
    var url = "$baseUrl/get_invoice_payment_student.php";
    final Uri uri = Uri.parse(url);

    final body = {
      'school_code': schoolCode,
      'student_id': studentId,
    };

    // ⭐️ DEBUG PRINT 1: URL & request body
    debugPrint("123 ▶️ API URL: $uri");
    debugPrint("123 ▶️ Request Body: $body");

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      // ⭐️ DEBUG PRINT 2: Status code
      debugPrint("123 ▶️ Response Status Code: ${response.statusCode}");

      // ⭐️ DEBUG PRINT 3: Raw response (trimmed for safety)
      debugPrint(
        "123 ▶️ Raw Response: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}",
      );

      // If request fails
      if (response.statusCode != 200) {
        debugPrint("123 ❌ Non-200 response received");
        return <FeesInvoiceModel>[];
      }

      // 🔹 Decode response
      var dataJson = json.decode(response.body);

      // ⭐️ DEBUG PRINT 4: Decoded JSON type
      debugPrint("123 ▶️ Decoded JSON Type: ${dataJson.runtimeType}");

      List<FeesInvoiceModel> datalist = [];

      // 🔹 Validate list response
      if (dataJson is List) {
        debugPrint("123 ▶️ JSON is a List with length: ${dataJson.length}");
        try {
          for (var datasjson in dataJson) {
            datalist.add(FeesInvoiceModel.fromJson(datasjson));
          }

          // ⭐️ DEBUG PRINT 5: Parsed model count
          debugPrint("123 ✅ Parsed Invoice Count: ${datalist.length}");

          if (datalist.isEmpty) {
            debugPrint("123 ⚠️ Parsed list is empty");
          }
        } catch (e, stacktrace) {
          debugPrint("123 ❌ Parsing error: $e");
          debugPrint("123 ❌ Stacktrace: $stacktrace");
          datalist.clear();
        }
      } else {
        // 🔹 Unexpected response format
        debugPrint("123 ❌ Unexpected JSON format. Expected List.");
      }

      return datalist;
    } catch (e, stacktrace) {
      // 🔹 Handle network or decoding errors
      debugPrint("123 ❌ Exception occurred: $e");
      debugPrint("123 ❌ Stacktrace: $stacktrace");
      return <FeesInvoiceModel>[];
    }
  }


  Future<Map<String, dynamic>> makePayment({
    required String schoolCode,
    required int invoiceId,
    required double amountPaid,
    required String modeOfPayment,
    required String createdBy,
    String? referenceNo,
    String? remarks,
    DateTime? paymentDate,
    required FeesInvoiceModel feesInvoice,
  }) async
  {
    final uri = Uri.parse('$baseUrl/insert_fees_payment_student.php');
    // final uri = Uri.parse('http://192.168.1.7/smart_school/insert_fees_payment.php');
    final formattedDate = DateFormat('yyyy-MM-dd')
        .format(paymentDate ?? DateTime.now());
    // --- Build body ---
    final body = {
      'school_code': schoolCode,
      'invoice_id': invoiceId.toString(),
      'amount_paid': amountPaid.toStringAsFixed(2),
      'mode_of_payment': modeOfPayment,
      'created_by': createdBy,
      'reference_no': referenceNo ?? '',
      'remarks': remarks ?? '',
      'payment_date':formattedDate,

      // ✅ Attach full invoice data as JSON string
      'invoice_data': jsonEncode(feesInvoice.toJson()),
    };



    try {
      final response = await http.post(uri,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: body);


      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          return jsonData;
        } else {
          throw Exception(jsonData['message'] ?? 'Unknown error from server');
        }
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }


  Future<List<FeesPayment>> getFeesPaymentData(
      String schoolCode,
      String studentId,
      ) async {
    var url = "$baseUrl/get_invoice_payment_student.php";
    final Uri uri = Uri.parse(url);

    final body = {
      'school_code': schoolCode,
      'student_id': studentId,
    };

    // 🔹 Request log

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      // 🔹 Response log

      if (response.statusCode != 200) {
        return [];
      }

      var jsonData = json.decode(response.body);


      List<FeesPayment> list = [];

      if (jsonData is List) {
        try {
          for (var item in jsonData) {
            list.add(FeesPayment.fromJson(item));
          }
        } catch (e) {
        }
      } else {
      }

      return list;
    } catch (e) {
      return [];
    }
  }


}
