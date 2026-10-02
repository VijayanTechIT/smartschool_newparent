import 'package:intl/intl.dart'; // Add this package to your pubspec.yaml if you need date formatting

class TermModel {
  // Required fields for core model data
  final int termId; // Primary Key
  final String schoolCode;
  final String termName;
  final int priority;
  final String? academicYearId; // Nullable based on SQL definition
  final String startDate;
  final String endDate;

  // Audit fields - often received from API, but not sent for Add/Update
  final DateTime? createdOn;
  final String? createdBy;
  final DateTime? updatedOn;
  final String? updatedBy;

  TermModel({
    required this.termId,
    required this.schoolCode,
    required this.termName,
    required this.priority,
    this.academicYearId,
    required this.startDate,
    required this.endDate,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
  });

  // Helper for formatting dates to ISO 8601 string (e.g., 'YYYY-MM-DD')
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  // Helper for formatting timestamps (e.g., '2025-10-30 12:00:00')
  static final _timestampFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

// ------------------------------------------------------------------
// 1. Deserialization: JSON (Map) -> Dart Object
// ------------------------------------------------------------------

  factory TermModel.fromJson(Map<String, dynamic> json) {
    String? parseNullableString(String? value) {
      if (value == null || value.isEmpty) return null;
      return value;
    }

    String parseDate(String? value) {
      if (value == null || value == "0000-00-00") return "";
      return value;
    }

    DateTime? parseDateTime(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    return TermModel(
      termId: int.tryParse(json['term_id'].toString()) ?? 0,
      schoolCode: json['school_code'] ?? '',
      termName: json['term_name'] ?? '',
      priority: int.tryParse(json['priority'].toString()) ?? 0,
      academicYearId: parseNullableString(json['academic_year_id']),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      createdOn: parseDateTime(json['created_on']),
      createdBy: json['created_by'],
      updatedOn: parseDateTime(json['updated_on']),
      updatedBy: json['updated_by'],
    );
  }

// ------------------------------------------------------------------
// 2. Serialization for CREATE/ADD (POST Request)
// ------------------------------------------------------------------



  Map<String, dynamic> toJsonAdd() {
    String formatDate(String? dateStr, String fieldName) {
      print('📅 [DEBUG] Raw $fieldName value: $dateStr');
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        print('⚠️ [$fieldName] Invalid or empty date, defaulting to 0000-00-00');
        return "0000-00-00";
      }
      try {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed == null) {
          print('❌ [$fieldName] Failed to parse date: $dateStr');
          return "0000-00-00";
        }
        final formatted = DateFormat('yyyy-MM-dd').format(parsed);
        print('✅ [$fieldName] Formatted date: $formatted');
        return formatted;
      } catch (e) {
        print('🚨 [$fieldName] Exception while formatting: $e');
        return "0000-00-00";
      }
    }

    final formattedStart = formatDate(startDate, 'start_date');
    final formattedEnd = formatDate(endDate, 'end_date');

    final jsonData = {
      'school_code': schoolCode,
      'term_name': termName,
      if (academicYearId != null && academicYearId!.isNotEmpty)
        'academic_year_id': academicYearId,
      'start_date': formattedStart,
      'end_date': formattedEnd,
    };

    print('📦 Final JSON data to send: $jsonData');
    return jsonData;


  }


// ------------------------------------------------------------------
// 3. Serialization for UPDATE (PUT Request)
// ------------------------------------------------------------------

  Map<String, dynamic> toJsonUpdate() {
    String formatDate(String? dateStr, String fieldName) {
      print('📅 [DEBUG] Raw $fieldName value: $dateStr');
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        print('⚠️ [$fieldName] Invalid or empty date, defaulting to 0000-00-00');
        return "0000-00-00";
      }
      try {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed == null) {
          print('❌ [$fieldName] Failed to parse date: $dateStr');
          return "0000-00-00";
        }
        final formatted = DateFormat('yyyy-MM-dd').format(parsed);
        print('✅ [$fieldName] Formatted date: $formatted');
        return formatted;
      } catch (e) {
        print('🚨 [$fieldName] Exception while formatting: $e');
        return "0000-00-00";
      }
    }

    final formattedStart = formatDate(startDate, 'start_date');
    final formattedEnd = formatDate(endDate, 'end_date');
    return {
      // Primary key (term_id) is REQUIRED to identify the record to update
      'term_id': termId.toString(),
      'school_code': schoolCode,
      'term_name': termName,
      'priority': priority.toString(),
      'academic_year_id': academicYearId,
      'start_date': formattedStart,
      'end_date':formattedEnd,

      // Audit field like updated_by is often set by the app or backend
      // 'updated_by': updatedBy,
    };
  }


  // ------------------------------------------------------------------
  TermModel copyWith({
    int? termId,
    String? schoolCode,
    String? termName,
    int? priority,
    String? academicYearId,
    String? startDate,
    String? endDate,
    DateTime? createdOn,
    String? createdBy,
    DateTime? updatedOn,
    String? updatedBy,
  }) {
    return TermModel(
      termId: termId ?? this.termId,
      schoolCode: schoolCode ?? this.schoolCode,
      termName: termName ?? this.termName,
      priority: priority ?? this.priority,
      academicYearId: academicYearId ?? this.academicYearId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      updatedOn: updatedOn ?? this.updatedOn,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}