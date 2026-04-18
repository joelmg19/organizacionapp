import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/theme_provider.dart';
import 'package:producti_app/providers/user_provider.dart';
import 'package:producti_app/providers/settings_provider.dart';
import 'package:producti_app/providers/event_provider.dart'; // Necesario para la sincronización
import 'package:producti_app/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Perfil Real
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.blue,
                child: Text(userProvider.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(userProvider.userName),
              subtitle: Text(userProvider.user?.email ?? 'Sin correo vinculado'),
            ),
          ),

          _buildSectionTitle('Apariencia'),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar entre tema claro y oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: AppColors.blue),
          ),

          const Divider(),
          _buildSectionTitle('Notificaciones'),
          SwitchListTile(
            title: const Text('Notificaciones Push'),
            value: settingsProvider.pushNotifications,
            onChanged: (value) => settingsProvider.togglePushNotifications(value),
            secondary: const Icon(Icons.notifications, color: AppColors.blue),
          ),
          SwitchListTile(
            title: const Text('Recordatorios Diarios'),
            value: settingsProvider.dailyReminders,
            onChanged: (value) => settingsProvider.toggleDailyReminders(value),
            secondary: const Icon(Icons.alarm, color: AppColors.orange),
          ),

          const Divider(),
          _buildSectionTitle('Calendario y Sincronización'),
          SwitchListTile(
            title: const Text('Sincronizar con Google'),
            subtitle: const Text('Importar eventos del calendario del sistema'),
            value: settingsProvider.systemCalendarSync,
            onChanged: (value) async {
              await settingsProvider.toggleSystemCalendarSync(value);
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitando permisos de calendario...')));
                await eventProvider.syncDeviceCalendars();
              } else {
                eventProvider.clearDeviceEvents();
              }
            },
            secondary: const Icon(Icons.sync, color: AppColors.green),
          ),

          const Divider(),
          _buildSectionTitle('Privacidad'),
          SwitchListTile(
            title: const Text('Bloqueo con PIN'),
            subtitle: const Text('Proteger la app al iniciar'),
            value: settingsProvider.pinLock,
            onChanged: (value) => settingsProvider.togglePinLock(value),
            secondary: const Icon(Icons.lock, color: AppColors.red),
          ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                userProvider.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}