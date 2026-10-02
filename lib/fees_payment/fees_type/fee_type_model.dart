import 'package:flutter/material.dart'; // Included for completeness, though often not needed in pure models

class FeeCategory {
  // Required Fields (NOT NULL in SQL)
  final int? categoryId; // PK
  final String schoolCode;
  final String categoryName;
  final String status; // ENUM: 'Active' or 'Inactive'
  int? priority;

  // Optional Fields (DEFAULT or NULL in SQL)
  final String? description;
  final String? createdBy;
  final DateTime? createdOn;
  final String? updatedBy;
  final DateTime? updatedOn;

  FeeCategory({
    this.categoryId,
    required this.schoolCode,
    required this.categoryName,
    this.description,
    required this.status,
    this.priority,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
  });

  // ------------------------------------------------------------------------
  // 1. FACTORY CONSTRUCTOR for JSON DESERIALIZATION (Mapping JSON to Dart Object)
  // ------------------------------------------------------------------------

  factory FeeCategory.fromJson(Map<String, dynamic> json) {
    // Helper to safely get a String, returning null if the key is missing or the value is null/empty.
    String? safeString(String key) {
      final value = json[key];
      if (value == null || value.toString().isEmpty) return null;
      return value.toString();
    }

    // Helper to safely get an Int, handling null, int, or string inputs.
    int? safeInt(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // --- Priority Parsing ---
    // If 'priority' is present and not empty, parse it to int. Defaulting to null if parsing fails.
    final parsedPriority = safeInt('priority');

    return FeeCategory(
      // Primary Key (feestype_id -> categoryId)
      categoryId: safeInt('feestype_id'), // Mapped from feestype_id

      // Required Strings (Using safeString to handle potential nulls/wrong types more gracefully)
      // NOTE: If these are truly REQUIRED, you might want to throw an error instead of using safeString.
      schoolCode: safeString('school_code') ?? 'N/A', // Using null-coalescing for required fields
      categoryName: safeString('fees_name') ?? 'N/A', // Mapped from fees_name

      // Status (Mapping is_active to status)
      // The JSON has 'is_active', which is an empty string. Assuming this means 'Inactive' or '0',
      // or maybe you want to default it to 'Active' if it's empty/missing.
      // Based on the JSON, we'll map 'is_active' to 'status'.
      status: safeString('is_active') ?? 'Active', // Assuming 'Active' if empty/null, adjust logic as needed.

      // Priority
      priority: parsedPriority,

      // Optional/Nullable Fields
      description: safeString('description'),
      createdBy: safeString('created_by'),
      updatedBy: safeString('updated_by'),

      // Date/Time Parsing
      createdOn: safeString('created_on') != null
          ? DateTime.tryParse(safeString('created_on')!)
          : null,
      updatedOn: safeString('updated_on') != null
          ? DateTime.tryParse(safeString('updated_on')!)
          : null,
    );
  }

  // ------------------------------------------------------------------------
  // 2. METHOD for JSON SERIALIZATION (Mapping Dart Object to JSON - ADD/CREATE)
  // Excludes DB-managed fields (PK, created/updated timestamps)
  // ------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'school_code': schoolCode,
      'category_name': categoryName,
      'description': description, // Nullable field
      'status': status,
      'priority': priority,
      'created_by': createdBy, // Sent to DB for insertion
      // 'created_on' is managed by the database
    };
  }

  // ------------------------------------------------------------------------
  // 3. METHOD for JSON SERIALIZATION (Mapping Dart Object to JSON - UPDATE)
  // Includes PK and all fields needed for a PUT/PATCH request
  // ------------------------------------------------------------------------

  Map<String, dynamic> toJsonUpdate() {
    return {
      'category_id': categoryId.toString(),
      'school_code': schoolCode.toString(),
      'category_name': categoryName.toString(),
      'description': description.toString(),
      'is_active': status.toString(),
      'priority': priority.toString(),
      // Use updatedBy for tracking the change
      'updated_by': updatedBy.toString(),
    };
  }
}

// ------------------------------------------------------------------------
// 4. EXTENSION for COPYWITH METHOD
// ------------------------------------------------------------------------

extension FeeCategoryClassCopy on FeeCategory {
  FeeCategory copyWith({
    int? categoryId,
    String? schoolCode,
    String? categoryName,
    String? description,
    String? status,
    int? priority,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
  }) {
    return FeeCategory(
      categoryId: categoryId ?? this.categoryId,
      schoolCode: schoolCode ?? this.schoolCode,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedOn: updatedOn ?? this.updatedOn,
    );
  }
}