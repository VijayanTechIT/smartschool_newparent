import 'package:flutter_bloc/flutter_bloc.dart';
import '../student/StudentModel.dart';
import 'fees_invoice_api.dart';
import 'fees_invoice_model.dart';
import 'fees_payment_model.dart';

part 'fees_payment_event.dart';
part 'fees_payment_state.dart';

class FeesPaymentBloc extends Bloc<FeesPaymentEvent, FeesPaymentState> {
  FeesPaymentBloc() : super(FeesPaymentInitial()) {
    on<LoadInitialFeesPaymentData>(_onLoadInitialFeesPaymentData);
    on<MakePayment>((event, emit) async {

      if (state is FeesPaymentLoaded) {
        final currentState = state as FeesPaymentLoaded;

        emit(FeesPaymentSaving(currentState));

        try {
          final updatedInvoice = event.invoice; // Already has correct details


          if (updatedInvoice.details != null && updatedInvoice.details!.isNotEmpty) {
            for (final detail in updatedInvoice.details!) {
            }
          }

          // ✅ Submit to API
          await FeeRepository().makePayment(
            schoolCode: event.schoolCode,
            invoiceId: updatedInvoice.invoiceId ?? 0,
            paymentDate: DateTime.now(),
            amountPaid: event.amountPaid,
            modeOfPayment: event.mode,
            referenceNo: '',
            remarks: '',
            createdBy: event.user,
            feesInvoice: updatedInvoice,
          );





          final results = await Future.wait([

            FeeRepository().getFeesInvoiceData(
                event.schoolCode,event.studentId),

          ]);

          final invoices = results[0];
          final studentOutstandingInvoices = invoices
              .where((i) =>
          i.studentId.toString() ==
              currentState.selectedStudent!.id.toString())
              .where((i) => i.balanceAmount > 0)
              .toList();


          emit(FeesPaymentLoaded(
              selectedStudent: currentState.selectedStudent,
              allStudents: currentState.allStudents,
              feesInvoices: studentOutstandingInvoices,
              paymentData: invoices.first.paymentsAgainstInvoice ?? [],
              allFeesInvoices: invoices,
              filteredStudents: currentState.filteredStudents,
         )

          );

        } catch (e, stack) {
          emit(FeesPaymentError("Payment failed: $e"));
        }
      }
    });
  }


  Future<void> _onLoadInitialFeesPaymentData(
      LoadInitialFeesPaymentData event,
      Emitter<FeesPaymentState> emit,
      )
  async {

    print("Load initialised  ${event.studentId} - ${event.schoolCode}");
    emit(FeesPaymentLoading());

    final results = await Future.wait([
      FeeRepository().getFeesInvoiceData(event.schoolCode,
          event.studentId
      ),
      FeeRepository().getFeesPaymentData(event.schoolCode,event.studentId),
    ]);

    // --- Added print statement here ---
    print("Fees Invoice Data fetched successfully. ${results[1]}");
    // ----------------------------------


    emit(FeesPaymentLoaded(
      paymentData: results[1] as List<FeesPayment>,
      selectedStudent: event.student,
      allStudents: [],
      filteredStudents: [],
      allFeesInvoices: [],
      feesInvoices: results[0] as List<FeesInvoiceModel>,
    ));
  }
}
