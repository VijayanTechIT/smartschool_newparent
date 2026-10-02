import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/marks_model_class.dart';
import '../helper/marksApi.dart';

// Events
abstract class MarksEvent  {
  @override
  List<Object?> get props => [];
}

class FetchMarks extends MarksEvent {
  final String examId;
  final String schoolCode;
  final String studentId;

  FetchMarks(this.examId, this.schoolCode, this.studentId);

  @override
  List<Object?> get props => [examId, schoolCode, studentId];
}



class FetchInitialMarks extends MarksEvent {

  final String schoolCode;
  final String studentId;

  FetchInitialMarks( this.schoolCode, this.studentId);

  @override
  List<Object?> get props => [schoolCode, studentId];
}

// States
abstract class MarksState {

  List<Object?> get props => [];
}

class MarksInitial extends MarksState {}

class MarksLoading extends MarksState {}

class MarksLoaded extends MarksState {
  final List<MarksModelClass> marksList;
  MarksLoaded(this.marksList);

  @override
  List<Object?> get props => [marksList];
}

class MarksError extends MarksState {}

// Bloc
class MarksBloc extends Bloc<MarksEvent, MarksState> {
  MarksBloc({List<MarksModelClass>? initialMarks})
      : super(initialMarks != null ? MarksLoaded(initialMarks) : MarksInitial()) {
    on<FetchMarks>(_onFetchMarks);
    on<FetchInitialMarks>(_onFetchInitialMarks);
  }

  Future<void> _onFetchInitialMarks(FetchInitialMarks event, Emitter<MarksState> emit) async {
    emit(MarksLoading());

    try {
      List<MarksModelClass> marksList = await MarksApi().getMarks(
         event.schoolCode, event.studentId
      );
      emit(MarksLoaded(marksList));
    } catch (e) {
      emit(MarksError());
    }
  }
  Future<void> _onFetchMarks(FetchMarks event, Emitter<MarksState> emit) async {
    emit(MarksLoading());

    try {
      List<MarksModelClass> marksList = await MarksApi().getStudentMarks(
          event.examId, event.schoolCode, event.studentId
      );
      emit(MarksLoaded(marksList));
    } catch (e) {
      emit(MarksError());
    }
  }
}
