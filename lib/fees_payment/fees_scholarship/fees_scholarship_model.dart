// The two possible values for the discount_type ENUM
enum DiscountType { amount, percentage }

// Extension to help with JSON serialization/deserialization
extension DiscountTypeExtension on DiscountType {
  String get value => toString().split('.').last;
}

class StudentScholarship {
  final int? id;
  final String schoolCode;
  final String studentId;
  final String? feeType;
  final String? scholarshipType;  // Mapped from scholarship_type VARCHAR(100)
  final String discountType;
  final double discountValue; // Dart uses double for floating point numbers
  final String? remarks;
  final bool isActive;
  final DateTime? createdOn;
  final String? createdBy;
  final DateTime? updatedOn;
  final String? updatedBy;

  // 1. Constructor for creating a new object in memory (best practice is using 'final' and 'const' if possible)
  const StudentScholarship({
    this.id,
    required this.schoolCode,
    required this.studentId,
    this.feeType,this.isActive = true, // Maps to DEFAULT TRUE in SQL
    this.discountType = 'percentage', // Default value
    this.discountValue = 0.0, // Default value
    this.remarks,
    this.scholarshipType,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
  });

  // 2. Factory method for Deserialization (converting JSON/Map to Dart Object)
  factory StudentScholarship.fromJson(Map<String, dynamic> json) {
    // Helper to parse the boolean safely from '0' or '1' strings
    bool safeParseBool(String? value) {
      // Treat "1", "true", or any non-zero/non-false string as true.
      // Treat "0" or "false" as false. Default to false if null.
      if (value == null) return false;
      return value == '1' || value.toLowerCase() == 'true';
    }
    String? safeString(String key) {
      final value = json[key];
      // This handles null, empty string, and converts any other type (like int 0) to a string
      if (value == null || value.toString().isEmpty || value == 'null') return null;
      return value.toString();
    }
    // --- UPDATED PARSING ---
    final String? idAsString = safeString('id');
    final String? isActiveAsString = safeString('is_active');


    // Helper to safely parse a String, returning null if empty/null
    String? _safeString(dynamic value) {
      if (value == null || value.toString().isEmpty || value == 'null') return null;
      return value.toString();
    }

    return StudentScholarship(
      // ID: Handles potential null and ensures it's an int
      id: int.parse(json['id']) as int?,
      schoolCode: json['school_code'] as String,
      studentId: json['student_id'] as String,
      isActive: safeParseBool(isActiveAsString),

      feeType: json['fee_type'] as String?,
      // **CRITICAL FIX**: Use the helper to convert String to Enum
      discountType: json['discount_type'] as String,
      // DISCOUNT VALUE: Handles num, double, or null, defaulting to 0.0
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0.0') ?? 0.0,
      remarks: json['remarks'] as String?,
      // SCHOLARSHIP TYPE: Uses safe string check
      scholarshipType: _safeString(json['scholarship_type']),
      // CREATED ON/UPDATED ON: Robust parsing of timestamps, handles null/empty string
      createdOn: DateTime.tryParse(json['created_on'] as String? ?? ''),
      createdBy: json['created_by'] as String?,
      updatedOn: DateTime.tryParse(json['updated_on'] as String? ?? ''),
      updatedBy: json['updated_by'] as String?,
    );
  }
  // 3. Method for Serialization (converting Dart Object to JSON/Map)
  Map<String, dynamic> toJson() {
    return {
      // id is usually excluded for POST requests (new records)
      if (id != null) 'id': id,
      'student_id': studentId,
      'school_code':schoolCode,
      'fee_type': feeType,
      'is_active': isActive,
      // Convert the Enum back to its string value
      'discount_type': discountType,
      'discount_value': discountValue,
      'remarks': remarks,

      // Convert DateTime to ISO 8601 string for API transport
      if (createdOn != null) 'created_on': createdOn!.toIso8601String(),
      'created_by': createdBy,
      if (updatedOn != null) 'updated_on': updatedOn!.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      // id is usually excluded for POST requests (new records)
      if (id != null) 'id': id,
      'student_id': studentId,
      'school_code':schoolCode,
      'fee_type': feeType,
      'is_active': isActive ? '1': '0',
      // Convert the Enum back to its string value
      'discount_type': discountType,
      'discount_value': discountValue,
      'remarks': remarks,

      // Convert DateTime to ISO 8601 string for API transport
      if (createdOn != null) 'created_on': createdOn!.toIso8601String(),
      'created_by': createdBy,
      if (updatedOn != null) 'updated_on': updatedOn!.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  // 4. Utility method for copying (useful for immutability and state management)
  StudentScholarship copyWith({
    int? id,
    String? studentId,
    String? schoolCode,
    String? feeType,
    String? discountType,
    double? discountValue,
    String? remarks,
    DateTime? createdOn,
    String? createdBy,
    DateTime? updatedOn,
    String? updatedBy,
  }) {
    return StudentScholarship(
      id: id ?? this.id,
      schoolCode: schoolCode ?? this.schoolCode,
      studentId: studentId ?? this.studentId,
      feeType: feeType ?? this.feeType,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      remarks: remarks ?? this.remarks,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      updatedOn: updatedOn ?? this.updatedOn,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}