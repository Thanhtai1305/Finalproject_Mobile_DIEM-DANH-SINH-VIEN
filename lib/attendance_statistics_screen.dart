import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceStatisticsScreen extends StatefulWidget {
  const AttendanceStatisticsScreen({super.key});

  @override
  State<AttendanceStatisticsScreen> createState() => _AttendanceStatisticsScreenState();
}

class _AttendanceStatisticsScreenState extends State<AttendanceStatisticsScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Sinhvien');
  Map<String, int> _attendanceByStudent = {};
  int _totalAttendance = 0;
  Map<String, int> _attendanceByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final snapshot = await _dbRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _attendanceByStudent.clear();
        _attendanceByDate.clear();
        _totalAttendance = 0;

        data.forEach((studentName, studentData) {
          if (studentData is Map<dynamic, dynamic>) {
            studentData.forEach((key, value) {
              if (value is Map<dynamic, dynamic>) {
                final timestamp = value['timestamp']?.toString();
                if (timestamp != null) {
                  _totalAttendance++;
                  _attendanceByStudent[studentName] = (_attendanceByStudent[studentName] ?? 0) + 1;

                  try {
                    final dateTime = DateTime.parse(timestamp).toLocal();
                    final date = DateFormat('dd/MM/yyyy').format(dateTime);
                    _attendanceByDate[date] = (_attendanceByDate[date] ?? 0) + 1;
                  } catch (e) {
                    print('Lỗi định dạng ngày: $timestamp');
                  }
                }
              }
            });
          }
        });
      }
    } catch (e) {
      print('Lỗi khi tải thống kê: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê điểm danh'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStatistics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _totalAttendance == 0
              ? const Center(child: Text('Chưa có dữ liệu điểm danh để thống kê.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildStatCard(
                        title: 'Tổng số lần điểm danh',
                        value: _totalAttendance.toString(),
                        icon: Icons.assignment_turned_in,
                        color: Colors.purple[100]!,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Thống kê theo sinh viên'),
                      _buildStudentStatistics(),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Thống kê theo ngày'),
                      _buildDateStatistics(),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Biểu đồ thống kê theo ngày'),
                      _buildChart(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple[700],
        ),
      ),
    );
  }

  Widget _buildStudentStatistics() {
    final sortedStudents = _attendanceByStudent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var entry in sortedStudents)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text('${entry.value} lần'),
                      backgroundColor: Colors.purple[100],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStatistics() {
    final sortedDates = _attendanceByDate.entries.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var entry in sortedDates)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Chip(
                      label: Text('${entry.value} lần'),
                      backgroundColor: Colors.purple[100],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.purple[700]),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.purple[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final sortedDates = _attendanceByDate.entries.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < sortedDates.length) {
                        final date = sortedDates[index].key;
                        return Text(date.split('/').first); // hiển thị ngày
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 32,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 28,
                    interval: 1,
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(sortedDates.length, (index) {
                final entry = sortedDates[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(4),
                      width: 16,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
