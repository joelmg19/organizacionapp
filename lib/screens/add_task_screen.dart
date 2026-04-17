import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/task_provider.dart';
import 'package:producti_app/models/task.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:producti_app/screens/add_task_screen.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Priority _selectedPriority = Priority.medium;
  bool _isLoading = false;

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }

    setState(() => _isLoading = true);

    final newTask = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      status: TaskStatus.todo,
      category: 'General',
      dueDate: _selectedDate,
      completed: false,
    );

    await Provider.of<TaskProvider>(context, listen: false).addTask(newTask);

    if (mounted) {
      Navigator.pop(context); // Cierra la pantalla y vuelve a la lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tarea'),
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveTask,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '¿Qué necesitas hacer?',
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Añade detalles o notas...',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.blue),
            title: const Text('Fecha límite'),
            subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: AppColors.orange),
            title: const Text('Prioridad'),
            trailing: DropdownButton<Priority>(
              value: _selectedPriority,
              underline: const SizedBox(),
              items: Priority.values.map((Priority p) {
                return DropdownMenuItem<Priority>(
                  value: p,
                  child: Text(p.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (Priority? newValue) {
                if (newValue != null) setState(() => _selectedPriority = newValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}