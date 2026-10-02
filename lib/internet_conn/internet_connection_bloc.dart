import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

part 'internet_connection_event.dart';
part 'internet_connection_state.dart';

/// [InternetConnectionBloc] monitors the internet connection status.
/// It listens to [Connectivity] changes and emits appropriate states.
class InternetConnectionBloc extends Bloc<InternetConnectionEvent, InternetConnectionState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  /// Initializes the [InternetConnectionBloc] and starts listening to connectivity changes.
  InternetConnectionBloc() : super(InternetConnectionInitial()) {
    // Handle connection state change event
    on<InternetConnectionChanged>((InternetConnectionChanged event, Emitter<InternetConnectionState> emit) {
      if (event.connectivityResult == ConnectivityResult.none) {
        emit(InternetDisconnected());
      } else {
        emit(InternetConnected());
      }
    });

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      add(InternetConnectionChanged(result));
    });
  }

  /// Cancels the connectivity subscription when the bloc is closed.
  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

