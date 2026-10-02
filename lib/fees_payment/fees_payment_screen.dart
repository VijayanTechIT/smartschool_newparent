
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_parent/fees_payment/payment_receipt_pdf.dart' show generateMergedInvoicePdf;

import '../../student/StudentModel.dart';
import '../academic_bloc/academic_year_bloc.dart';
import 'fees_invoice_detail_model.dart';
import 'fees_invoice_model.dart';
import 'fees_payment_bloc.dart';
import 'fees_payment_model.dart';
import 'fees_scholarship/fees_scholarship_list/fees_scholarship_list_bloc.dart';
import 'fees_scholarship/fees_scholarship_model.dart';
import 'fees_term/fees_term_bloc.dart';
import 'fees_type/fees_pay_screen.dart';
import 'fees_type/fees_type_bloc.dart';


class FeesPaymentScreen extends StatelessWidget {
  const FeesPaymentScreen({super.key,
    required this.schoolName,
    required this.student,
    required this.payButtonStatus,
    required this.schoolAddress,
    required this.schoolCode,
    // required this.user
  });
  // final String user;
  final String schoolName;
  final String schoolAddress;
  final String schoolCode;
  final bool payButtonStatus;
  final StudentWhole student;

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC and trigger the initial load event
    return _FeesPaymentView(
      payButtonStatus: payButtonStatus,
      schoolCode: schoolCode,
      schoolAddress: schoolAddress,
      schoolName: schoolName,
      student: student,
      // user:user ,
    );
  }
}

class _FeesPaymentView extends StatelessWidget {
  const _FeesPaymentView({
    required this.schoolCode,
    required this.payButtonStatus,
    required this.schoolName,
    required this.schoolAddress,
    // required this.user,
  required this.student});
  // final String user;
  final String schoolCode;
  final bool payButtonStatus;
  final String schoolName;
  final String schoolAddress;
  final StudentWhole student;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Payment',
          style: TextStyle(fontSize: 14),),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<FeesPaymentBloc, FeesPaymentState>(
        builder: (context, state) {

          if (state is FeesPaymentLoading || state is FeesPaymentInitial) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (state is FeesPaymentError) {
            return Center(child: Text('Error: ${state.message}',
                style: const TextStyle(color: Colors.red)));
          }
          if (state is FeesPaymentLoaded) {
            return
              // Expanded(
              // child:
              _buildInvoiceList(state,'',student,payButtonStatus)
            ;
          }else {
            return const Center(
                child: CircularProgressIndicator(
                    color: Colors.indigo));
          } },
      ),
    );
  }

  // --- Widget Builders ---


  Widget _buildInvoiceList(FeesPaymentLoaded state,String user,StudentWhole student,bool payButtonStatus) {


    if (state.feesInvoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 35.0),
          child: Text(
            'No outstanding invoices found for ${student.name}.',
            style: TextStyle(color: Colors.green.shade700, fontStyle: FontStyle.italic, fontSize: 16),
          ),
        ),
      );
    }

    String? currentAcademicId;

    return BlocBuilder<FeesScholarshipListBloc, FeesScholarshipListState>(
      builder: (context, scholarshipState) {
        List<StudentScholarship> scholarships=[];
        if(scholarshipState is FeesScholarshipListSuccess){
          scholarships =  scholarshipState.scholarships;
        }
    return BlocBuilder<AcademicYearBloc, AcademicYearState>(
      builder: (context, academicState) {
        return BlocBuilder<FeesTermBloc, FeesTermState>(
          builder: (context, termState) {
            Map<String, String> termMap = {};

            if (termState is FeesTermSuccess) {
              termMap = {for (var t in termState.feesTerm) t.termId.toString()
                  : t.termName};
            }

            Map<String,String> academicMap = {};

            if(academicState is AcademicYearSuccess){
              academicMap = {for(var a in academicState.academicYears)
                a.id.toString() : a.academicYear};
              currentAcademicId = academicState.activeAcademicYear?.id;
            }

            final filteredInvoices = state.feesInvoices.where((inv) {
              final balance = inv.balanceAmount;
              final isCurrentYear = inv.academicId.toString() == currentAcademicId.toString();

              return balance > 0 || isCurrentYear;
            }).toList();


            return ListView.builder(
              itemCount: filteredInvoices.length,
              itemBuilder: (context, index) {

                final invoice = state.feesInvoices[index];
                final termName = termMap[invoice.termId.toString()] ?? "Term ${invoice.termId}";
                final academicYear = academicMap[invoice.academicId.toString()]
                    ?? "${invoice.academicId}";

                final invoicePayments = state.paymentData
                    .where((p) => p.invoiceId == invoice.invoiceId)
                    .toList();

                final filteredScholarships = scholarships.where((scholar){
                  return scholar.studentId.toString() == state.selectedStudent.id.toString()
                      && scholar.isActive.toString() == 'true';
                }).toList();



                return InvoiceCard(
                  payButtonStatus: payButtonStatus,
                  invoice: invoice,
                  termName: termName,
                  schoolName: schoolName,
                  schoolAddress: schoolAddress,
                  student: state.selectedStudent,
                  invoicePayments:invoice.paymentsAgainstInvoice ?? [],
                  academicYear: academicYear,
                  onPay: () => _showPaymentDialog(context, invoice,schoolCode,user,student),
                  scholarships: filteredScholarships,
                );


              },
            );
          },
        );
      },
    );
  },
);
  }
}
// --- Invoice Card (Used within the list) ---

