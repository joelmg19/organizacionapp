import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:producti_app/providers/habit_provider.dart';
import 'package:producti_app/models/habit.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'package:producti_app/screens/add_habit_screen.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController(text: '💧'); // Emoji por defecto
  Frequency _selectedFrequency = Frequency.daily;
  int _goal = 7;
  Color _selectedColor = AppColors.blue;
  bool _isLoading = false;

  final List<Color> _colors = [
    AppColors.blue, AppColors.green, AppColors.purple, AppColors.orange, AppColors.red
  ];

  void _saveHabit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    setState(() => _isLoading = true);

    final newHabit = Habit(
      name: _nameController.text.trim(),
      icon: _iconController.text.trim().isEmpty ? '🎯' : _iconController.text.trim(),
      color: _selectedColor,
      frequency: _selectedFrequency,
      currentStreak: 0,
      longestStreak: 0,
      completedDates: [],
      goal: _goal,
    );

    await Provider.of<HabitProvider>(context, listen: false).addHabit(newHabit);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Hábito'),
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveHabit,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _iconController,
                  style: const TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                  maxLength: 2, // Limitar para que sea solo un emoji
                  decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: '🎯'
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Beber agua',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Color del hábito', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _colors.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 25,
                  child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Frecuencia', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: DropdownButton<Frequency>(
              value: _selectedFrequency,
              underline: const SizedBox(),
              items: Frequency.values.map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f == Frequency.daily ? 'Diaria' : 'Semanal')
              )).toList(),
              onChanged: (val) => setState(() => _selectedFrequency = val!),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Meta objetivo', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Veces para completar la racha'),
            trailing: SizedBox(
              width: 50,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (val) => _goal = int.tryParse(val) ?? 7,
                decoration: InputDecoration(
                  hintText: _goal.toString(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}