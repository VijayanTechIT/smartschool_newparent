part of 'internet_connection_bloc.dart';

/// Base class for all internet connection states.
abstract class InternetConnectionState{}


/// Initial state when the internet connection status is unknown.
class InternetConnectionInitial extends InternetConnectionState {}

/// State representing that the internet is connected.
class InternetConnected extends InternetConnectionState {}

/// State representing that the internet is disconnected.
class InternetDisconnected extends InternetConnectionState {}
