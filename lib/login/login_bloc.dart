// login_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../student/StudentModel.dart';


// Login Events
abstract class LoginEvent {
  @override
  List<Object?> get props => [];
}

class CheckLoginStatus extends LoginEvent {}

class PerformLogin extends LoginEvent {
  final StudentWhole student;
  PerformLogin(this.student);
  @override
  List<Object?> get props => [student];
}

class Logout extends LoginEvent {}

// Login States
abstract class LoginState{
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final StudentWhole student;
  LoginSuccess(this.student);
  @override
  List<Object?> get props => [student];
}

class LoginFailure extends LoginState {}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<PerformLogin>(_onPerformLogin);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckLoginStatus(
      CheckLoginStatus event, Emitter<LoginState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentDataString = prefs.getString('StudentData');
    if (studentDataString != null) {
      Map<String, dynamic> jsonData = json.decode(studentDataString);
      StudentWhole student = StudentWhole.fromJson(jsonData);
      emit(LoginSuccess(student));
    } else {
      emit(LoginFailure());
    }
  }

  Future<void> _onPerformLogin(
      PerformLogin event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      // Simulate login delay
      await Future.delayed(const Duration(seconds: 2));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('StudentData', json.encode(event.student.toJson()));
      emit(LoginSuccess(event.student));
    } catch (e) {
      emit(LoginFailure());
    }
  }

  Future<void> _onLogout(Logout event, Emitter<LoginState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('StudentData');
    emit(LoginFailure());
  }
}
