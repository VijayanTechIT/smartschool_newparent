
class MarksModelClass{
  String? markId;
  String schoolCode;
  final String studentId;
  final String examId;
  final String subjectId;
  final String gradeId;
  final String section;
  final String mark;
  final String maxMarks;
  final String academicYearId;
  final String? examName;
  String? enteredBy;
  final String examDate;
  DateTime? enteredDate;
  DateTime? updatedDate;
  String? updatedBy;

  MarksModelClass({
    this.markId,
    required this.schoolCode,
    required this.studentId,
    required this.subjectId,
    required this.examId,
    required this.mark,
    required this.gradeId,
    required this.section,
    required this.maxMarks,
    required this.academicYearId,
    this.enteredBy,
    this.enteredDate,
    this.updatedBy,
    this.updatedDate,
    required this.examDate,
    this.examName,

  });
  factory MarksModelClass.fromJson(Map<String, dynamic> json) {
    return MarksModelClass(
      markId: json['mark_id'].toString(),
      schoolCode: json['school_code'] ?? "",
      studentId: json['student_id'] ?? "",
      subjectId: json['subject_name'] ?? "",
      examId: json['exam_id'] ?? "",
      examName: json['exam_name'] ?? "",
      mark: json['mark'] ?? "",
      gradeId: json['grade_id'] ?? "",
      section: json['section'] ?? "",
      maxMarks: json['max_marks'] ?? "",
      academicYearId: json["academic_year_id"] ?? "",
      enteredBy: json["entered_by"] ?? "",
      examDate:  json["exam_date"] ?? "",
      updatedBy: json["updated_by"] ?? "",
      enteredDate: json["entered_date"] != null
          ? DateTime.tryParse(json["entered_date"])
          : null,
      updatedDate: json["updated_date"] != null
          ? DateTime.tryParse(json["updated_date"])
          : null,

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'mark_id': markId,
      'school_code': schoolCode,
      'student_id': studentId,
      'exam_id':examId,
      'subject_id':subjectId,
      'mark':mark,
      'grade_id':gradeId,
      'section':section,
      'max_marks':maxMarks,
      'academic_year_id':academicYearId,
      'entered_by':enteredBy,
      'exam_date':examDate,
      'updated_by':enteredBy,

      'updated_date':enteredDate?.toIso8601String(),
      'entered_date':enteredDate?.toIso8601String()
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'mark_id': markId,
      'school_code': schoolCode,
      'student_id': studentId,
      'exam_id':examId,
      'subject_id':subjectId,
      'mark':mark,
      'grade_id':gradeId,
      'section':section,
      'max_marks':maxMarks,
      'academic_year_id':academicYearId,
      'updated_by':enteredBy,
      'exam_date':examDate,
      'updated_date':enteredDate?.toIso8601String()
    };
  }


}