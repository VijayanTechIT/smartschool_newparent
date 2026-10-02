import 'package:smart_school_parent/fees_payment/fees_payment_model.dart';

import 'fees_invoice_detail_model.dart';

class FeesInvoiceModel {
  final int? invoiceId;
  final String schoolCode;
  final int studentId;
  final int termId;
  final int academicId;
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final String status;
  final DateTime invoiceDate;
  final String? createdBy;
  final String remarks;
  // Optional: List of details for sending/receiving complete invoice
  final List<FeesInvoiceDetailModel>? details;
  final List<FeesPayment>? paymentsAgainstInvoice;

  FeesInvoiceModel({
    this.invoiceId,
    required this.schoolCode,
    required this.studentId,
    required this.termId,
    required this.academicId,
    required this.totalAmount,
    this.paidAmount = 0.00,
    required this.balanceAmount,
    this.remarks = '',
    this.status = 'Unpaid', // Default status for new invoice
    required this.invoiceDate,
    this.createdBy,
    this.details,
    this.paymentsAgainstInvoice
  });

  // Factory constructor for creating a model from a JSON map (for fetching data)
  factory FeesInvoiceModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return FeesInvoiceModel(
      invoiceId: json['invoice_id'] is int
          ? json['invoice_id'] as int
          : int.tryParse(json['invoice_id'].toString()),
      schoolCode: json['school_code']?.toString() ?? '',
      studentId: json['student_id'] is int
          ? json['student_id'] as int
          : int.tryParse(json['student_id'].toString()) ?? 0,
      termId: json['term_id'] is int
          ? json['term_id'] as int
          : int.tryParse(json['term_id'].toString()) ?? 0,
      academicId: json['academic_id'] is int
          ? json['academic_id'] as int
          : int.tryParse(json['academic_id'].toString()) ?? 0,
        remarks: json['remarks']?.toString() ?? '',
      // ✅ Safe numeric parsing
      totalAmount: parseDouble(json['total_amount']),
      paidAmount: parseDouble(json['paid_amount']),
      balanceAmount: parseDouble(json['balance_amount']),

      status: json['status']?.toString() ?? '',
      invoiceDate: DateTime.tryParse(json['invoice_date']?.toString() ?? '') ??
          DateTime.now(),
      createdBy: json['created_by']?.toString(),

      details: (json['details'] is List)
          ? (json['details'] as List)
          .map((i) => FeesInvoiceDetailModel.fromJson(i))
          .toList()
          : [],

      paymentsAgainstInvoice: (json['payments'] is List)?
      (json['payments'] as List)
          .map((i) => FeesPayment.fromJson(i))
          .toList() : []
    );
  }

  // Method for converting the model to a JSON map (for sending data)
  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'school_code': schoolCode,
      'student_id': studentId,
      'term_id': termId,
      'academic_id': academicId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'status': status,
      'remarks':remarks,
      'invoice_date': invoiceDate.toIso8601String().substring(0, 10), // Only date part
      'created_by': createdBy,
      'details': details?.map((d) => d.toJson()).toList(),
    };
  }

  FeesInvoiceModel copyWith({
    int? invoiceId,
    String? schoolCode,
    int? studentId,
    int? termId,
    int? academicId,
    double? totalAmount,
    double? paidAmount,
    double? balanceAmount,
    String? status,
    DateTime? invoiceDate,
    String? createdBy,
    List<FeesInvoiceDetailModel>? details,
  }) {
    return FeesInvoiceModel(
      invoiceId: invoiceId ?? this.invoiceId,
      schoolCode: schoolCode ?? this.schoolCode,
      studentId: studentId ?? this.studentId,
      termId: termId ?? this.termId,
      academicId: academicId ?? this.academicId,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      status: status ?? this.status,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      createdBy: createdBy ?? this.createdBy,
      details: details ?? this.details,
    );
  }

}