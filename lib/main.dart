import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/providers/habit_provider.dart';
import 'package:producti_app/providers/event_provider.dart';
import 'package:producti_app/providers/user_provider.dart';
import 'package:producti_app/providers/theme_provider.dart';
import 'package:producti_app/theme/app_theme.dart';
import 'package:producti_app/screens/main_layout.dart';
import 'package:producti_app/screens/auth_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:producti_app/providers/settings_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// IMPORTACIÓN DEL SERVICIO DE NOTIFICACIONES
import 'package:producti_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // INICIALIZACIÓN DE NOTIFICACIONES
  await NotificationService.init();

  await initializeDateFormatting('es_CL', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer2<ThemeProvider, UserProvider>(
        builder: (context, themeProvider, userProvider, child) {
          return MaterialApp(
            title: 'ProductiApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: userProvider.isAuthenticated
                ? const MainLayout()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}