class InvoiceCard extends StatefulWidget {
  final FeesInvoiceModel invoice;
  final String termName;
  final String academicYear;
  final VoidCallback onPay;
  final List<FeesPayment> invoicePayments;
  final StudentWhole student;
  final bool payButtonStatus;
  final String schoolName;
  final String schoolAddress;
  final List<StudentScholarship> scholarships;
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.payButtonStatus,
    required this.termName,
    required this.onPay,
    required this.scholarships,
    required this.schoolName,
    required this.schoolAddress,
    required this.student,
    required this.academicYear,required this.invoicePayments
  });

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  final Map<String, double> scholarshipByCategory = {};
  final Map<String, TextEditingController> controllers = {};
  @override
  void initState() {
    super.initState();

    // Build base scholarship map from backend data
    for (var s in widget.scholarships) {
      final key = s.feeType.toString();

      double value = 0;

      // Find matching fee item
      FeesInvoiceDetailModel? feeItem;
      final matchingItems = widget.invoice.details!
          .where((item) => item.categoryId.toString() == key)
          .toList();

      if (matchingItems.isNotEmpty) {
        feeItem = matchingItems.first;
      } else {
        feeItem = null;
        debugPrint("⚠️ Fee item not found for categoryId: $key");
      }

      if (feeItem != null) {
        final remainingAmount =
        (feeItem.amount - feeItem.paidAmount).clamp(0.0, double.infinity);

        if (s.discountType == "percentage") {
          value = (feeItem.amount * s.discountValue / 100);
        } else {
          value = s.discountValue;
        }

        // ⭐ Cap scholarship to the remaining fee amount
        value = value.clamp(0.0, remainingAmount);
      }

      scholarshipByCategory[key] = (scholarshipByCategory[key] ?? 0) + value;
    }

    // Prepare controllers for each category row
    for (var item in widget.invoice.details!) {
      final key = item.categoryId.toString();
      final remaining = (item.amount - item.paidAmount).clamp(0.0, double.infinity);

      // Cap again while assigning to controller
      final initial = (scholarshipByCategory[key] ?? 0.0).clamp(0.0, remaining);

      controllers[key] =
          TextEditingController(text: initial.toStringAsFixed(0));

      // Update back into the map so totals are correct
      scholarshipByCategory[key] = initial;
    }
  }
  Map<String, double> getScholarshipValues() {
    final Map<String, double> data = {}; controllers.forEach((key, ctrl)
    { data[key] = double.tryParse(ctrl.text) ?? 0.0; }); return data; }
  @override
  Widget build(BuildContext context) {
    // Calculate grouped payments as before (unchanged)
    final groupedPayments = <String, List<FeesPayment>>{};
    for (var p in widget.invoicePayments) {
      groupedPayments.putIfAbsent(p.referenceNo, () => []);
      groupedPayments[p.referenceNo]!.add(p);
    }

    final mergedPayments = groupedPayments.entries.map((entry) {
      final ref = entry.key;
      final group = entry.value;
      final totalAmount =
      group.fold(0.0, (sum, p) => sum + p.amountPaid);

      return {
        "reference_no": ref,
        "date": group.first.createdOn!,
        "amount": totalAmount,
        "mode": group.first.modeOfPayment,
      };
    }).toList();


    final totalScholarship = widget.invoice.details!.fold(0.0, (sum, item) {
      final key = item.categoryId.toString();

      // If already fully paid → no scholarship
      if (item.paidAmount >= item.amount) return sum;

      final scholarshipValue = scholarshipByCategory[key] ?? 0.0;

      // Remaining fee = amount - paidAmount
      final remaining = item.amount - item.paidAmount;

      // Scholarship cannot exceed the remaining amount
      final cappedScholarship = scholarshipValue.clamp(0.0, remaining);

      return sum + cappedScholarship;
    });



    final adjustedBalanceTotal =
    (widget.invoice.totalAmount -
        widget.invoice.paidAmount -
        totalScholarship)
        .clamp(0, double.infinity);


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.termName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.indigo,
                  ),
                ),
                Text(
                  'AY : ${widget.academicYear}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 4),
            // Text(
            //   'Invoice Date: ${DateFormat('dd-MM-yyyy').format(invoice.invoiceDate)}',
            //   style: const TextStyle(fontSize: 13, color: Colors.black54),
            // ),
            const Divider(height: 20),


            // --- Fee Split-Up Table ---
            const Text(
              'Fee Breakdown:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                  fontSize: 14),
            ),
            const SizedBox(height: 6),

            BlocBuilder<FeesTypeBloc, FeesTypeState>(
              builder: (context, feesTypeState) {
                Map<String, String> categoryMap = {};
                Map<String, int> priorityMap = {};
                if (feesTypeState is FeesTypeSuccess) {
                  // Assuming FeesTypeModel has id and name
                  categoryMap = {
                    for (var c in feesTypeState.feesType)
                      c.categoryId.toString(): c.categoryName
                  };


                  priorityMap = {
                    for (var c in feesTypeState.feesType)
                      c.categoryId.toString(): c.priority ?? 999
                  };
                }
                // Define consistent column widths
                const double colWidthFeesType = 120.0; // Increased width for text
                const double colWidthAmount = 100.0;
                const double colWidthPaid = 100.0;
                const double colWidthScholarship = 120.0; // Increased for TextFormField
                const double colWidthBalance = 100.0;

                // Calculate total required width
                const double totalTableWidth = colWidthFeesType +
                    colWidthAmount +
                    colWidthPaid +
                    colWidthScholarship +
                    colWidthBalance +
                    (5 * 10); // Add some padding/margin allowance

                final sortedDetails = [...widget.invoice.details!];

                sortedDetails.sort((a, b) {
                  final pa = priorityMap[a.categoryId.toString()] ?? 999;
                  final pb = priorityMap[b.categoryId.toString()] ?? 999;
                  return pa.compareTo(pb);
                });
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          // Give the scrollable content a defined width
                          width: totalTableWidth,
                          child: Column(
                            children: [
                              // ---- TABLE HEADER ----
                              Container(
                                color: Colors.indigo.shade50,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    SizedBox(
                                        width: colWidthFeesType,
                                        child: Text('  Fee Type',
                                            style: TextStyle(fontWeight: FontWeight.bold))),
                                    SizedBox(
                                        width: colWidthAmount,
                                        child: Text('Amount',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontWeight: FontWeight.bold))),
                                    SizedBox(
                                        width: colWidthPaid,
                                        child: Text('Paid',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontWeight: FontWeight.bold))),
                                    SizedBox(
                                        width: colWidthScholarship,
                                        child: Text('Scholarship',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontWeight: FontWeight.bold))),
                                    SizedBox(
                                        width: colWidthBalance,
                                        child: Text('Balance',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),



                              // ---- TABLE ROWS ----
                              ...sortedDetails.map((item) {
                                final key = item.categoryId.toString();
                                final categoryName =
                                    categoryMap[key] ?? "Category ${item.categoryId}";

                                final scholarshipAmt =
                                    double.tryParse(controllers[key]!.text) ?? 0.0;

                                final adjustedBalance =
                                (item.amount - item.paidAmount - scholarshipAmt)
                                    .clamp(0, double.infinity);


                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(width: colWidthFeesType, child: Column(
                                        mainAxisSize:MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(categoryName),
                                          if (widget.invoice.remarks.trim().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                widget.invoice.remarks,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                        ],
                                      )),
                                      SizedBox(
                                          width: colWidthAmount,
                                          child: Text(
                                            indianFormat.format(item.amount),
                                            textAlign: TextAlign.right,
                                          )),
                                      SizedBox(
                                          width: colWidthPaid,
                                          child: Text(
                                            indianFormat.format(item.paidAmount),
                                            textAlign: TextAlign.right,
                                          )),
                                      SizedBox(
                                          width: colWidthPaid,
                                          child: Text(
                                            indianFormat.format(scholarshipByCategory[item.categoryId.toString()]),
                                            textAlign: TextAlign.right,
                                          )),
                                      // SizedBox(
                                      //   width: colWidthScholarship,
                                      //   child: isFullyPaid
                                      //       ? const Text(
                                      //     "—",
                                      //     textAlign: TextAlign.center,
                                      //     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                      //   )
                                      //       : SizedBox(
                                      //     height: 32,
                                      //     child: TextFormField(
                                      //       controller: controllers[key],
                                      //       keyboardType: TextInputType.number,
                                      //       textAlign: TextAlign.right,
                                      //       style: const TextStyle(
                                      //         color: Colors.green,
                                      //         fontWeight: FontWeight.bold,
                                      //       ),
                                      //       decoration: const InputDecoration(
                                      //         border: OutlineInputBorder(),
                                      //         contentPadding:
                                      //         EdgeInsets.symmetric(horizontal: 6),
                                      //       ),
                                      //       onChanged: (value) {
                                      //         double v = double.tryParse(value) ?? 0.0;
                                      //
                                      //         // Prevent exceeding available amount
                                      //         double maxAllowed = (item.amount - item.paidAmount).clamp(0, double.infinity);
                                      //         if (v > maxAllowed) {
                                      //           v = maxAllowed;
                                      //           controllers[key]!.text = v.toStringAsFixed(0);
                                      //           controllers[key]!.selection = TextSelection.fromPosition(
                                      //             TextPosition(offset: controllers[key]!.text.length),
                                      //           );
                                      //         }
                                      //
                                      //         setState(() {
                                      //           scholarshipByCategory[key] = v;
                                      //         });
                                      //       },
                                      //
                                      //     ),
                                      //   ),
                                      // ),

                                      SizedBox(
                                          width: colWidthBalance,
                                          child: Text(
                                            indianFormat.format(adjustedBalance),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(color: Colors.red),
                                          )),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            const Divider(),

            // --- Summary Section ---
            _buildInfoRow('Total Fee:', '₹${widget.invoice.totalAmount.toStringAsFixed(2)}'),
            _buildInfoRow('Paid Amount:', '₹${widget.invoice.paidAmount.toStringAsFixed(2)}'),
            _buildInfoRow(
              'Outstanding Balance:',
              '₹${widget.invoice.balanceAmount.toStringAsFixed(2)}',
              color: Colors.red.shade700,
              isBold: true,
            ),

            const SizedBox(height: 10),
            if (widget.invoicePayments.isNotEmpty) ...[
              const Text(
                "Previous Payments:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: mergedPayments.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:2,
                            child: Text(
                              DateFormat('dd-MM-yyyy').format(p["date"] as DateTime),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Expanded(flex:2,
                            child: Text(
                              '${indianFormat.format(p["amount"])}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(flex:2,
                            child: Text(
                              p["mode"] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue,
                                  fontSize: 14
                              ),
                            ),
                          ),
                          Expanded(flex:1,
                            child: InkWell(
                              onTap: () async{

                                await generateMergedInvoicePdf(
                                    context: context,
                                    referenceNumber: p['referenceNo'].toString() ?? '',
                                    schoolName: widget.schoolName,
                                    schoolAddress:widget.schoolAddress,
                                    studentName: widget.student.name,
                                    className: "${widget.student.studyingGrade}-${widget.student.studyingSection}",
                                    invoiceDate: DateFormat('dd-MM-yyyy').format(
                                        groupedPayments.entries.first.value.first.paymentDate),
                                    totalPaid: p['amount'] as double,
                                    payments: groupedPayments,
                                    mergedPayments: p,
                                    modeOfPayment: p['mode'].toString()
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),

                                ],
                              ),
                            ),
                          )

                        ],
                      ),
                    );
                  }).toList(),

                ),
              ),
            ],

            if(widget.invoice.balanceAmount > 0 && widget.payButtonStatus)
            Center(
              child: ElevatedButton.icon(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FeeInformationScreen(
                        invoice: widget.invoice,
                        schoolCode: widget.invoice.schoolCode,
                        studentId: widget.student.id,
                        user: widget.student.studentId,
                        student: widget.student,
                      ),
                    ),
                  ).then((value){
                     context.read<FeesPaymentBloc>().add(LoadInitialFeesPaymentData(
                        schoolCode: widget.invoice.schoolCode,
                        student: widget.student,
                        studentId: widget.invoice.studentId.toString()));
                  });


                },
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('Make Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color color = Colors.black87, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: color)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }
}

