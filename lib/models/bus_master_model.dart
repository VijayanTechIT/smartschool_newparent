class BusMaster {
  final int? busId; // Nullable for creation (auto-increment)
  final String schoolCode;
  final String busNo;
  String? photo;
  final String busRegisterNumber;
  final String modelName;
  final String yearOfMake;
  final String brandName;
  final String engineNumber;
  final String seatingCapacity;
  final String chaseNumber;
  final String gpsLocation;
  final String createdBy;
  final String createdOn;
  final String updatedBy;
  final String updatedOn;
  String? status;

  BusMaster({
    this.busId,
    this.photo,
    this.status,
    required this.schoolCode,
    required this.busNo,
    required this.busRegisterNumber,
    required this.modelName,
    required this.yearOfMake,
    required this.brandName,
    required this.engineNumber,
    required this.seatingCapacity,
    required this.chaseNumber,
    required this.gpsLocation,
    required this.createdBy,
    required this.createdOn,
    required this.updatedBy,
    required this.updatedOn,
  });

  factory BusMaster.fromJson(Map<String, dynamic> json) {
    return BusMaster(
        busId: json['bus_id'],
        schoolCode: json['school_code'],
        busNo: json['bus_no'],
        busRegisterNumber: json['bus_register_number'],
        modelName: json['model_name'],
        yearOfMake: json['year_of_make'],
        brandName: json['brand'],
        engineNumber: json['engine_no'],
        seatingCapacity: json['seating_capacity'],
        chaseNumber: json['chase_no'],
        gpsLocation: json['gps_location'],
        createdBy: json['created_by'],
        createdOn: json['created_on'],
        updatedBy: json['updated_by'],
        updatedOn: json['updated_on'],
        photo: json['photo'],
        status:json['status']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'school_code': schoolCode,
      'bus_no': busNo,
      'bus_register_number': busRegisterNumber,
      'driver_name': modelName,
      'driver_contact': yearOfMake,
      'helper_name': brandName,
      'helper_number': engineNumber,
      'gps_location':gpsLocation,
      'seating_capacity': seatingCapacity,
      'no_of_trip': chaseNumber,
      'status':'Active',
      'created_by': createdBy,
      'created_on': createdOn,
      'updated_by': updatedBy,
      'updated_on': updatedOn,
    };
  }
}