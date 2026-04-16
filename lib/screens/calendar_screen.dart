import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:producti_app/providers/event_provider.dart';
import 'package:producti_app/models/calendar_event.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

enum CalendarView { day, week, month }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarView _currentView = CalendarView.month;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final selectedEvents = eventProvider.getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // View Tabs
          Container(
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: _buildViewTab('Día', CalendarView.day),
                ),
                Expanded(
                  child: _buildViewTab('Semana', CalendarView.week),
                ),
                Expanded(
                  child: _buildViewTab('Mes', CalendarView.month),
                ),
              ],
            ),
          ),

          // Calendar
          if (_currentView == CalendarView.month)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) => eventProvider.getEventsForDay(day),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // Events List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  DateFormat('EEEE, d \'de\' MMMM', 'es').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No hay eventos para este día'),
                    ),
                  )
                else
                  ...selectedEvents.map((event) => _buildEventCard(event)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de crear evento próximamente')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildViewTab(String label, CalendarView view) {
    final isSelected = _currentView == view;
    return InkWell(
      onTap: () {
        setState(() {
          _currentView = view;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final timeStr = DateFormat('HH:mm').format(event.startTime);
    final endTimeStr = DateFormat('HH:mm').format(event.endTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 4,
          height: double.infinity,
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(event.title),
        subtitle: Text('$timeStr - $endTimeStr • ${event.category}'),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: event.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
