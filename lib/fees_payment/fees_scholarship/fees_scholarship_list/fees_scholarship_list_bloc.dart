import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_school_parent/helper/studentapi.dart';

import '../../../student/StudentModel.dart';
import '../../../student/studentapi.dart';
import '../fees_scholarship_api.dart';
import '../fees_scholarship_model.dart';

part 'fees_scholarship_list_event.dart';
part 'fees_scholarship_list_state.dart';

class FeesScholarshipListBloc extends Bloc<FeesScholarshipListEvent,
    FeesScholarshipListState> {
  FeesScholarshipListBloc() : super(FeesScholarshipListInitial()) {
    on<FetchStudentScholarship>(_onFetchStudentScholarship);
  }

  Future<void> _onFetchStudentScholarship(FetchStudentScholarship event,
      Emitter<FeesScholarshipListState> emit) async {
    emit(FeesScholarshipListLoading());
    // try {
    // Wrong if you want sorted history records:
    final scholarships = await StudentScholarshipApi()
        .getScholarshipTypeData(event.schoolCode);

    // Run all requests in parallel
    final results = await Future.wait([
      StudentRecord().getAllStudent(event.schoolCode),

    ]);

    // De structure results

    final studentList = (results[0])
        .where((s) => s.status.toLowerCase() == "active")
        .toList();


    print("Schoilarships fetched: ${scholarships.length}");

    // Emitting chronicleTypes instead of actual histories
    emit(FeesScholarshipListSuccess(scholarships,

        studentList: studentList));
  }


}