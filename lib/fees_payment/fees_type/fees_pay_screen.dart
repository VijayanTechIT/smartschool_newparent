import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import '../../student/StudentModel.dart';
import '../fees_invoice_detail_model.dart';
import '../fees_invoice_model.dart';
import '../payment_api.dart';
import 'fees_type_bloc.dart';

class FeeInformationScreen extends StatefulWidget {
  final FeesInvoiceModel invoice; // singular invoice
  final String schoolCode;
  final StudentWhole? student;
  final String studentId;
  final String user;

  FeeInformationScreen({
    super.key,
    required this.invoice,
    required this.schoolCode,
    required this.studentId,
    required this.user,
    required this.student
  });

  @override
  State<FeeInformationScreen> createState() => _FeeInformationScreenState();
}

class _FeeInformationScreenState extends State<FeeInformationScreen> {
  // Sum paid across invoice details
  double sumPaid() {
    final details = widget.invoice.details ?? <FeesInvoiceDetailModel>[];
    return details.fold<double>(0.0, (sum, d) => sum + (d.paidAmount));
  }

  // Sum due across invoice details
  double sumDue() {
    final details = widget.invoice.details ?? <FeesInvoiceDetailModel>[];
    return details.fold<double>(0.0, (sum, d) => sum + (d.balanceAmount));
  }

  final cashfree = CashfreeService();

