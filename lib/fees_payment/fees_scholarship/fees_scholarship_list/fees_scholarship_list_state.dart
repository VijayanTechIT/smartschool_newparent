part of 'fees_scholarship_list_bloc.dart';

@immutable
sealed class FeesScholarshipListState {}

final class FeesScholarshipListInitial extends FeesScholarshipListState {}


class FeesScholarshipListLoading extends FeesScholarshipListState {}


class FeesScholarshipListSuccess extends FeesScholarshipListState {
  final List<StudentScholarship> scholarships;
  final List<StudentWhole> studentList;
  final bool isChanged;
  final bool isSaved;
  final bool isSubmitting;
  FeesScholarshipListSuccess(this.scholarships,{
    this.studentList = const [],
    this.isChanged = false,
    this.isSaved = false,
    this.isSubmitting = false});


  FeesScholarshipListSuccess copyWith({
    List<StudentScholarship>? scholarships,
    List<StudentWhole>? studentList,
    bool? isChanged,
    bool? isSubmitting,
    bool? isSaved,
  }) {
    return FeesScholarshipListSuccess(
      scholarships ?? this.scholarships,
      studentList: studentList ?? this.studentList,
      isChanged: isChanged ?? this.isChanged,
      isSubmitting:isSubmitting ??  this.isSubmitting,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  List<Object> get props => [scholarships];
}



class FeesScholarshipFailure extends FeesScholarshipListState {
  final String error;

  FeesScholarshipFailure(this.error);


  List<Object> get props => [error];
}