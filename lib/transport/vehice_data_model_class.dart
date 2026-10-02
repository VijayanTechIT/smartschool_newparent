class VehicleData {
  final double latitude;
  final double longitude;
  final double speed;
  final int date; // Unix timestamp in milliseconds
  final String isoDate;
  final double odoDistance;
  final String ignitionStatus;
  final String status;
  final String vehicleStatus;
  final String address;
  final String regNo;
  final String vehicleType;
  final String vehicleId;
  final String deviceId;
  final String expiryDate;
  final String onboardDate;
  final double fuelLitre;
  final double bearing;
  final int serverTime;
  final String insideGeoFence;
  final List<String> triggeredGeoFences;
  final int rowId;

  VehicleData({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.date,
    required this.isoDate,
    required this.odoDistance,
    required this.ignitionStatus,
    required this.status,
    required this.vehicleStatus,
    required this.address,
    required this.regNo,
    required this.vehicleType,
    required this.vehicleId,
    required this.deviceId,
    required this.expiryDate,
    required this.onboardDate,
    required this.fuelLitre,
    required this.bearing,
    required this.serverTime,
    required this.insideGeoFence,
    required this.triggeredGeoFences,
    required this.rowId,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      speed: (json['speed'] ?? 0).toDouble(),
      date: json['date'] ?? 0,
      isoDate: json['isoDate'] ?? '',
      odoDistance: (json['odoDistance'] ?? 0).toDouble(),
      ignitionStatus: json['ignitionStatus'] ?? '',
      status: json['status'] ?? '',
      vehicleStatus: json['vehicleStatus'] ?? '',
      address: json['address'] ?? '',
      regNo: json['regNo'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      onboardDate: json['onboardDate'] ?? '',
      fuelLitre: (json['fuelLitre'] ?? 0).toDouble(),
      bearing: (json['bearing'] ?? 0).toDouble(),
      serverTime: json['serverTime'] ?? 0,
      insideGeoFence: json['insideGeoFence'] ?? '',
      triggeredGeoFences: List<String>.from(json['triggeredGeoFences'] ?? []),
      rowId: json['rowId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'date': date,
      'isoDate': isoDate,
      'odoDistance': odoDistance,
      'ignitionStatus': ignitionStatus,
      'status': status,
      'vehicleStatus': vehicleStatus,
      'address': address,
      'regNo': regNo,
      'vehicleType': vehicleType,
      'vehicleId': vehicleId,
      'deviceId': deviceId,
      'expiryDate': expiryDate,
      'onboardDate': onboardDate,
      'fuelLitre': fuelLitre,
      'bearing': bearing,
      'serverTime': serverTime,
      'insideGeoFence': insideGeoFence,
      'triggeredGeoFences': triggeredGeoFences,
      'rowId': rowId,
    };
  }
}
