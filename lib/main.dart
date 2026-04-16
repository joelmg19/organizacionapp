import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/providers/habit_provider.dart';
import 'package:producti_app/providers/event_provider.dart';
import 'package:producti_app/providers/user_provider.dart';
import 'package:producti_app/providers/theme_provider.dart';
import 'package:producti_app/theme/app_theme.dart';
import 'package:producti_app/screens/main_layout.dart';
import 'package:intl/date_symbol_data_local.dart';

// 1. Nuevas importaciones de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase utilizando las opciones generadas por FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa los datos locales para las fechas en español (Chile)
  await initializeDateFormatting('es_CL', null);

  // Arranca la aplicación
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ProductiApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainLayout(),
          );
        },
      ),
    );
  }
}