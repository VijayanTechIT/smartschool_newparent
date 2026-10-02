part of 'fees_scholarship_list_bloc.dart';

@immutable
sealed class FeesScholarshipListEvent {}

class FetchStudentScholarship extends FeesScholarshipListEvent{

  final String schoolCode;
  FetchStudentScholarship({required this.schoolCode});
}




