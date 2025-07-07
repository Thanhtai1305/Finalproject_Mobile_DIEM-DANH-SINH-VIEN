class Student {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String studentId;
  final String? phone;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    this.avatarUrl,
    this.phone,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      avatarUrl: map['avatarUrl'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'avatarUrl': avatarUrl,
      'phone': phone,
    };
  }
}