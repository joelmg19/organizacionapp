import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/theme_provider.dart';
import 'package:producti_app/providers/user_provider.dart'; // Importado para Logout y Datos
import 'package:producti_app/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context); // Obtenemos el Provider del usuario

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Profile Card - Ahora con datos dinámicos de Firebase
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(userProvider.userName), // Nombre real
              subtitle: Text(userProvider.user?.email ?? 'Sin correo vinculado'), // Correo real
              trailing: const Icon(Icons.edit),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editar perfil próximamente')),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Apariencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar entre tema claro y oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.blue,
            ),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SwitchListTile(
            title: const Text('Notificaciones Push'),
            subtitle: const Text('Recibir alertas de tareas y eventos'),
            value: true,
            onChanged: (value) {},
            secondary: const Icon(Icons.notifications, color: AppColors.blue),
          ),

          SwitchListTile(
            title: const Text('Recordatorios'),
            subtitle: const Text('Recordatorios de hábitos diarios'),
            value: true,
            onChanged: (value) {},
            secondary: const Icon(Icons.alarm, color: AppColors.orange),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Calendario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.sync, color: AppColors.green),
            title: const Text('Sincronización'),
            subtitle: const Text('Sincronizar con calendario del sistema'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.language, color: AppColors.blue),
            title: const Text('Zona Horaria'),
            subtitle: const Text('GMT-5 (America/Bogota)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Privacidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SwitchListTile(
            title: const Text('Bloqueo con PIN'),
            subtitle: const Text('Proteger app con código de seguridad'),
            value: false,
            onChanged: (value) {},
            secondary: const Icon(Icons.lock, color: AppColors.red),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppColors.purple),
            title: const Text('Privacidad de Datos'),
            subtitle: const Text('Gestionar tus datos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Soporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.help, color: AppColors.blue),
            title: const Text('Ayuda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.contact_support, color: AppColors.green),
            title: const Text('Contactar Soporte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info, color: AppColors.purple),
            title: const Text('Acerca de'),
            subtitle: const Text('Versión 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Cierra el diálogo
                          // Llama a la función de Firebase para desloguear
                          Provider.of<UserProvider>(context, listen: false).logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                        ),
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Cerrar Sesión'),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}