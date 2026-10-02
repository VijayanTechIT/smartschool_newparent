import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'fees_term_api.dart';
import 'fees_term_model.dart';

part 'fees_term_event.dart';
part 'fees_term_state.dart';

class FeesTermBloc extends Bloc<FeesTermEvent, FeesTermState> {
  FeesTermBloc() : super(FeesTermInitial()) {
    on<AddFeeTerm>(_onAddFeeTerm);
    on<EditFeeTerm>(_onEditFeeTerm);
    on<FetchFeeTerm>(_onFetchFeeTerm);
    on<UpdateFeeTermOrder>((event, emit) {
      emit(FeesTermSuccess(
          event.updatedFeeTerms, isChanged: true));
    });
    on<SaveFeeTermOrder>((event, emit) async {
      try {
        if (state is FeesTermSuccess) {
          final currentState = state as FeesTermSuccess;

          // Emit loading state with isSubmitting = true
          emit(currentState.copyWith(isSubmitting: true));

          // Update priorities through API
          await FeesTermApi().updateFeesTermPriorities(
              event.feeTermsToSave);

          // Emit updated list with isChanged = false and isSubmitting = false
          emit(currentState.copyWith(
            feesTerm: event.feeTermsToSave,
            isChanged: false,
            isSubmitting: false,
          ));
        }
      } catch (e) {
        // Optionally handle failure
        if (state is FeesTermSuccess) {
          final currentState = state as FeesTermSuccess;
          emit(currentState.copyWith(
            isSubmitting: false,
            isChanged: true, // remain changed since saving failed
          ));
        }
      }
    });
  }

  Future<void> _onAddFeeTerm(
      AddFeeTerm event, Emitter<FeesTermState> emit)
  async {
    emit(FeesTermLoading());
    try {
      final result = await FeesTermApi().addFeesTerm(event.fee);

      if (result == "success") {
        add(FetchFeeTerm(schoolCode:event.fee.schoolCode));
      } else {
        emit(FeesTermFailure(result));
      }
    } catch (e) {
      emit(FeesTermFailure("An error occurred: $e"));
    }
  }

  Future<void> _onEditFeeTerm(
      EditFeeTerm event, Emitter<FeesTermState> emit)
  async {
    emit(FeesTermLoading());
    try {
      final result = await FeesTermApi().editFeesTerm(event.feeTerm);
      if (result == "success") {

        add(FetchFeeTerm(
            schoolCode:event.feeTerm.schoolCode));
      } else {
        emit(FeesTermFailure(result));
      }
    } catch (e) {
      emit(FeesTermFailure("Failed to Load Data"));
    }
  }

  Future<void> _onFetchFeeTerm(
      FetchFeeTerm event, Emitter<FeesTermState> emit)
  async {
    emit(FeesTermLoading());
    // try {
    // Wrong if you want sorted history records:
    final feeTerms = await FeesTermApi().getFeesTermData(
        event.schoolCode);

// Sorting the Term objects
    feeTerms.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

// Emitting chronicleTerms instead of actual histories
    emit(FeesTermSuccess(feeTerms));


    // } catch (e) {
    //   emit(FeesTermFailure("Failed to Load Data"));
    // }
  }

}
