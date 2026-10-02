part of 'fees_payment_bloc.dart';


sealed class FeesPaymentState {}

final class FeesPaymentInitial extends FeesPaymentState {}
final class FeesPaymentLoading extends FeesPaymentState {}

class FeesPaymentError extends FeesPaymentState {
  final String message;
  FeesPaymentError(this.message);
}

class FeesPaymentSaving extends FeesPaymentState {
  final FeesPaymentLoaded previousState;

  FeesPaymentSaving(this.previousState);
}

class FeesPaymentLoaded extends FeesPaymentState{

  StudentWhole selectedStudent;
  List<StudentWhole> allStudents;
  List<FeesInvoiceModel> feesInvoices;
  List<FeesInvoiceModel> allFeesInvoices;
  List<FeesPayment> paymentData;
  List<StudentWhole> filteredStudents;

  FeesPaymentLoaded({
    required this.selectedStudent,
    required this.allStudents,
    required this.feesInvoices,
    required this.paymentData,
    required this.allFeesInvoices,
    required this.filteredStudents,

  });

  FeesPaymentLoaded copyWith({

    List<FeesInvoiceModel>? feesInvoices,
    List<FeesInvoiceModel>? allFeesInvoices,
    StudentWhole? selectedStudent,
    List<StudentWhole>? allStudents,
    List<FeesPayment>? paymentData,

    List<StudentWhole>? filteredStudents,

  }) {

    return FeesPaymentLoaded(
        paymentData: paymentData ?? this.paymentData,
        feesInvoices: feesInvoices ?? this.feesInvoices,
        allFeesInvoices: allFeesInvoices ?? this.allFeesInvoices,
        allStudents: allStudents ?? this.allStudents,
        selectedStudent: selectedStudent ?? this.selectedStudent,
        filteredStudents: filteredStudents ?? this.filteredStudents,

    );
  }
}