void _showPaymentDialog(
    BuildContext outerContext,
    FeesInvoiceModel invoice,
    String schoolCode,
    String user,
    StudentWhole student
    )
{
  final amountController = TextEditingController();
  String selectedMode = "Online";
  bool isFullPayment = false;

  // Track category-wise payments
  Map<int, double> categoryPayments = {
    for (var d in invoice.details ?? []) d.categoryId: 0.0
  };

  // Controllers for category inputs
  final Map<int, TextEditingController> controllers = {};

  void disposeControllers() {
    amountController.dispose();
    for (var c in controllers.values) {
      c.dispose();
    }
  }

  showDialog(
    context: outerContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (context, setState) {
        final feesPaymentBloc = outerContext.read<FeesPaymentBloc>();
        categoryPayments.values.fold(0.0, (a, b) => a + b);

        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay Invoice',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Balance Due: ₹${invoice.balanceAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // FULL PAYMENT CHECKBOX
                  Row(
                    children: [
                      Checkbox(
                        value: isFullPayment,
                        onChanged: (val) {
                          setState(() {
                            isFullPayment = val ?? false;

                            if (isFullPayment) {
                              amountController.text =
                                  invoice.balanceAmount.toStringAsFixed(2);

                              categoryPayments = {
                                for (var d in invoice.details ?? [])
                                  d.categoryId: d.balanceAmount
                              };

                              for (var d in invoice.details ?? []) {
                                controllers[d.categoryId]?.text =
                                    d.balanceAmount.toStringAsFixed(2);
                              }
                            } else {
                              amountController.clear();

                              categoryPayments = {
                                for (var d in invoice.details ?? [])
                                  d.categoryId: 0.0
                              };

                              for (var c in controllers.values) {
                                c.clear();
                              }
                            }
                          });
                        },
                      ),
                      const Text('Full Payment'),
                    ],
                  ),

                  // TOTAL AMOUNT FIELD
                  TextField(
                    controller: amountController,
                    enabled: isFullPayment, // disabled during partial
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Total Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  const Text(
                    "Category-wise Payment Split",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // CATEGORY TABLE
                  BlocBuilder<FeesTypeBloc, FeesTypeState>(
                    builder: (context, feesTypeState) {
                      Map<int, String> categoryMap = {};
                      if (feesTypeState is FeesTypeSuccess) {
                        categoryMap = {
                          for (var c in feesTypeState.feesType)
                            c.categoryId!: c.categoryName,
                        };
                      }

                      if (!isFullPayment &&
                          (invoice.details?.isNotEmpty ?? false)) {
                        return Column(
                          children: invoice.details!.map((detail) {
                            final categoryName =
                                categoryMap[detail.categoryId] ??
                                    'Category ${detail.categoryId}';

                            final controller = controllers.putIfAbsent(
                              detail.categoryId,
                                  () => TextEditingController(
                                text: categoryPayments[detail.categoryId]! > 0
                                    ? categoryPayments[detail.categoryId]!
                                    .toStringAsFixed(2)
                                    : '',
                              ),
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  // CATEGORY NAME
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      categoryName,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),

                                  // BALANCE COLUMN
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "₹${detail.balanceAmount.toStringAsFixed(2)    }",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // ENTER AMOUNT FIELD
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Enter Amount',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        double entered = double.tryParse(val) ?? 0.0;

                                        final double maxAllowedForCategory = detail.balanceAmount;

                                        // 1️⃣ Prevent category > its balance
                                        if (entered > maxAllowedForCategory) {
                                          entered = maxAllowedForCategory;

                                          controller.text = entered.toStringAsFixed(2);
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );

                                          ScaffoldMessenger.of(outerContext).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Amount for "$categoryName" cannot exceed ₹${maxAllowedForCategory.toStringAsFixed(2)}',
                                              ),
                                            ),
                                          );
                                        }

                                        // 2️⃣ Save the corrected value
                                        categoryPayments[detail.categoryId] = entered;

                                        // 3️⃣ Recalculate TOTAL ALWAYS = sum
                                        final newTotal =
                                        categoryPayments.values.fold(0.0, (a, b) => a + b);

                                        // 4️⃣ Assign auto total (NO manual typing allowed)
                                        amountController.text = newTotal.toStringAsFixed(2);
                                      },

                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 8),

                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                disposeControllers();
                Navigator.pop(dialogCtx);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final enteredAmount =
                    double.tryParse(amountController.text) ?? 0.0;

                if (enteredAmount <= 0) {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                if (enteredAmount > invoice.balanceAmount + 0.01) {
                  ScaffoldMessenger.of(outerContext).showSnackBar(
                    const SnackBar(
                        content: Text('Amount exceeds balance due')),
                  );
                  return;
                }

                // BUILD UPDATED DETAILS
                final updatedDetails = invoice.details?.map((d) {
                  final paidNow = isFullPayment
                      ? d.balanceAmount
                      : (categoryPayments[d.categoryId] ?? 0.0);

                  return d.copyWith(
                    paidAmount: paidNow,
                    balanceAmount: (d.balanceAmount - paidNow)
                        .clamp(0.0, double.infinity),
                  );
                }).toList();

                // DISPATCH EVENT
                feesPaymentBloc.add(
                  MakePayment(
                    studentId: student.studentId,
                    invoice: invoice.copyWith(details: updatedDetails),
                    amountPaid: enteredAmount,
                    schoolCode: schoolCode,
                    mode: selectedMode,
                    user: user,
                  ),
                );

                disposeControllers();
                Navigator.pop(dialogCtx);
              },
              child: const Text('Submit Payment'),
            ),
          ],
        );
      },
    ),
  );
}


final indianFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '',
  decimalDigits: 0, // remove .00
);