  @override
  Widget build(BuildContext context) {
    final details = widget.invoice.details ?? <FeesInvoiceDetailModel>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2346A5),
        title: const Text("Fee Information",
        style: TextStyle(
          fontSize: 18
        ),),
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),

              Expanded(
                child: ListView(
                  children: [
                    // Iterate details (each row is a category/line item)
                    ...details.map(
                          (detail) => _buildFeeRow(widget.student,context, detail,
                          widget.schoolCode),
                    ),

                    _buildTotalRow(context,widget.student),

                    const SizedBox(height: 12),
                  ],
                ),
              )
            ],
          ),
          if (_isLoading)
            const AbsorbPointer( // Prevents interaction with widgets underneath
              child: ModalBarrier( // Darkens the background
                color: Colors.black38,
                dismissible: false,
              ),
            ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE71F2A)), // Use your brand color
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      color: Colors.grey.shade200,
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("Fee Type", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Paid", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Due", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Pay now", textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  Widget _buildFeeRow(
      StudentWhole? student,
      BuildContext context,
      FeesInvoiceDetailModel detail,
      String schoolCode,
      )
  {

    final feeTitle = getCategoryName(context, detail.categoryId);

    final paid = detail.paidAmount;
    final balance = detail.balanceAmount;
    bool isPayable = balance > 0 || _isLoading;

    if(balance ==  0){
      isPayable = false;
    }

    print("Fee Title: $feeTitle  -${isPayable}-- $balance  --- ${balance > 0 } ==  ${_isLoading}");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feeTitle,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "₹${paid.toStringAsFixed(0)}",
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(     flex: 2,
            child: Text(
              "₹${balance.toStringAsFixed(0)}",
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                    onPressed: !isPayable ? null :
                      // 1. Set loading to true
                     () async {
                       setState(() {
                         _isLoading = true;
                       });
                       try{
                       final order = await cashfree.createCashfreeOrder(
                        schoolCode: schoolCode,
                        amount: balance,
                        customerId: student?.studentId ?? "MYST002",
                        customerName: student?.name ?? 'Maya',
                        customerEmail: student?.email ?? 'maya@123.com',
                        customerPhone: student?.phoneNumber ?? '1234567809',
                      );


                      final orderId = order["order_id"];
                      final sessionId = order["payment_session_id"];




                      if (orderId != null && sessionId != null) {
                        // Proceed to Cashfree payment screen
                        startCashfreePayment(
                          orderId: orderId,
                          fullPayment: false,
                          paymentSessionId: sessionId,
                          detailId: detail.categoryId.toString(),
                          amount: balance,
                            context: context
                        );

                      } else {
                      }}catch(e){
// Handle any errors during the async operation
                         print("Error during payment initiation: $e");
                       } finally {
                         // 2. Set loading to false when the process is complete
                         // (either success, failure, or navigation away)
                         setState(() {
                           _isLoading = false;
                         });
                       }
                    },

                    style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: isPayable
                          ? const Color(0xFFE71F2A)
                          : Colors.grey.shade400, // disabled color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Pay",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;

  String getCategoryName(BuildContext context, int? categoryId) {
    if (categoryId == null) return "Unknown Fee";

    final state = context.read<FeesTypeBloc>().state;

    if (state is FeesTypeSuccess) {
      final type = state.feesType.firstWhere(
            (t) => t.categoryId.toString() == categoryId.toString(),

      );
      return type.categoryName;
    }

    return "Loading...";
  }

  // ---------------------------------------------------------------
  Widget _buildTotalRow(BuildContext context,StudentWhole? student) {
    // Define key colors for better theming
    const Color primaryColor = Color(0xFF3B8794); // A strong blue
    const Color successColor = Color(0xFF388E3C); // Dark green
    const Color errorColor = Color(0xFFD32F2F);   // Dark red
    const Color buttonColor = Color(0xFFE71F2A); // Deep orange

    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use minimum space vertically
        children: [
          /// --- Financial Summary Row (Total, Paid, Due) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// --- Total Label ---
              Text(
                "TOTAL AMOUNT",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// --- Total Paid ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Paid",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${sumPaid().toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 16,
                            color: successColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24), // Separation

                    /// --- Total Due ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Due",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${sumDue().toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 18,
                            color: errorColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15), // Separator between summary and button

          /// --- Button Row (Pay Now) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.credit_card, size: 18),
                label: const Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  double amount = double.parse(sumDue().toStringAsFixed(0));


                  if (amount <= 0) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("No dues to pay.")),
                    // );
                    return;
                  }

try{
                  final order = await cashfree.createCashfreeOrder(
                    schoolCode: widget.schoolCode,
                    amount: amount,
                    customerId: student?.studentId ?? "MYST002",
                    customerName: student?.name ?? 'Maya',
                    customerEmail: student?.email ?? 'maya@123.com',
                    customerPhone: student?.phoneNumber ?? '1234567809',
                  );

                  final orderId = order["order_id"];
                  final sessionId = order["payment_session_id"];


                  if (orderId == null || sessionId == null) {
                    // Handle error UI here if necessary
                    return;
                  }

                  if (orderId != null && sessionId != null) {
                    // Proceed to Cashfree payment screen
                    startCashfreePayment(
                      orderId: orderId,
                      paymentSessionId: sessionId,
                      fullPayment: true,
                      detailId: '0',
                      amount: sumDue(),
                      context: context,
                    );
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    // This else block is technically unreachable due to the 'if (orderId == null || sessionId == null)' check above,
                    // but a print statement here would catch unexpected logic failures.
                  }}catch(e){
  setState(() {
    _isLoading = false;
  });
} finally {
  // 2. Set loading to false when the process is complete
  // (either success, failure, or navigation away)

}     // Launch the payment checkout
                },
              ),
            ],
          ),
          /// --- Divider Below Pay Button ---
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Divider(
              height: 1,
              thickness: 1.5,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  void startCashfreePayment({
    required String orderId,
    required String paymentSessionId,
    required bool fullPayment,
    required String detailId,required double amount,
    required BuildContext context
  })
  async {
    // REQUIRED: setup callbacks once
    _initPaymentCallbacks(fullPayment,detailId,amount,context);

    // STEP 1 — Build session
    final session = _buildSession(
      orderId: orderId,
      paymentSessionId: paymentSessionId,
      environment: CFEnvironment.SANDBOX,  // OR CFEnvironment.PRODUCTION
    );

    if (session == null) {
      return;
    }

    // STEP 2 — Build Web Checkout object
    final webCheckoutPayment = CFWebCheckoutPaymentBuilder()
        .setSession(session)
        .build();

    // STEP 3 — Start Payment

      await CFPaymentGatewayService().doPayment(webCheckoutPayment);

  }

  CFSession? _buildSession({
    required String orderId,
    required String paymentSessionId,
    required CFEnvironment environment,
  })
  {
    try {

      setState(() {
        _isLoading = false;
      });
      return CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

    } on CFException catch (e) {
      return null;
    }
  }

  void _initPaymentCallbacks(
      bool fullPayment,
      String categoryId,
      double paidAmount,
      BuildContext context,
      ) {
    CFPaymentGatewayService().setCallback(
          (String orderId) async {
       final List<CurrentPaidItem> currentPaidList = [];

       if (fullPayment) {
         // Full payment → pay remaining balance for all categories
         for (final d in widget.invoice.details ?? []) {
           final remaining = d.balanceAmount;
           if (remaining > 0) {
             currentPaidList.add(
               CurrentPaidItem(
                 categoryId: d.categoryId,
                 paidAmount: remaining,
               ),
             );
           }
         }
       } else {
         // Partial payment → only selected category
         currentPaidList.add(
           CurrentPaidItem(
             categoryId: int.parse(categoryId),
             paidAmount: paidAmount,
           ),
         );
       }

       // STEP 1: Update category-wise details
        final updatedDetails = widget.invoice.details?.map((d) {
          if (fullPayment) {
            return d.copyWith(
              paidAmount: d.amount,
              balanceAmount: 0.0,
            );
          } else {
            if (d.categoryId.toString() == categoryId.toString()) {
              final newPaid = (d.paidAmount + paidAmount).clamp(0.0, d.amount);
              final newBalance =
              (d.balanceAmount - paidAmount).clamp(0.0, d.amount);

              return d.copyWith(
                paidAmount: newPaid,
                balanceAmount: newBalance,
              );
            } else {
              return d;
            }
          }
        }).toList();

        // STEP 2: Update TOTAL invoice paid and balance
        double newInvoicePaid = widget.invoice.paidAmount;
        double newInvoiceBalance = widget.invoice.balanceAmount;

        if (fullPayment) {
          newInvoicePaid = widget.invoice.totalAmount;
          newInvoiceBalance = 0.0;
        } else {
          newInvoicePaid = (widget.invoice.paidAmount + paidAmount)
              .clamp(0.0, widget.invoice.totalAmount);
          newInvoiceBalance = (widget.invoice.balanceAmount - paidAmount)
              .clamp(0.0, widget.invoice.totalAmount);
        }

        // STEP 3: Send to server
        await CashfreeService().verifyPayment(
          orderId: orderId,
          feesInvoiceModel: widget.invoice.copyWith(
            paidAmount: newInvoicePaid,
            balanceAmount: newInvoiceBalance,
            details: updatedDetails,
          ),
          currentPaidItems: currentPaidList, // 👈 NEW
          invoiceId: widget.invoice.invoiceId.toString(),
          schoolCode: widget.schoolCode,
          context: context,
        );
      },
          (CFErrorResponse error, String orderId) {},
    );
  }
}


class CurrentPaidItem {
  final int categoryId;
  final double paidAmount;

  CurrentPaidItem({
    required this.categoryId,
    required this.paidAmount,
  });
}
