import 'package:flutter_bloc/flutter_bloc.dart';
import 'academic_api.dart';

import '../../models/academic_year_model.dart';

part 'academic_year_event.dart';
part 'academic_year_state.dart';

class AcademicYearBloc extends Bloc<AcademicYearEvent, AcademicYearState> {
  AcademicYearBloc() : super(AcademicYearInitial()) {
    on<AddAcademicYear>(_onAddAcademicYear);
    on<EditAcademicYear>(_onEditAcademicYear);
    on<FetchAcademicYears>(_onFetchAcademicYears);
  }

  Future<void> _onAddAcademicYear(
      AddAcademicYear event, Emitter<AcademicYearState> emit) async {
    emit(AcademicYearLoading());
    try {
      final result = await AcademicApi().addAcademicYear(event.academicYear);

      if (result == "success") {
        add(FetchAcademicYears(event.academicYear.schoolCode));
      } else {
        emit(AcademicYearFailure(result));
      }
    } catch (e) {
      emit(AcademicYearFailure("An error occurred: $e"));
    }
  }

  Future<void> _onEditAcademicYear(
      EditAcademicYear event, Emitter<AcademicYearState> emit) async {
    emit(AcademicYearLoading());
    try {
      final result = await AcademicApi().editAcademicYear(event.academicYear);
      if (result == "success") {

        add(FetchAcademicYears(event.academicYear.schoolCode));
      } else {
        emit(AcademicYearFailure(result));
      }
    } catch (e) {
      emit(AcademicYearFailure("Failed to Load Data"));
    }
  }

  Future<void> _onFetchAcademicYears(
      FetchAcademicYears event, Emitter<AcademicYearState> emit) async {
    print("📩 FetchAcademicYears received with code: ${event.schoolCode}");
    emit(AcademicYearLoading());
    try {
      final academicYears =
      await AcademicApi().getAcademicYearData(event.schoolCode);
      emit(AcademicYearSuccess(academicYears));
    } catch (e) {
      emit(AcademicYearFailure("Failed to Load Data"));
    }
  }
}
