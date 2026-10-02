class StudentClassTestModel {
  final int classTestId;
  final String schoolCode;
  final String studentId;
  final String gradeId;
  final String sectionId;
  final String mark;
  final String maxMarks;
  final String academicYearId;
  final String createdBy;
  final String? updatedBy;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final DateTime testDate;
  final String subjectName;

  StudentClassTestModel({
    required this.classTestId,
    required this.schoolCode,
    required this.studentId,
    required this.gradeId,
    required this.sectionId,
    required this.mark,
    required this.maxMarks,
    required this.academicYearId,
    required this.createdBy,
    this.updatedBy,
    required this.createdOn,
    this.updatedOn,
    required this.testDate,
    required this.subjectName,
  });

  factory StudentClassTestModel.fromJson(Map<String, dynamic> json) {
    return StudentClassTestModel(
      classTestId: json['class_test_id'] as int,
      schoolCode: json['school_code'] as String,
      studentId: json['student_id'] as String,
      gradeId: json['grade_id'] as String,
      sectionId: json['section_id'] as String,
      mark: json['mark'] as String,
      maxMarks: json['max_marks'] as String,
      academicYearId: json['academic_year_id'] as String,
      createdBy: json['created_by'] as String,
      updatedBy: json['updated_by'] as String?,
      createdOn: DateTime.parse(json['created_on'] as String),
      updatedOn: json['updated_on'] != null && (json['updated_on'] as String).isNotEmpty
          ? DateTime.parse(json['updated_on'] as String)
          : null,
      testDate: DateTime.parse(json['test_date'] as String),
      subjectName: json['subject_name'] as String,
    );
  }}