import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String _searchQuery = ''; // Biến lưu từ khóa tìm kiếm

  // Danh sách sinh viên có sẵn với ID riêng biệt và MSSV
  final List<Map<String, String>> _predefinedStudents = [
    {
      'name': 'HoangVanE',
      'studentId': '29F7B6B8',
      'mssv': 'SV001',
      'email': 'hoangvane@student.edu.vn'
    },
    {
      'name': 'LeTuC',
      'studentId': '09B1DAB9',
      'mssv': 'SV002',
      'email': 'letuc@student.edu.vn'
    },
    {
      'name': 'NguyenHoangG',
      'studentId': '2915B8B8',
      'mssv': 'SV003',
      'email': 'nguyenhoangg@student.edu.vn'
    },
    {
      'name': 'NguyenVanA',
      'studentId': '2E28A304',
      'mssv': 'SV004',
      'email': 'nguyenvana@student.edu.vn'
    },
    {
      'name': 'PhamThiD',
      'studentId': '516DB005',
      'mssv': 'SV005',
      'email': 'phamthid@student.edu.vn'
    },
    // {
    //   'name': 'TranThiB',
    //   'studentId': '399CBAB8',
    //   'mssv': 'SV006',
    //   'email': 'tranthib@student.edu.vn'
    // },
    // {
    //   'name': 'VoThiF',
    //   'studentId': 'B90429B3',
    //   'mssv': 'SV007',
    //   'email': 'vothif@student.edu.vn'
    // },
  ];

  @override
  void initState() {
    super.initState();
    _initializePredefinedStudents();
  }

  Future<void> _initializePredefinedStudents() async {
    try {
      for (var student in _predefinedStudents) {
        final snapshot = await _databaseRef
            .child('students')
            .child(student['studentId']!)
            .get();

        if (!snapshot.exists) {
          await _databaseRef.child('students').child(student['studentId']!).set({
            'name': student['name']!,
            'mssv': student['mssv']!,
            'email': student['email']!,
            'phone': '',
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }
      print('Đã khởi tạo danh sách sinh viên có sẵn trong Realtime Database');
    } catch (e) {
      print('Lỗi khi khởi tạo danh sách sinh viên: $e');
    }
  }

  Future<void> _addStudentToAttendanceSystem(String name, String mssv) async {
    try {
      await _databaseRef.child('Sinhvien').child(name).set({
        'code': mssv,
        'timestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm $name vào hệ thống điểm danh')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm vào hệ thống điểm danh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, MSSV hoặc UID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: StreamBuilder<DatabaseEvent>(
              stream: _databaseRef.child('students').onValue,
              builder: (context, snapshot) {
                int count = 0;
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );
                  count = data.length;
                }

                return Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Text(
                      'Tổng số sinh viên: $count',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.storage, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Realtime DB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _databaseRef.child('students').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có sinh viên nào',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final data = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                final students = data.entries.map((entry) {
                  final studentData = Map<String, dynamic>.from(entry.value as Map);
                  return Student.fromMap(studentData, entry.key);
                }).toList();

                // Lọc danh sách sinh viên dựa trên từ khóa tìm kiếm
                final filteredStudents = students.where((student) {
                  final nameMatch = student.name.toLowerCase().contains(_searchQuery);
                  final mssvMatch = student.mssv.toLowerCase().contains(_searchQuery);
                  final uidMatch = student.studentId.toLowerCase().contains(_searchQuery);
                  return nameMatch || mssvMatch || uidMatch;
                }).toList();

                // Sắp xếp danh sách sinh viên theo tên
                filteredStudents.sort((a, b) => a.name.compareTo(b.name));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          radius: 24,
                          child: Text(
                            student.name.isNotEmpty ? student.name.substring(0, 1) : '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.fingerprint, size: 16, color: Colors.green[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'ID: ${student.studentId}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[700],
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'MSSV: ${student.mssv}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    student.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'details':
                                _showStudentDetails(context, student);
                                break;
                              case 'add_to_attendance':
                                await _addStudentToAttendanceSystem(student.name, student.mssv);
                                break;
                              case 'edit':
                                _showEditStudentDialog(context, student);
                                break;
                              case 'delete':
                                _showDeleteConfirmation(context, student);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline),
                                  SizedBox(width: 8),
                                  Text('Xem chi tiết'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'add_to_attendance',
                              child: Row(
                                children: [
                                  Icon(Icons.how_to_reg, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Thêm vào điểm danh'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Chỉnh sửa'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(student.name.substring(0, 1)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(student.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.fingerprint, 'ID hệ thống', student.studentId, Colors.green),
            _buildDetailRow(Icons.badge, 'MSSV', student.mssv, Colors.blue),
            _buildDetailRow(Icons.email, 'Email', student.email, Colors.grey),
            _buildDetailRow(Icons.phone, 'Điện thoại', student.phone ?? 'Chưa cập nhật', Colors.grey),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: label.contains('ID') || label.contains('MSSV') ? 'monospace' : null,
                color: color,
                fontWeight: label.contains('ID') ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    final mssvController = TextEditingController(text: student.mssv);
    final emailController = TextEditingController(text: student.email);
    final phoneController = TextEditingController(text: student.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin sinh viên'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mssvController,
                  decoration: const InputDecoration(
                    labelText: 'MSSV *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                    hintText: 'VD: SV00n',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập MSSV';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fingerprint, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 6),
                      Text(
                        'ID hệ thống: ${student.studentId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                await _databaseRef.child('students').child(student.studentId).update({
                  'name': nameController.text.trim(),
                  'mssv': mssvController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'updatedAt': DateTime.now().toIso8601String(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thông tin thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi cập nhật: $e')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên "${student.name}" (ID: ${student.studentId})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _databaseRef.child('students').child(student.studentId).remove();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa sinh viên thành công')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xóa: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final mssvController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final studentIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sinh viên mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mssvController,
                  decoration: const InputDecoration(
                    labelText: 'MSSV *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập MSSV';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'UID thẻ RFID *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.card_membership),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập UID thẻ RFID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ID hệ thống sẽ được sử dụng từ UID thẻ RFID',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final studentsSnapshot = await _databaseRef.child('students').get();
                if (studentsSnapshot.exists) {
                  final studentsData = Map<String, dynamic>.from(studentsSnapshot.value as Map);
                  final isDuplicate = studentsData.containsKey(studentIdController.text.trim());

                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UID đã tồn tại')),
                    );
                    return;
                  }
                }

                await _databaseRef.child('students').child(studentIdController.text.trim()).set({
                  'name': nameController.text.trim(),
                  'mssv': mssvController.text.trim(),
                  'email': emailController.text.trim().isEmpty
                      ? '${nameController.text.trim().toLowerCase().replaceAll(' ', '')}@student.edu.vn'
                      : emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'createdAt': DateTime.now().toIso8601String(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thêm sinh viên thành công (ID: ${studentIdController.text.trim()})')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi thêm: $e')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class Student {
  final String studentId;
  final String name;
  final String mssv;
  final String email;
  final String? phone;

  Student({
    required this.studentId,
    required this.name,
    required this.mssv,
    required this.email,
    this.phone,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      studentId: id,
      name: map['name'] ?? '',
      mssv: map['mssv'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mssv': mssv,
      'email': email,
      'phone': phone,
    };
  }
}