part of 'fees_term_bloc.dart';

@immutable
sealed class FeesTermState {}

final class FeesTermInitial extends FeesTermState {}

class FeesTermLoading extends FeesTermState {}


class FeesTermSuccess extends FeesTermState {
  final List<TermModel> feesTerm;
  final bool isChanged;
  final bool isSaved;
  final bool isSubmitting;
  FeesTermSuccess(this.feesTerm,{
    this.isChanged = false,
    this.isSaved = false,
    this.isSubmitting = false});


  FeesTermSuccess copyWith({
    List<TermModel>? feesTerm,
    bool? isChanged,
    bool? isSubmitting,
    bool? isSaved,
  }) {
    return FeesTermSuccess(
      feesTerm ?? this.feesTerm,
      isChanged: isChanged ?? this.isChanged,
      isSubmitting:isSubmitting ??  this.isSubmitting,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  List<Object> get props => [feesTerm];
}



class FeesTermFailure extends FeesTermState {
  final String error;

  FeesTermFailure(this.error);


  List<Object> get props => [error];
}