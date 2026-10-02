class ParentSettingsModel {
  final int? id;
  final String schoolCode;

  final String notification;
  final int notificationPriority;

  final String marks;
  final int marksPriority;

  final String attendance;
  final int attendancePriority;

  final String transport;
  final int transportPriority;

  final String classTest;
  final int classTestPriority;

  final String feesPayment;
  final int feesPaymentPriority;

  final String homework;
  final int homeworkPriority;

  final String myAchievements;
  final int myAchievementsPriority;


  final DateTime? createdOn;
  final String createdBy;

  final String payButtonShow;

  final DateTime? updatedOn;
  final String updatedBy;

  ParentSettingsModel({
    this.id,
    required this.schoolCode,
    required this.notification,
    required this.notificationPriority,
    required this.marks,
    required this.marksPriority,
    required this.attendance,
    required this.attendancePriority,
    required this.transport,
    required this.transportPriority,
    required this.classTest,
    required this.classTestPriority,
    required this.feesPayment,
    required this.feesPaymentPriority,
    required this.homework,
    required this.homeworkPriority,
    required this.payButtonShow,
    required this.myAchievements,
    required this.myAchievementsPriority,
    this.createdOn,
    required this.createdBy,
    this.updatedOn,
    required this.updatedBy,
  });

  factory ParentSettingsModel.fromJson(Map<String, dynamic> json) {
    return ParentSettingsModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      schoolCode: json['school_code'] ?? '',

      notification: json['notification'] ?? '',
      notificationPriority: int.tryParse(json['notification_priority'].toString()) ?? 0,

      marks: json['marks'] ?? '',
      marksPriority: int.tryParse(json['marks_priority'].toString()) ?? 0,

      attendance: json['attendance'] ?? '',
      attendancePriority: int.tryParse(json['attendance_priority'].toString()) ?? 0,

      transport: json['transport'] ?? '',
      transportPriority: int.tryParse(json['transport_priority'].toString()) ?? 0,

      classTest: json['class_test'] ?? '',
      classTestPriority: int.tryParse(json['class_test_priority'].toString()) ?? 0,

      feesPayment: json['fees_payment'] ?? '',
      feesPaymentPriority: int.tryParse(json['fees_payment_priority'].toString()) ?? 0,

      myAchievements: json['my_achievements'] ?? '',
      myAchievementsPriority: int.tryParse(json['my_achievements_priority'].toString()) ?? 0,


      homework: json['homework'] ?? '',
      homeworkPriority: int.tryParse(json['homework_priority'].toString()) ?? 0,
      payButtonShow:json['pay_button_show'] ?? '',
      createdOn: DateTime.tryParse(json['created_on'].toString()) ?? DateTime.now(),
      createdBy: json['created_by'] ?? '',

      updatedOn: DateTime.tryParse(json['updated_on'].toString()) ?? DateTime.now(),
      updatedBy: json['updated_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {

      "school_code": schoolCode,
      "notification": notification,
      "notification_priority": notificationPriority.toString(),
      "marks": marks,
      "marks_priority": marksPriority.toString(),
      "attendance": attendance,
      "attendance_priority": attendancePriority.toString(),
      "transport": transport,
      "transport_priority": transportPriority.toString(),
      "class_test": classTest,
      "class_test_priority": classTestPriority.toString(),
      "fees_payment": feesPayment,
      "fees_payment_priority": feesPaymentPriority.toString(),
      "homework": homework,
      "homework_priority": homeworkPriority.toString(),
      "my_achievements":myAchievements,
      "my_achievements_priority":myAchievementsPriority.toString(),
      "payButtonShow":payButtonShow,
      "created_by": createdBy,

      "updated_by": updatedBy,
    };
  }
}
