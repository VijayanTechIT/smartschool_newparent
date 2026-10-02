class Attendance{
  final String centercode;
  final String student_id;
  final String staff_id;
  final String date;
  final String attendance_status;
  final String course;
  final String batch;

  Attendance({required this.centercode,required this.student_id,required this.staff_id,
    required this.date,required this.attendance_status,required this.course,required this.batch});

  factory Attendance.fromJson(Map<String,dynamic>json){
    return Attendance(
      centercode:json['centercode'] ,
      student_id: json['student_id'],
      staff_id:json['staff_id'] ,
      date: json['date'],
      course: json['course'],
      batch: json['batch'],
      attendance_status: json['attendance_status'],

    );
  }

  Map<String,dynamic>toJsonAdd(){
    return{
      "centercode":centercode,
      "student_id":student_id,
      "staff_id":staff_id,
      "date":date,
      "course":course,
      "batch":batch,
      "attendance_status":attendance_status,
    };
  }
}




class AttendanceWhole{
  String? id;
  String? centercode;
  String? student_id;
  String? staff_id;
  String? date;
  String? attendance_status;
  String? morning;
  String? evening;
  String? course;
  String? batch;
  String? student_codeid;
  String? student_name;


  AttendanceWhole({
    this.id,
    this.centercode,
    this.student_id,
    this.staff_id,
    this.course,
    this.student_name,
    this.batch,
    this.morning,
    this.evening,
    this.student_codeid,
    this.attendance_status,
    this.date,
  });

  factory AttendanceWhole.fromJson(Map<String, dynamic> json) {
    return AttendanceWhole(
      id: json['id'].toString(),
      centercode: json['school_code'] ?? "",
      student_id: json['student_id'] ?? "",
      staff_id: json['staff_id'] ?? "",
      date: json['date'] ?? "",
      course: json['course'] ?? "",
      morning: json['morning'] ?? "",
      evening: json['evening'] ?? "",
      batch: json['batch'] ?? "",
      student_codeid: json['student_codeid'] ?? "",
      student_name: json['student_name'] ?? "",
      attendance_status: json['attendance_status'] ?? "",
    );
  }
  Map<String,dynamic>toJsonAdd(){
    return{
      "id":id,
      "centercode":centercode,
      "student_id":student_id,
      "staff_id":staff_id,
      "date":date,
      "course":course,
      "morning":morning,
      "evening":evening,
      "batch":batch,
      "attendance_status":attendance_status,
    };
  }

  @override
  String toString() {
    return 'AttendanceWhole(id: $id, centercode: $centercode, student_id: $student_id, staff_id: $staff_id, date: $date, '
        'morning: $morning, evening: $evening, attendance_status: $attendance_status, course: $course, batch: $batch)';
  }
}