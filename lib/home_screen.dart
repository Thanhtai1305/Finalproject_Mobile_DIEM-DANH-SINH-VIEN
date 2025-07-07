import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'student_list_screen.dart';
import 'attendance_history_screen.dart';
import 'attendance_statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDateTime(String? timestamp) {
    if (timestamp == null) return 'Không xác định';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final vietnamTime = dateTime.add(const Duration(hours: 7)); // Chuyển sang giờ Việt Nam
      return DateFormat('dd/MM - HH:mm').format(vietnamTime);
    } catch (e) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin người dùng
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      user?.email?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Chưa xác định',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text('Chào mừng bạn trở lại!'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Ô danh sách sinh viên (Firestore)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StudentListScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách sinh viên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('students')
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Lỗi tải dữ liệu');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return const Text('Chưa có sinh viên nào');
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final student = Student.fromMap(
                                doc.data() as Map<String, dynamic>,
                                doc.id,
                              );
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.blue[100],
                                      child: Text(
                                        student.name.substring(0, 1),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(student.name),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('students')
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.docs.length == 3) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                '...Xem thêm',
                                style: TextStyle(color: Colors.blue),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ô lịch sử điểm danh gần đây (Realtime Database)
              FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance.ref('Sinhvien').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.value == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[100]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lịch sử điểm danh',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Không có dữ liệu điểm danh'),
                        ],
                      ),
                    );
                  }

                  final data = Map<String, dynamic>.from(snapshot.data!.value as Map);
                  
                  // Chuyển đổi và sắp xếp theo thời gian
                  final entries = data.entries.map((entry) {
                    final name = entry.key;
                    final value = entry.value;
                    
                    String code = '';
                    String? timestamp;
                    
                    if (value is Map) {
                      code = value['code']?.toString() ?? '';
                      timestamp = value['timestamp']?.toString();
                    } else {
                      code = value.toString();
                    }
                    
                    return {
                      'name': name,
                      'code': code,
                      'timestamp': timestamp,
                    };
                  }).toList();

                  // Sắp xếp theo thời gian mới nhất
                  entries.sort((a, b) {
                    final timestampA = a['timestamp'] as String?;
                    final timestampB = b['timestamp'] as String?;
                    
                    if (timestampA == null && timestampB == null) return 0;
                    if (timestampA == null) return 1;
                    if (timestampB == null) return -1;
                    
                    try {
                      final dateA = DateTime.parse(timestampA);
                      final dateB = DateTime.parse(timestampB);
                      return dateB.compareTo(dateA);
                    } catch (e) {
                      return 0;
                    }
                  });

                  final selectedEntries = entries.take(2).toList();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lịch sử điểm danh',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...selectedEntries.map((entry) {
                            final name = entry['name'] as String;
                            final code = entry['code'] as String;
                            final timestamp = entry['timestamp'] as String?;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '$name - mã: $code',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (timestamp != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 22, top: 2),
                                      child: Text(
                                        _formatDateTime(timestamp),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          const Text(
                            '...Xem tất cả',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Ô thống kê điểm danh (Realtime Database)
              FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance.ref('Sinhvien').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[100]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thống kê điểm danh',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.value == null) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AttendanceStatisticsScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[100]!),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thống kê điểm danh',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Không có dữ liệu thống kê'),
                            SizedBox(height: 8),
                            Text(
                              '...Xem chi tiết',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final data = Map<String, dynamic>.from(snapshot.data!.value as Map);
                  
                  // Tính toán thống kê cơ bản
                  Map<String, int> attendanceByStudent = {};
                  Map<String, int> attendanceByDate = {};
                  int totalAttendance = 0;

                  data.forEach((studentName, studentData) {
                    if (studentData is Map<dynamic, dynamic>) {
                      studentData.forEach((key, value) {
                        if (value is Map<dynamic, dynamic>) {
                          final timestamp = value['timestamp']?.toString();
                          if (timestamp != null) {
                            totalAttendance++;
                            attendanceByStudent[studentName] = (attendanceByStudent[studentName] ?? 0) + 1;

                            try {
                              final date = DateFormat('dd/MM/yyyy').format(DateTime.parse(timestamp).toLocal());
                              attendanceByDate[date] = (attendanceByDate[date] ?? 0) + 1;
                            } catch (e) {
                              // Bỏ qua lỗi định dạng ngày
                            }
                          }
                        }
                      });
                    }
                  });

                  // Lấy top 3 sinh viên có số lần điểm danh nhiều nhất
                  final topStudents = attendanceByStudent.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final selectedStudents = topStudents.take(3).toList();

                  // Lấy 2 ngày gần đây nhất
                  final recentDates = attendanceByDate.entries.toList()
                    ..sort((a, b) {
                      try {
                        final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
                        final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
                        return dateB.compareTo(dateA);
                      } catch (e) {
                        return 0;
                      }
                    });
                  final selectedDates = recentDates.take(2).toList();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceStatisticsScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thống kê điểm danh',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Tổng số lần điểm danh
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bar_chart, color: Colors.purple[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Tổng số lần điểm danh: $totalAttendance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Top sinh viên
                          if (selectedStudents.isNotEmpty) ...[
                            Text(
                              'Top sinh viên tích cực:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.purple[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...selectedStudents.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.person, size: 16, color: Colors.purple[600]),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${entry.key}: ${entry.value} lần',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                          ],
                          
                          // Ngày gần đây
                          if (selectedDates.isNotEmpty) ...[
                            Text(
                              'Hoạt động gần đây:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.purple[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...selectedDates.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Colors.purple[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${entry.key}: ${entry.value} lượt',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                          
                          const SizedBox(height: 8),
                          const Text(
                            '...Xem thống kê chi tiết',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}