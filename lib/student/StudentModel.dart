class StudentWhole {
  final String id;
  final String studentId;
  final String emisNumber;
  final String schoolCode;
  final String name;
  final String fatherName;
  final String motherName;
  final String fatherOccupation;
  final String motherOccupation;
  final String dob;
  final String dateOfJoining;
  final String joiningGrade;
  final String studyingGrade;
  final String studyingSection;
  final String phoneNumber;
  final String whatsappNo;
  final String bloodGroup;
  final String aadharNo;
  final String email;
  final String address;
  final String previousSchool;
  final String status;
  final String aadharPhoto;
  final String photo;
  final String remarks;
  final String identificationMarks;
  final String siblingId;
  final String siblingRelationship;
  final String transport;
  final String routeName;
  final String stageName;
  final String schoolName;
  final String schoolAddress;

  StudentWhole({
    required this.id,
    required this.studentId,
    required this.emisNumber,
    required this.schoolCode,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.fatherOccupation,
    required this.motherOccupation,
    required this.dob,
    required this.dateOfJoining,
    required this.joiningGrade,
    required this.studyingGrade,
    required this.studyingSection,
    required this.phoneNumber,
    required this.whatsappNo,
    required this.bloodGroup,
    required this.aadharNo,
    required this.email,
    required this.address,
    required this.previousSchool,
    required this.status,
    required this.aadharPhoto,
    required this.photo,
    required this.remarks,
    required this.identificationMarks,
    required this.siblingId,
    required this.siblingRelationship,
    required this.transport,
    required this.stageName,
    required this.routeName,
    required this.schoolAddress,
    required this.schoolName
  });

  factory StudentWhole.fromJson(Map<String, dynamic> json) {

    print("School Name : ${json['school_name']
        ?? 'dddd'}  ===  ${json['school_address'] ?? 'kkk' } ");

    return StudentWhole(
      id: json['id'].toString(),
      studentId: json['student_id'] ?? '',
      emisNumber: json['emis_number'] ?? '',
      schoolCode: json['school_code'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      fatherOccupation: json['father_occupation'] ?? '',
      motherOccupation: json['mother_occupation'] ?? '',
      dob: json['dob'] ?? '',
      dateOfJoining: json['date_of_joining'] ?? '',
      joiningGrade: json['joining_grade'] ?? '',
      studyingGrade: json['studying_grade'] ?? '',
      studyingSection: json['studying_section'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      whatsappNo: json['whatsappno'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      aadharNo: json['aadhar_no'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      previousSchool: json['previous_school'] ?? '',
      status: json['status'] ?? '',
      aadharPhoto: json['aadhar_photo'] ?? '',
      photo: json['photo'] ?? '',
      remarks: json['remarks'] ?? '',
      identificationMarks: json['identification_marks'] ?? '',
      siblingId: json['sibling_id'] ?? '',
      siblingRelationship: json['sibling_relationship'] ?? '',
      transport: json['bus_id'].toString(),
      routeName: json['route_name'] ?? '',
      stageName: json['stage_name'] ?? '',
      schoolName: json['school_name'] ?? '',
      schoolAddress: json['school_address'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'emis_number': emisNumber,
      'school_code': schoolCode,
      'name': name,
      'father_name': fatherName,
      'mother_name': motherName,
      'father_occupation': fatherOccupation,
      'mother_occupation': motherOccupation,
      'dob': dob,
      'date_of_joining': dateOfJoining,
      'joining_grade': joiningGrade,
      'studying_grade': studyingGrade,
      'studying_section': studyingSection,
      'phone_number': phoneNumber,
      'whatsappno': whatsappNo,
      'blood_group': bloodGroup,
      'aadhar_no': aadharNo,
      'email': email,
      'address': address,
      'previous_school': previousSchool,
      'status': status,
      'aadhar_photo': aadharPhoto,
      'photo': photo,
      'remarks': remarks,
      'identification_marks': identificationMarks,
      'sibling_id': siblingId,
      'sibling_relationship': siblingRelationship,
      'transport':transport,
      'stage_name':stageName,
      'route_name':routeName
    };
  }
}



extension StudentWholeCopy on StudentWhole {
  StudentWhole copyWithPhoto(String newPhoto) {
    return StudentWhole(
      id: id,
      studentId: studentId,
      emisNumber: emisNumber,
      schoolCode: schoolCode,
      name: name,
      fatherName: fatherName,
      motherName: motherName,
      fatherOccupation: fatherOccupation,
      motherOccupation: motherOccupation,
      dob: dob,
      dateOfJoining: dateOfJoining,
      joiningGrade: joiningGrade,
      studyingGrade: studyingGrade,
      studyingSection: studyingSection,
      phoneNumber: phoneNumber,
      whatsappNo: whatsappNo,
      bloodGroup: bloodGroup,
      aadharNo: aadharNo,
      email: email,
      address: address,
      previousSchool: previousSchool,
      status: status,
      aadharPhoto: aadharPhoto,
      photo: newPhoto,
      remarks: remarks,
      identificationMarks: identificationMarks,
      siblingId: siblingId,
      siblingRelationship: siblingRelationship,
      transport: transport,
      routeName: routeName,
      stageName: stageName,
      schoolName: schoolName,
      schoolAddress: schoolAddress
    );
  }
}
