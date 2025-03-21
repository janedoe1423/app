import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/utils/connectivity_utils.dart';
import 'core/utils/admin_initializer.dart';
import 'core/services/auth_service.dart';
import 'features/auth/provider/auth_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize connectivity utils
  ConnectivityUtils().init();

  // Ensure admin account exists
  await AdminInitializer.ensureAdminExists();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize secure storage
  const secureStorage = FlutterSecureStorage();

  // Initialize services
  final authService = AuthService();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Teacher Dashboard',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
}