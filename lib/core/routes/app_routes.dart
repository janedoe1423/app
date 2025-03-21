import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/teacher_dashboard/screens/dashboard_screen.dart';
import '../../features/teacher_dashboard/screens/create_assessment_page.dart';
import '../models/user_model.dart';
import '../../features/teacher_dashboard/screens/student_analysis_page.dart';
import '../../features/teacher_dashboard/screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String createAssessment = '/create-assessment';
  static const String studentAnalysis = '/student-analysis';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );

      case teacherDashboard:
        return MaterialPageRoute(
          builder: (_) => const TeacherDashboardScreen(),
        );

      case createAssessment:
        return MaterialPageRoute(
          builder: (_) => const CreateAssessmentPage(),
        );

      case studentAnalysis:
        return MaterialPageRoute(
          builder: (_) => const StudentAnalysisPage(),
        );

      case AppRoutes.settings:
      return MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}