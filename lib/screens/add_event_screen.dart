import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/event_provider.dart';
import 'package:producti_app/models/calendar_event.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  Color _selectedColor = AppColors.blue;
  bool _isLoading = false;

  final List<Color> _colors = [AppColors.blue, AppColors.green, AppColors.purple, AppColors.orange, AppColors.red];

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time == null) return;

    setState(() {
      if (isStart) {
        _startDate = date;
        _startTime = time;
        // Auto-ajustar el fin
        _endDate = date;
        _endTime = time.replacing(hour: time.hour + 1);
      } else {
        _endDate = date;
        _endTime = time;
      }
    });
  }

  void _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }

    setState(() => _isLoading = true);

    final finalStart = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    final finalEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    final newEvent = CalendarEvent(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startTime: finalStart,
      endTime: finalEnd,
      color: _selectedColor,
    );

    await Provider.of<EventProvider>(context, listen: false).addEvent(newEvent);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Evento'),
        actions: [
          IconButton(
            icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveEvent,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: 'Título del evento', border: InputBorder.none),
          ),
          const Divider(),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Añade una descripción...', border: InputBorder.none),
          ),
          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.access_time, color: AppColors.green),
            title: const Text('Empieza'),
            subtitle: Text('${DateFormat('dd/MM/yyyy').format(_startDate)} - ${_startTime.format(context)}'),
            onTap: () => _pickDateTime(true),
          ),
          ListTile(
            leading: const Icon(Icons.access_time_filled, color: AppColors.red),
            title: const Text('Termina'),
            subtitle: Text('${DateFormat('dd/MM/yyyy').format(_endDate)} - ${_endTime.format(context)}'),
            onTap: () => _pickDateTime(false),
          ),

          const SizedBox(height: 20),
          const Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _colors.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 20,
                  child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}