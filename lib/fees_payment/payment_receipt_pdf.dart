
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'fees_payment_model.dart';
import 'fees_type/fees_type_bloc.dart';

Future<void> generateMergedInvoicePdf({
  required BuildContext context,
  required String schoolName,
  required String schoolAddress,
  required String studentName,
  required String className,
  required String invoiceDate,
  required String referenceNumber,
  required Map<String,List<FeesPayment>> payments,
  required Map<String,Object> mergedPayments,
  required double totalPaid,

 required String modeOfPayment
}) async {
  final feesTypeState = context.read<FeesTypeBloc>().state;

  final Map<int, String> categoryMap = {};

  if (feesTypeState is FeesTypeSuccess) {
    print('📌 FeesType list length: ${feesTypeState.feesType.length}');

    for (var t in feesTypeState.feesType) {
      final id = t.categoryId ?? 0;
      final name = t.categoryName;

      print('➡️ Adding category → id: $id , name: $name');

      categoryMap[id] = name;
    }
  } else {
    print('❌ FeesTypeState is NOT FeesTypeSuccess');
  }

// Final map print
  print('✅ Final categoryMap: $categoryMap');

  // Determine the Receipt/Reference No
  // String receiptNumber =  mergedPayments["reference_no"].toString();



  final pdf = pw.Document();

  // ------------------- THEME COLORS -------------------
  final primaryColor = PdfColor.fromHex("#2d4c9c"); // Dark Maroon
  final headerTextColor = PdfColors.white;

  // ------------------- FONTS -------------------
  final regularFont = pw.Font.ttf(
    await rootBundle.load("images/fontopensans/Roboto-Regular.ttf"),
  );
  final boldFont = pw.Font.ttf(
    await rootBundle.load("images/fontopensans/Roboto-Bold.ttf"),
  );
  final semiBoldFont = pw.Font.ttf(
    await rootBundle.load("images/fontopensans/Roboto-Medium.ttf"),
  );

  final baseStyle = pw.TextStyle(font: regularFont, fontSize: 10);
  final boldStyle = pw.TextStyle(font: boldFont, fontSize: 10);
  final semiBoldStyle = pw.TextStyle(font: semiBoldFont, fontSize: 10);
  String receiptNumber = "#N/A";
  if (payments.isNotEmpty && payments.values.first.isNotEmpty) {
    // Using the reference_no from the first payment item
    receiptNumber = payments.values.first.first.referenceNo;
  }
  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        // Take first record
        final FeesPayment first = payments.values.first.first;

        final String mode = modeOfPayment;
        final String formattedDate =
        DateFormat("dd-MM-yyyy").format(first.paymentDate);
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER (Top Address Bar - Simplified) ----------------
            pw.Container(
              height: 40,
              decoration: pw.BoxDecoration(color: primaryColor),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          schoolName,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 12,
                            color: headerTextColor,
                          ),
                        ),
                        pw.Text(
                          schoolAddress,
                          style: baseStyle.copyWith(
                            fontSize: 8,
                            color: headerTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Placeholder for the school logo/icon on the right
                  pw.Container(
                    width: 30,
                    height: 30,
                    margin: const pw.EdgeInsets.only(right: 10),
                    decoration: pw.BoxDecoration(
                      color: headerTextColor,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text("Cc.", style: pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor)),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // ---------------- TITLE ----------------
            pw.Center(
              child: pw.Text(
                "School Fee Receipt",
                style: pw.TextStyle(
                  fontSize: 18,
                  font: boldFont,
                  color: PdfColors.black,
                ),
              ),
            ),

            pw.SizedBox(height: 15),

            // ---------------- RECEIPT DETAILS & STUDENT INFO ----------------
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [

                pw.Text("Receipt No: $receiptNumber", style: semiBoldStyle),
              ],
            ),
            pw.SizedBox(height: 8),
            // Student Details
            pw.Text(
                "Student Name: $studentName | Class: $className",
                style: semiBoldStyle
            ),


            pw.SizedBox(height: 15),

            // ---------------- COMMON PAYMENT DETAILS (New addition) ----------------
            pw.Text(
              "Payment Mode: $mode",
              style: baseStyle.copyWith(color: PdfColors.grey700),
            ),
            pw.Text(
              "Payment Date: $formattedDate",
              style: baseStyle.copyWith(color: PdfColors.grey700),
            ),

            pw.SizedBox(height: 25),

            // ---------------- PAYMENT SPLIT-UP TABLE ----------------
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No.
                1: const pw.FlexColumnWidth(3.0), // Fee Type
                2: const pw.FlexColumnWidth(1.5), // Amount (INR)
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell("S.No.", boldStyle, PdfColors.black), // Added S.No.
                    _cell("Fee Type", boldStyle, PdfColors.black),
                    _cell("Amount (INR)", boldStyle, PdfColors.black),
                  ],
                ),

                // Data
                // Data
                ...payments.entries.expand((entry) {
                  final List<FeesPayment> list = entry.value;

                  final allowedRefs =  mergedPayments["reference_no"].toString();



// Filter: include only those matching mergedPayments referenceNo
                  final filteredList = list.where((p) {
                    final match = allowedRefs.contains(p.referenceNo);


                    return match;
                  }).toList();

                  return List.generate(filteredList.length, (index) {
                    final p = filteredList[index];


                    print("Category Id: ${p.categoryId}");
                    final categoryName =
                        categoryMap[int.tryParse(p.categoryId ?? '0')] ?? "--";

                    final runningIndex = index + 1;

                    return pw.TableRow(
                      children: [
                        _cell("$runningIndex", baseStyle),
                        _cell(categoryName, baseStyle),
                        _cell("₹${p.amountPaid.toStringAsFixed(2)}", baseStyle),
                      ],
                    );
                  });
                }).toList(),

              ],
            ),

            pw.SizedBox(height: 25),

            // ---------------- TOTAL AND BALANCE SECTION ----------------


            pw.RichText(
              text: pw.TextSpan(
                style: semiBoldStyle.copyWith(fontSize: 12),
                children: [
                  pw.TextSpan(text: "Amount Paid: "),
                  pw.TextSpan(
                    text: "₹${totalPaid.toStringAsFixed(2)}",
                    style: semiBoldStyle.copyWith(font: boldFont),
                  ),
                  // pw.TextSpan(text: " | Outstanding Balance: "),
                  // pw.TextSpan(
                  //   text: "₹${outstandingBalance.toStringAsFixed(2)}",
                  //   style: semiBoldStyle.copyWith(font: boldFont),
                  // ),
                ],
              ),
            ),

            pw.SizedBox(height: 50),

            // ---------------- FOOTER ----------------
            pw.Text(
              "Thank you for your payment. Should you have any queries, feel free to reach out.",
              style: baseStyle,
            ),
            // pw.SizedBox(height: 5),
            // pw.Text(
            //   "For further assistance, contact us at [YOUR EMAIL] or call [YOUR COMPANY NUMBER].",
            //   style: baseStyle.copyWith(color: PdfColors.grey700),
            // ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Generated Date : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
              style: baseStyle.copyWith(color: PdfColors.grey700),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}

// Helper cell method
pw.Padding _cell(String text, pw.TextStyle style, [PdfColor? color]) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: style.copyWith(color: color),
    ),
  );
}