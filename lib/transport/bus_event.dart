

abstract class BusEvent {
    List<Object?> get props => [];
}

class FetchBusById extends BusEvent {
  final String schoolCode;
  final int busId;

  FetchBusById(this.schoolCode, this.busId);

  @override
  List<Object?> get props => [schoolCode, busId];
}
