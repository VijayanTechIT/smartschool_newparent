part of 'fees_term_bloc.dart';

@immutable
sealed class FeesTermEvent {}

class UpdateFeeTermOrder extends FeesTermEvent {
  final List<TermModel> updatedFeeTerms;
  UpdateFeeTermOrder(this.updatedFeeTerms);
}


class SaveFeeTermOrder extends FeesTermEvent {
  final List<TermModel> feeTermsToSave;
  SaveFeeTermOrder(this.feeTermsToSave);
}

class FetchFeeTerm extends FeesTermEvent{

  final String schoolCode;
  FetchFeeTerm({required this.schoolCode});
}

class AddFeeTerm extends FeesTermEvent{

  final TermModel fee;
  AddFeeTerm({required this.fee});
}


class EditFeeTerm extends FeesTermEvent {
  final TermModel feeTerm;

  EditFeeTerm(this.feeTerm);


}
