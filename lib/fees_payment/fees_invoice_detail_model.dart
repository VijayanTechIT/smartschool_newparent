class FeesInvoiceDetailModel {
  final int? detailId;
  final String schoolCode;
  final int? invoiceId;
  final int categoryId;
  final double amount;
  final double paidAmount;
  final double balanceAmount;
  final String? createdBy;

  FeesInvoiceDetailModel({
    this.detailId,
    required this.schoolCode,
    this.invoiceId,
    required this.categoryId,
    required this.amount,
    this.paidAmount = 0.00,
    required this.balanceAmount,
    this.createdBy,
  });

  factory FeesInvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return FeesInvoiceDetailModel(
      detailId: parseInt(json['detail_id']),
      schoolCode: json['school_code']?.toString() ?? '',
      invoiceId: parseInt(json['invoice_id']),
      categoryId: parseInt(json['category_id']),
      amount: parseDouble(json['amount']),
      paidAmount: parseDouble(json['paid_amount']),
      balanceAmount: parseDouble(json['balance_amount']),
      createdBy: json['created_by']?.toString(),
    );
  }


  // Method for converting the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId,
      'school_code': schoolCode,
      'invoice_id': invoiceId,
      'category_id': categoryId,
      'amount': amount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'created_by': createdBy,
    };
  }

  FeesInvoiceDetailModel copyWith({
    int? detailId,
    String? schoolCode,
    int? invoiceId,
    int? categoryId,
    double? amount,
    double? paidAmount,
    double? balanceAmount,
    String? createdBy,
  }) {
    return FeesInvoiceDetailModel(
      detailId: detailId ?? this.detailId,
      schoolCode: schoolCode ?? this.schoolCode,
      invoiceId: invoiceId ?? this.invoiceId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}