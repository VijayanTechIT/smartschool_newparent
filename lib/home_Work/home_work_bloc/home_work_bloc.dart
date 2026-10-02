import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:smart_school_parent/constants.dart';

part 'home_work_event.dart';
part 'home_work_state.dart';

class HomeWorkBloc extends Bloc<HomeWorkEvent, HomeWorkState> {
  HomeWorkBloc() : super(HomeWorkLoading()) {
    on<FetchHomework>(_onFetchHomework);
  }

  Future<void> _onFetchHomework(FetchHomework event, Emitter<HomeWorkState> emit) async {
    emit(HomeWorkLoading());

    final url = Uri.parse("${Constants.url}/get_homework.php");
    try {
      final response = await http.post(
        url,
        body: {
          "grade_name": event.gradeName,
          "section_name": event.sectionName,
          "school_code": event.schoolCode,
        },
      );

      print("Grade: ${event.gradeName}  Section: ${event.sectionName}");
      print("Home Work Repsonse: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          emit(HomeWorkLoaded(jsonResponse['homeworks']));
        } else {
          emit(HomeWorkError(jsonResponse['message']));
        }
      } else {
        emit(HomeWorkError("Server error"));
      }
    } catch (e) {
      emit(HomeWorkError("Failed to fetch homework"));
    }
  }


}
