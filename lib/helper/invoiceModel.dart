class InvoiceModel{
  final String center_code;
  final String student_id;
  final String invoice_date;
  final String invoice_amount;
  final String course_id;
  final String batch_id;
  final String payment_status;
  final String invoice_id;
  final String remarks;

  InvoiceModel({required this.center_code,required this.student_id,required this.invoice_date,
    required this.invoice_amount,required this.course_id,required this.batch_id,required this.payment_status,
    required this.invoice_id,required this.remarks});

  factory InvoiceModel.fromJson(Map<String,dynamic>json){
    return InvoiceModel(
        center_code:json['center_code'] ,
        student_id: json['student_id'],
        invoice_date:json['invoice_date'] ,
        invoice_amount: json['invoice_amount'],
        course_id: json['course_id'],
        batch_id: json['batch_id'],
        payment_status: json['payment_status'],
        invoice_id: json['invoice_id'],
        remarks: json['remarks']

    );
  }

  Map<String,dynamic>toJsonAdd(){
    print("INVOICE AMOUNT : $invoice_amount");
    return{
      "center_code":center_code,
      "student_id":student_id,
      "invoice_date":invoice_date,
      "invoice_amount":invoice_amount,
      "course_id":course_id,
      "batch_id":batch_id,
      "payment_status":payment_status,
      "invoice_id": invoice_id,
      "remarks":remarks
    };

  }
}




class InvoiceModelWhole{
  String? id;
  String? center_code;
  String? amount;
  String? student_id;
  String? student_codeid;
  String? invoice_date;
  String? invoice_amount;
  String? course_id;
  String? batch_id;
  String? payment_status;
  String? invoice_id;
  String? remarks;
  String? student_name;


  InvoiceModelWhole({
    this.id,
    this.center_code,
    this.student_id,
    this.invoice_id,
    this.student_codeid,
    this.invoice_amount,
    this.invoice_date,
    this.amount,
    this.course_id,
    this.batch_id,
    this.student_name,
    this.payment_status,
    this.remarks
  });
  factory InvoiceModelWhole.fromJson(Map<String, dynamic> json) {
    return InvoiceModelWhole(
      id: json['id'].toString(),
      center_code: json['center_code'] ?? "",
      student_id: json['student_id'] ?? "",
      invoice_id: json['invoice_id'] ?? "",
      invoice_amount: json['invoice_amount'] ?? "",
      invoice_date: json['invoice_date'] ?? "",
      course_id: json['course_id'] ?? "",
      batch_id: json['batch_id'] ?? "",
      payment_status: json['payment_status'] ?? "",
      remarks: json['remarks']?? "",
      amount: json['amount']??"",
      student_codeid:json['student_codeid']??"",
      student_name: json['student_name'] ?? ""
    );
  }

}