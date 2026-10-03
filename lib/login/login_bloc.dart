import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      try {
        Map<String, dynamic> jsonData = json.decode(studentDataString);
        StudentWhole student = StudentWhole.fromJson(jsonData);
        await prefs.setString('schoolCode', student.schoolCode);
        await prefs.setString('studentId', student.studentId);
        try {
          await FirebaseMessaging.instance.subscribeToTopic(student.schoolCode);
          await FirebaseMessaging.instance.subscribeToTopic(student.studentId);
          debugPrint("Check status subscribed to: ${student.schoolCode}, ${student.studentId}");
        } catch (e) {
          debugPrint("Check status topic subscription error: $e");
        }
        emit(LoginSuccess(student));
      } catch (e) {
        emit(LoginFailure());
      }
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
      await prefs.setString('schoolCode', event.student.schoolCode);
      await prefs.setString('studentId', event.student.studentId);
      try {
        await FirebaseMessaging.instance.subscribeToTopic(event.student.schoolCode);
        await FirebaseMessaging.instance.subscribeToTopic(event.student.studentId);
        debugPrint("Login subscribed to: ${event.student.schoolCode}, ${event.student.studentId}");
      } catch (e) {
        debugPrint("Login topic subscription error: $e");
      }
      emit(LoginSuccess(event.student));
    } catch (e) {
      emit(LoginFailure());
    }
  }

  Future<void> _onLogout(Logout event, Emitter<LoginState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? schoolCode = prefs.getString('schoolCode');
    String? studentId = prefs.getString('studentId');
    if (schoolCode != null) {
      try { await FirebaseMessaging.instance.unsubscribeFromTopic(schoolCode); } catch (_) {}
    }
    if (studentId != null) {
      try { await FirebaseMessaging.instance.unsubscribeFromTopic(studentId); } catch (_) {}
    }
    await prefs.remove('StudentData');
    await prefs.remove('schoolCode');
    await prefs.remove('studentId');
    emit(LoginFailure());
  }
}
