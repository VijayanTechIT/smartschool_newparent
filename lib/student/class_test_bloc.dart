import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../models/student_class_test_model.dart';

// Events
abstract class StClassTestEvent  {

  List<Object?> get props => [];
}

class FetchStClassTest extends StClassTestEvent {

  final String schoolCode;
  final String studentId;

  FetchStClassTest( this.schoolCode, this.studentId);

  @override
  List<Object?> get props => [ schoolCode, studentId];
}



// States
abstract class StClassTestState {

  List<Object?> get props => [];
}

class StClassTestInitial extends StClassTestState {}

class StClassTestLoading extends StClassTestState {}

class StClassTestLoaded extends StClassTestState {
  final List<StudentClassTestModel> classTestList;
  StClassTestLoaded(this.classTestList);

  @override
  List<Object?> get props => [classTestList];
}

class StClassTestError extends StClassTestState {}

// Bloc
class StClassTestBloc extends Bloc<StClassTestEvent, StClassTestState> {
  StClassTestBloc({List<StudentClassTestModel>? initialClassTest})
      : super(initialClassTest != null ? StClassTestLoaded(initialClassTest) : StClassTestInitial()) {
    on<FetchStClassTest>(_onFetchStClassTest);

  }


  Future<void> _onFetchStClassTest(FetchStClassTest event, Emitter<StClassTestState> emit) async {
    emit(StClassTestLoading());

    try {
      List<StudentClassTestModel> classTestList = await ClassTestApi().getClassTest(
          event.schoolCode, event.studentId
      );
      print("Class Test Received : ${classTestList}");
      emit(StClassTestLoaded(classTestList));
    } catch (e) {
      emit(StClassTestError());
    }
  }
}


class ClassTestApi{

  var url = Constants.url;

  Future<List<StudentClassTestModel>> getClassTest(String centerCode,String studentId) async {
    var getpayurl = "$url/getClassTestStudent.php";
    final response = await http.post(Uri.parse(getpayurl), body: {
      "school_code": centerCode,
      "student_id": studentId,
    },
    );
    print("Response BOdy:${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      var dataJson = json.decode(response.body);
      List<StudentClassTestModel> datalist = [];
      print("Response BOdy: ${response.body}");
      try {
        for (var datasjson in dataJson) {
          datalist.add(StudentClassTestModel.fromJson(datasjson));
        }
      } catch (e) {
        datalist.clear();
      }
      return datalist;
    } else {
      return <StudentClassTestModel>[];
    }
  }

}
