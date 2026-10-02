class AcademicYearModel{
  String? id;
  String schoolCode;
  final String academicYear;
  String? status;
  String? createdOn;
  String? createdBy;
  String? updatedBy;
  String? updatedOn;


  AcademicYearModel({
    this.id,
    required this.schoolCode,
    required this.academicYear,
    this.status,
    this.createdBy,
    this.createdOn,
    this.updatedOn,
    this.updatedBy

  });
  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id'].toString(),
      schoolCode: json['school_code'] ?? "",
      academicYear: json['academic_year'] ?? "",
      status: json['status'] ?? "",
        createdBy: json['created_by'] ?? "",
        createdOn: json['created_on'] ?? "",
        updatedBy: json['updated_by'] ?? "",
        updatedOn: json['updated_on'] ?? ""
    );
  }


  Map<String, dynamic> toJson() {
    return {

      'school_code': schoolCode,
      'academic_year': academicYear,
      'status':'Inactive',
      'created_by':createdBy
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'id' :id,
      'school_code': schoolCode,
      'academic_year': academicYear,
      'status':status,
      'updated_by':updatedBy
    };
  }


}