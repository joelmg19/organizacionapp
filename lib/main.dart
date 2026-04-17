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
// Importación de la nueva pantalla de autenticación
import 'package:producti_app/screens/auth_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importaciones de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase utilizando las opciones generadas por FlutterFire
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
      // Utilizamos Consumer2 para escuchar los cambios del ThemeProvider y del UserProvider
      child: Consumer2<ThemeProvider, UserProvider>(
        builder: (context, themeProvider, userProvider, child) {
          return MaterialApp(
            title: 'ProductiApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // Lógica mágica: Si está autenticado muestra la app, si no, muestra el login
            home: userProvider.isAuthenticated
                ? const MainLayout()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}