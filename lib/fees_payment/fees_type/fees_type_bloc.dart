import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'fee_type_model.dart';
import 'fees_type_api.dart';

part 'fees_type_event.dart';
part 'fees_type_state.dart';

class FeesTypeBloc extends Bloc<FeesTypeEvent, FeesTypeState> {
  FeesTypeBloc() : super(FeesTypeInitial()) {
    on<AddFeeType>(_onAddFeeType);
    on<EditFeeType>(_onEditFeeType);
    on<FetchFeeType>(_onFetchFeeType);
    on<UpdateFeeTypeOrder>((event, emit) {
      emit(FeesTypeSuccess(
          event.updatedFeeTypes, isChanged: true));
    });
    on<SaveFeeTypeOrder>((event, emit) async {
      try {
        if (state is FeesTypeSuccess) {
          final currentState = state as FeesTypeSuccess;

          // Emit loading state with isSubmitting = true
          emit(currentState.copyWith(isSubmitting: true));

          // Update priorities through API
          await FeesTypeApi().updateFeesTypePriorities(
              event.feeTypesToSave);

          // Emit updated list with isChanged = false and isSubmitting = false
          emit(currentState.copyWith(
            feesType: event.feeTypesToSave,
            isChanged: false,
            isSubmitting: false,
          ));
        }
      } catch (e) {
        // Optionally handle failure
        if (state is FeesTypeSuccess) {
          final currentState = state as FeesTypeSuccess;
          emit(currentState.copyWith(
            isSubmitting: false,
            isChanged: true, // remain changed since saving failed
          ));
        }
      }
    });
  }

  Future<void> _onAddFeeType(
      AddFeeType event, Emitter<FeesTypeState> emit)
  async {
    emit(FeesTypeLoading());
    try {
      final result = await FeesTypeApi().addFeesType(event.fee);

      if (result == "success") {
        add(FetchFeeType(schoolCode:event.fee.schoolCode));
      } else {
        emit(FeesTypeFailure(result));
      }
    } catch (e) {
      emit(FeesTypeFailure("An error occurred: $e"));
    }
  }

  Future<void> _onEditFeeType(
      EditFeeType event, Emitter<FeesTypeState> emit)
  async {
    emit(FeesTypeLoading());
    try {
      final result = await FeesTypeApi().editFeesType(event.feeType);
      if (result == "success") {

        add(FetchFeeType(
            schoolCode:event.feeType.schoolCode));
      } else {
        emit(FeesTypeFailure(result));
      }
    } catch (e) {
      emit(FeesTypeFailure("Failed to Load Data"));
    }
  }

  Future<void> _onFetchFeeType(
      FetchFeeType event, Emitter<FeesTypeState> emit)
  async {
    emit(FeesTypeLoading());
    // try {
    // Wrong if you want sorted history records:
    final feeTypes = await FeesTypeApi().getFeesTypeData(
        event.schoolCode);

// Sorting the type objects
    feeTypes.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

// Emitting chronicleTypes instead of actual histories
    emit(FeesTypeSuccess(feeTypes));


    // } catch (e) {
    //   emit(FeesTypeFailure("Failed to Load Data"));
    // }
  }

}
