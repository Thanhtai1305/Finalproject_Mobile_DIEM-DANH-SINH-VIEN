import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Screens
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'student_list_screen.dart';
import 'attendance_history_screen.dart';
import 'attendance_statistics_screen.dart';
import 'main_navigation_screen.dart';

// Notifications
import 'services/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _requestNotificationPermissions() async {
  final status = await Permission.notification.status;
  if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _requestNotificationPermissions();        // 🔒 Yêu cầu quyền
  await NotificationService.initialize();         // 🔔 Khởi tạo notification
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống điểm danh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/student-list': (context) => const StudentListScreen(),
        '/attendance-history': (context) => const AttendanceHistoryScreen(),
        '/attendance-statistics': (context) => const AttendanceStatisticsScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const MainNavigationScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
