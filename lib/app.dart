import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/connectivity_utils.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/provider/dashboard_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/admin/services/admin_service.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(authService: AdminService()),
        ),
      ],
      child: MaterialApp(
        title: 'EduGenius',
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
          Locale('fr', ''), // French
          Locale('de', ''), // German
          Locale('zh', ''), // Chinese
          Locale('hi', ''), // Hindi
          Locale('ar', ''), // Arabic
        ],
        home: ConnectivityMonitor(
          child: _buildHomeScreen(context),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final status = authProvider.status;
    
    // Show loading indicator while checking authentication status
    if (status == AuthStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show dashboard if authenticated, login screen otherwise
    return status == AuthStatus.authenticated
        ? const DashboardScreen()
        : const LoginScreen();
  }
}