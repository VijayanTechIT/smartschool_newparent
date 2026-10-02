part of 'home_work_bloc.dart';

sealed class HomeWorkEvent {}


class FetchHomework extends HomeWorkEvent{
  final String schoolCode;
  final String sectionName;
  final String gradeName;

  FetchHomework({required this.schoolCode,
    required this.sectionName,required this.gradeName});
}