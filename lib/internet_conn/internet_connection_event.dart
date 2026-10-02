part of 'internet_connection_bloc.dart';

/// Base class for all internet connection events.
abstract class InternetConnectionEvent{
  /// constructor for internet connection event
  const InternetConnectionEvent();

  /// props for internet connection if any
  List<Object> get props => <Object>[];
}

/// [InternetConnectionChanged] is emitted when the internet connection status changes.
class InternetConnectionChanged extends InternetConnectionEvent {
  /// The [connectivityResult] represents the current network status.
  final ConnectivityResult connectivityResult;

  /// Constructor for [InternetConnectionChanged].
  const InternetConnectionChanged(this.connectivityResult);

  @override
  List<Object> get props => <Object>[connectivityResult];
}
