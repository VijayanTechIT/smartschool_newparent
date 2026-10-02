



import '../models/bus_master_model.dart';

class BusState{
}

class BusInitial extends BusState {}

class BusLoading extends BusState {}

class BusLoaded extends BusState {
  final BusMaster bus;

  BusLoaded(this.bus);

  List<Object?> get props => [bus];
}

class BusError extends BusState {
  final String message;

  BusError(this.message);

  List<Object?> get props => [message];
}
