part of 'home_work_bloc.dart';


sealed class HomeWorkState {}



class HomeWorkLoading extends HomeWorkState {}

class HomeWorkLoaded extends HomeWorkState {
  final List<dynamic> homeworks; // Replace dynamic with a model class if needed

  HomeWorkLoaded(this.homeworks);
}

class HomeWorkError extends HomeWorkState {
  final String message;

  HomeWorkError(this.message);
}
