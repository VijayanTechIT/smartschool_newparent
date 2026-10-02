part of 'fees_type_bloc.dart';

@immutable
sealed class FeesTypeEvent {}

class UpdateFeeTypeOrder extends FeesTypeEvent {
  final List<FeeCategory> updatedFeeTypes;
  UpdateFeeTypeOrder(this.updatedFeeTypes);
}


class SaveFeeTypeOrder extends FeesTypeEvent {
  final List<FeeCategory> feeTypesToSave;
  SaveFeeTypeOrder(this.feeTypesToSave);
}

class FetchFeeType extends FeesTypeEvent{

  final String schoolCode;
  FetchFeeType({required this.schoolCode});
}

class AddFeeType extends FeesTypeEvent{

  final FeeCategory fee;
  AddFeeType({required this.fee});
}


class EditFeeType extends FeesTypeEvent {
  final FeeCategory feeType;

  EditFeeType(this.feeType);


}
