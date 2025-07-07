import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'services/flutter_local_notifications.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Sinhvien');
  TimeOfDay _classStartTime = const TimeOfDay(hour: 7, minute: 0);
  DateTime selectedDate = DateTime.now();
  final Set<String> _notifiedKeys = {};

  // Mốc thời gian điểm danh theo ngày được chọn và giờ đã cài
  DateTime get classStartTimeOfSelectedDate {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _classStartTime.hour,
      _classStartTime.minute,
    );
  }

  String _formatDateTime(String? timestamp) {
    if (timestamp == null) return 'Chưa có thời gian';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('dd/MM/yyyy - HH:mm:ss').format(dt);
    } catch (_) {
      return 'Không xác định ($timestamp)';
    }
  }

  String getAttendanceStatus(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final checkIn = DateTime.parse(timestamp).toLocal();
      final classTime = DateTime(
        checkIn.year,
        checkIn.month, 
        checkIn.day,
        _classStartTime.hour,
        _classStartTime.minute,
      );
      return checkIn.isAfter(classTime) ? 'Đi trễ' : 'Đúng giờ';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử điểm danh'),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            tooltip: 'Chọn giờ vào lớp',
            onPressed: () async {
              final picked = await showTimePicker(context: context, initialTime: _classStartTime);
              if (picked != null) {
                setState(() {
                  _classStartTime = picked;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Chọn ngày',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null || data is! Map) {
            return const Center(child: Text('Chưa có dữ liệu điểm danh'));
          }

          List<Map<String, dynamic>> entries = [];

          data.forEach((studentName, records) {
            if (records is Map) {
              records.forEach((key, value) {
                if (value is Map) {
                  final timestamp = value['timestamp']?.toString();
                  final code = value['code']?.toString() ?? '';
                  String status = value['status']?.toString() ?? '';
                  final uniqueKey = '$studentName|$key';

                  // Xử lý cập nhật status và notification
                  if (timestamp != null) {
                    final calcStatus = getAttendanceStatus(timestamp);
                    
                    // Luôn cập nhật status dựa trên tính toán hiện tại
                    if (calcStatus.isNotEmpty && status != calcStatus) {
                      _dbRef.child('$studentName/$key/status').set(calcStatus);
                      status = calcStatus;
                    }

                    // Gửi notification nếu chưa gửi cho key này
                    if (calcStatus.isNotEmpty && !_notifiedKeys.contains(uniqueKey)) {
                      _notifiedKeys.add(uniqueKey);
                      NotificationService.showNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: 'Điểm danh: $studentName',
                        body: calcStatus == 'Đi trễ'
                            ? '❌ Điểm danh thất bại (Đi trễ)'
                            : '✅ Điểm danh thành công',
                      );
                    }
                  }

                  // Lọc theo ngày đã chọn
                  final dateMatch = () {
                    try {
                      final d = DateTime.parse(timestamp!).toLocal();
                      return d.year == selectedDate.year &&
                          d.month == selectedDate.month &&
                          d.day == selectedDate.day;
                    } catch (_) {
                      return false;
                    }
                  };

                  if (timestamp != null && dateMatch()) {
                    entries.add({
                      'name': studentName,
                      'code': code,
                      'timestamp': timestamp,
                      'status': status,
                    });
                  }
                }
              });
            }
          });

          // Sắp xếp theo thời gian mới nhất
          entries.sort((a, b) =>
              DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(e['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã: ${e['code']}'),
                      Text('Thời gian: ${_formatDateTime(e['timestamp'])}'),
                      if (e['status'] != null && e['status'].toString().isNotEmpty)
                        Text(
                          e['status'],
                          style: TextStyle(
                            color: e['status'] == 'Đi trễ' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
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
    );
  }
}