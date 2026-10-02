import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import 'fees_invoice_model.dart';
import 'fees_type/fees_pay_screen.dart';

class CashfreeService {
  final String apiUrl = "${Constants.url}/create_cashfree_order.php";
  Future<Map<String, dynamic>> createCashfreeOrder({
    required String schoolCode,
    required double amount,
    required String customerId,
    required String customerName,
    String? customerEmail,   // optional
    String? customerPhone,   // optional
  })
  async {
    // 1. Print the request body being prepared
    final body = {
      "school_code": schoolCode,
      "amount": amount,
      "customer_id": customerId,
      "customer_name": customerName,
      "customer_email": customerEmail ?? "",
      "customer_phone": customerPhone ?? "",
    };
    // 1. Print Request Body

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // 2. Print the response status code
      // 2. Print Status Code

      if (response.statusCode != 200) {
        // 3. Print the full response body on server error
        // 3. Print Full Error Body
        throw Exception("Server error: ${response.statusCode}. Body: ${response.body}");
      }

      final data = jsonDecode(response.body);

      // 4. Print the decoded data if the status code is 200
      // 4. Print Decoded Data

      if (data["status"] == "error") {
        // 5. Print the specific error message from the response data
        // 5. Print API Error Message
        throw Exception(data["message"]);
      }

      // 6. Print successful return data
      // 6. Print Successful Return
      return data; // contains order_id & payment_session_id
    } catch (e) {
      // 7. Print the exception details
      // 7. Print Exception Details
      // Re-throw the exception wrapped in a more general message
      throw Exception("Failed to create order: $e");
    }
  }

  Future<void> verifyPayment({
    required String invoiceId,
    required String schoolCode,
    required String orderId,
    required FeesInvoiceModel feesInvoiceModel,
    required List<CurrentPaidItem> currentPaidItems, // 👈 NEW
    required BuildContext context
  }) async {
    final url = Uri.parse("${Constants.url}/verify_cashfree_payment.php");


    final currentPaidJson = currentPaidItems
        .map((e) => {
      "category_id": e.categoryId,
      "paid_amount": e.paidAmount,
    })
        .toList();


    final body = {
      "order_id": orderId,
      "school_code": schoolCode,
      "invoice_id": invoiceId,
      'invoice_data': jsonEncode(feesInvoiceModel.toJson()),
      // Array of details
      "invoice_details": feesInvoiceModel.details
          ?.map((d) => d.toJson())
          .toList(),
      "current_paid_items": currentPaidJson,// array of detail payments
    };



      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );


      // 1. Check for a successful HTTP status code (200 series) first
      if (response.statusCode >= 200 && response.statusCode < 300) {

        // 2. Decode the JSON string into a Dart Map
        final Map<String, dynamic> responseData = jsonDecode(response.body);


        // 3. Access the 'status' field from the decoded Map
        if (responseData["status"] == "success") {

          Navigator.pop(context);
        } else {
          // Handle server verification failure (e.g., status is "failed")
        }

      } else {
        // Handle HTTP error (e.g., 404, 500)
      }



  }


}
