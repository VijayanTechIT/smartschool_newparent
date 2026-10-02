
class ExamsModelClass{
  String? examId;
  String schoolCode;
  final String examName;
  String? status;


  ExamsModelClass({
    this.examId,
    required this.schoolCode,
    required this.examName,
    this.status

  });
  factory ExamsModelClass.fromJson(Map<String, dynamic> json) {
    return ExamsModelClass(
        examId: json['exam_id'].toString(),
        schoolCode: json['school_code'] ?? "",
        examName: json['exam_name'] ?? "",
        status: json['status'] ?? ""
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'school_code': schoolCode,
      'exam_name': examName,
      'status':'Active'
    };
  }
  Map<String, dynamic> toJsonUpdate() {
    return {
      'exam_id':examId,
      'school_code': schoolCode,
      'exam_name': examName,
      'status':status
    };
  }

}


