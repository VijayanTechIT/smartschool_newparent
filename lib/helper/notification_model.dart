class NotificationModel{
  String? notificationId;
  String? schoolCode;
  String? studentId;
  String? notificationTitle;
  String? notificationMessage;
  String? date;
  String? createdOn;
  String? createdBy;
  String? imagePath;



  NotificationModel({
    this.notificationId,
    this.schoolCode,
    this.studentId,
    this.notificationTitle,
    this.notificationMessage,
    this.date,
    this.createdOn,
    this.createdBy,
    this.imagePath,

  });
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        notificationId: json['notification_id'].toString(),
        schoolCode: json['school_code'] ?? "",
        studentId: json['student_id'] ?? "",
        notificationTitle: json['notification_title'] ?? "",
      notificationMessage: json['notification_message'] ?? "",
      date: json['date'] ?? '',
      createdBy:json['created_by'] ?? "",
      createdOn:json['created_on'] ?? "",
      imagePath: json['image_path'] ?? ""
       );
  }

}