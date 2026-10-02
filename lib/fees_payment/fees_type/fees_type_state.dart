part of 'fees_type_bloc.dart';

@immutable
sealed class FeesTypeState {}

final class FeesTypeInitial extends FeesTypeState {}




class FeesTypeLoading extends FeesTypeState {}


class FeesTypeSuccess extends FeesTypeState {
  final List<FeeCategory> feesType;
  final bool isChanged;
  final bool isSaved;
  final bool isSubmitting;
  FeesTypeSuccess(this.feesType,{
    this.isChanged = false,
    this.isSaved = false,
    this.isSubmitting = false});


  FeesTypeSuccess copyWith({
    List<FeeCategory>? feesType,
    bool? isChanged,
    bool? isSubmitting,
    bool? isSaved,
  }) {
    return FeesTypeSuccess(
      feesType ?? this.feesType,
      isChanged: isChanged ?? this.isChanged,
      isSubmitting:isSubmitting ??  this.isSubmitting,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  List<Object> get props => [feesType];
}



class FeesTypeFailure extends FeesTypeState {
  final String error;

  FeesTypeFailure(this.error);


  List<Object> get props => [error];
}