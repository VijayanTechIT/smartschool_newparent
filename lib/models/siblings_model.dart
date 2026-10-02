class SiblingModel {
  final int? id;
  final String studentId;
  final String name;
  final String dob;
  final String relationship;

  SiblingModel({
    this.id,
    required this.studentId,
    required this.name,
    required this.dob,
    required this.relationship,
  });

  // Convert a SiblingModel to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name':name,
      'dob':dob,
      'studentId': studentId,
      'relationship': relationship,
    };
  }

  // Create a SiblingModel from a Map (database row)
  factory SiblingModel.fromMap(Map<String, dynamic> map) {
    return SiblingModel(
      id: map['id'],
      name:map['name'],
      dob: map['dob'],
      studentId: map['studentId'],
      relationship: map['relationship'],
    );
  }

  @override
  String toString() {
    return 'SiblingModel(id: $id, studentId: $studentId, relationship: $relationship)';
  }
}
