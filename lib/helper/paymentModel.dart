class PaymentModel{
  final String center_code;
  final String student_id;
  final String paidAmount;
  final String balance;
  final String paymentType;
  final String remarks;
  final String payment_date;
  final String invoice_id;


  PaymentModel({required this.center_code,required this.student_id,required this.paidAmount,
    required this.balance,required this.paymentType,required this.remarks,required this.payment_date,
    required this.invoice_id});

  factory PaymentModel.fromJson(Map<String,dynamic>json){
    return PaymentModel(
        center_code:json['center_code'] ,
        student_id: json['student_id'],
        paidAmount:json['paidAmount'] ,
        balance: json['balance'],
        paymentType: json['paymentType'],
        remarks: json['remarks'],
        payment_date: json['payment_date'],
        invoice_id: json['invoice_id'],
     );
  }

  Map<String,dynamic>toJsonAdd(){
    return{
      "center_code":center_code,
      "student_id":student_id,
      "paidAmount":paidAmount,
      "balance":balance,
      "paymentType": paymentType,
      "payment_date":payment_date,
      "invoice_id":invoice_id,
      "remarks":remarks
    };
  }
}




class PaymentModelWhole{
  String? id;
  String? center_code;
  String? student_id;
  String? paidAmount;
  String? balance;
  String? paymentType;
  String? remarks;
  String? payment_date;
  String? invoce_id;
  String? student_name;
  String? student_codeid;
  String? course;


  PaymentModelWhole({
    this.id,
    this.center_code,
    this.student_id,
    this.paidAmount,
    this.balance,
    this.paymentType,
    this.payment_date,
    this.invoce_id,
    this.remarks,this.student_name,this.course,
    this.student_codeid
  });
  factory PaymentModelWhole.fromJson(Map<String, dynamic> json) {
    return PaymentModelWhole(
      id: json['id'].toString(),
      center_code: json['center_code'] ?? "",
      student_id: json['student_id'] ?? "",
      paidAmount: json['paidAmount'] ?? "",
      balance: json['balance'] ?? "",
      paymentType: json['paymentType'] ?? "",
      payment_date: json['payment_date'] ?? "",
      invoce_id: json['invoce_id'] ?? "",
      remarks: json['remarks']?? "",
        student_name:json['student_name'] ?? "",
        student_codeid:json['student_codeid']?? "",
      course: json['course'] ?? ""
    );
  }

}