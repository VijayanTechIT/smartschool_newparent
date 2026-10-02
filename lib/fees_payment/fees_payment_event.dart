part of 'fees_payment_bloc.dart';

sealed class FeesPaymentEvent {}


class LoadInitialFeesPaymentData extends FeesPaymentEvent {
  final String schoolCode;
  final String studentId;
  final StudentWhole student;
  LoadInitialFeesPaymentData({required this.schoolCode,
  required this.studentId,required this.student});
}

class MakePayment extends FeesPaymentEvent {
  final FeesInvoiceModel invoice;
  final String schoolCode;
  final String studentId;
  final double amountPaid;
  final String mode; // e.g. "Cash", "Online", "Card"
  final String user;
  MakePayment({
    required this.invoice,
    required this.schoolCode,
    required this.studentId,
    required this.amountPaid,
    required this.mode,
    required this.user
  });
}
