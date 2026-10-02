part of 'academic_year_bloc.dart';

sealed class AcademicYearState {}

final class AcademicYearInitial extends AcademicYearState {}



class AcademicYearLoading extends AcademicYearState {}


class AcademicYearSuccess extends AcademicYearState {
  final List<AcademicYearModel> academicYears;

  AcademicYearSuccess(this.academicYears);

  AcademicYearModel? get activeAcademicYear {
    for (var year in academicYears) {
      if (year.status == 'Active') {
        return year;
      }
    }
    return null;
  }


  List<Object> get props => [academicYears];
}



class AcademicYearFailure extends AcademicYearState {
  final String error;

  AcademicYearFailure(this.error);


  List<Object> get props => [error];
}