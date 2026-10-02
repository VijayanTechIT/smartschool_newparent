import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/bus_master_model.dart';
import 'bus_event.dart';
import 'bus_state.dart';


class BusBloc extends Bloc<BusEvent, BusState> {
  BusBloc() : super(BusInitial()) {
    on<FetchBusById>(_onFetchBusById);
  }

  Future<void> _onFetchBusById(
      FetchBusById event, Emitter<BusState> emit) async {
    emit(BusLoading());

    // try {
      final response = await http.post(
        Uri.parse("${Constants.url}/get_bus_with_bus_id.php"),
        body: {
          "school_code": event.schoolCode,
          "bus_id": event.busId.toString(),
        },
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String,dynamic> && data.containsKey("bus_id")) {
          emit(BusLoaded(BusMaster.fromJson(data)));
        } else if (data.containsKey("message")) {
          emit(BusError(data["message"]));
        } else {
          emit(BusError("Unexpected response format"));
        }
      } else {
        emit(BusError("Server error: ${response.statusCode}"));
      }
    // } catch (e) {
    //   emit(BusError("Failed to fetch bus: $e"));
    // }
  }
}
