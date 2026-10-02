part of 'academic_year_bloc.dart';


sealed class AcademicYearEvent {}


class AddAcademicYear extends AcademicYearEvent {
  final AcademicYearModel academicYear;

  AddAcademicYear(this.academicYear);

  List<Object> get props => [academicYear];
}

class EditAcademicYear extends AcademicYearEvent {
  final AcademicYearModel academicYear;

  EditAcademicYear(this.academicYear);

  List<Object> get props => [academicYear];
}

class FetchAcademicYears extends AcademicYearEvent {
  final String schoolCode;

  FetchAcademicYears(this.schoolCode);

  List<Object> get props => [schoolCode];
}