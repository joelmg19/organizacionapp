import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:producti_app/providers/event_provider.dart';
import 'package:producti_app/providers/settings_provider.dart'; // Importado
import 'package:producti_app/theme/app_colors.dart';
import 'package:producti_app/screens/add_event_screen.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final selectedEvents = eventProvider.events.where((event) =>
    event.startTime.year == _selectedDay!.year &&
        event.startTime.month == _selectedDay!.month &&
        event.startTime.day == _selectedDay!.day
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          // BOTÓN DE SINCRONIZACIÓN CON GOOGLE/SISTEMA
          IconButton(
            icon: Icon(
                Icons.sync,
                color: settingsProvider.systemCalendarSync ? Colors.green : Colors.white
            ),
            tooltip: 'Sincronizar con Google',
            onPressed: () async {
              if (!settingsProvider.systemCalendarSync) {
                // Si está apagado en ajustes, preguntamos si quiere activarlo
                _showSyncDialog(context, settingsProvider, eventProvider);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronizando eventos...'))
                );
                await eventProvider.syncDeviceCalendars();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.blue.withOpacity(0.3), shape: BoxShape.circle),
            ),
            eventLoader: (day) {
              return eventProvider.events.where((event) =>
              event.startTime.year == day.year &&
                  event.startTime.month == day.month &&
                  event.startTime.day == day.day
              ).toList();
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(child: Text('No hay eventos este día'))
                : ListView.builder(
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 12,
                      decoration: BoxDecoration(
                          color: event.color,
                          borderRadius: BorderRadius.circular(4)
                      ),
                    ),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${DateFormat('HH:mm').format(event.startTime)} - ${event.category}'),
                    trailing: event.isDeviceEvent
                        ? const Icon(Icons.smartphone, size: 16, color: Colors.grey)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEventScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSyncDialog(BuildContext context, SettingsProvider settings, EventProvider events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sincronizar Calendario'),
        content: const Text('¿Deseas vincular los eventos de tu cuenta de Google y del sistema con la aplicación?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await settings.toggleSystemCalendarSync(true);
                await events.syncDeviceCalendars();
              },
              child: const Text('Vincular ahora')
          ),
        ],
      ),
    );
  }
}