import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../helper/paymentModel.dart';

class PaymentRecord{
  var url = Constants.url;

  Future<String> addPayment(PaymentModel staff) async {
    var inserturl = "$url/insertpayment.php";

    final response = await http.post(Uri.parse(inserturl), body: staff.toJsonAdd());
    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      // Parse the JSON response
      if (result == "success") {
        return "success";
      }else{
        return "Error: Unexpected response";
      }
    } else {
      return "Error: HTTP request failed";
    }
  }

  Future<List<PaymentModelWhole>> getPayments(String centerCode) async {
    var inserturl = "$url/getallpayments.php";

    try {
      final response = await http.post(Uri.parse(inserturl), body: {
        "center_code": centerCode,
      });


      if (response.statusCode == 200) {
        var result = json.decode(response.body) as List;
        List<PaymentModelWhole> datalist = [];

        for (var dataJson in result) {
          try {
            datalist.add(PaymentModelWhole.fromJson(dataJson));
          } catch (e) {
          }
        }

        return datalist;
      } else {
        return <PaymentModelWhole>[];
      }
    } catch (e) {
      return <PaymentModelWhole>[];
    }
  }


  Future<List<PaymentModelWhole>> getPaymentforstudent(String centerCode, String invoice_id) async {
    var inserturl = "$url/getPaymentforstudent.php";

    try {
      final response = await http.post(Uri.parse(inserturl), body: {
        "center_code": centerCode,
        "invoice_id": invoice_id,
      });


      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        // Check if the result is a list
        if (result is List) {
          List<PaymentModelWhole> datalist = [];

          for (var dataJson in result) {
            try {
              datalist.add(PaymentModelWhole.fromJson(dataJson));
            } catch (e) {
            }
          }
          return datalist;
        } else if (result is Map<String, dynamic> && result.containsKey("message")) {
          // Handle the case where the response is an object with a "message" key
          return <PaymentModelWhole>[]; // Return an empty list if no records are found
        } else {
          return <PaymentModelWhole>[];
        }
      } else {
        return <PaymentModelWhole>[];
      }
    } catch (e) {
      return <PaymentModelWhole>[];
    }
  }

}