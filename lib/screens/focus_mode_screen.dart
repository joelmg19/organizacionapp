import 'dart:async';
import 'package:flutter/material.dart';
import 'package:producti_app/theme/app_colors.dart';
import 'dart:math' as math;

enum FocusPhase { focus, shortBreak, longBreak }

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  bool _isActive = false;
  int _timeLeft = 25 * 60; // 25 minutes in seconds
  FocusPhase _phase = FocusPhase.focus;
  int _sessionsCompleted = 0;
  bool _soundEnabled = true;
  Timer? _timer;

  final Map<FocusPhase, int> _phaseDurations = {
    FocusPhase.focus: 25 * 60,
    FocusPhase.shortBreak: 5 * 60,
    FocusPhase.longBreak: 15 * 60,
  };

  final Map<FocusPhase, String> _phaseLabels = {
    FocusPhase.focus: 'Modo Enfoque',
    FocusPhase.shortBreak: 'Descanso Corto',
    FocusPhase.longBreak: 'Descanso Largo',
  };

  final Map<FocusPhase, List<Color>> _phaseGradients = {
    FocusPhase.focus: AppColors.indigoGradient,
    FocusPhase.shortBreak: AppColors.greenGradient,
    FocusPhase.longBreak: AppColors.blueGradient,
  };

  final List<String> _motivationalQuotes = [
    'Mantén el enfoque en tus objetivos',
    'Cada minuto cuenta hacia tu éxito',
    'La concentración es la clave de la excelencia',
    'Estás haciendo un gran trabajo',
    'Tus metas están más cerca de lo que piensas',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _handlePhaseComplete();
        }
      });
    });
  }

  void _handlePhaseComplete() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      
      if (_phase == FocusPhase.focus) {
        _sessionsCompleted++;
        
        if (_sessionsCompleted % 4 == 0) {
          _phase = FocusPhase.longBreak;
          _timeLeft = _phaseDurations[FocusPhase.longBreak]!;
        } else {
          _phase = FocusPhase.shortBreak;
          _timeLeft = _phaseDurations[FocusPhase.shortBreak]!;
        }
      } else {
        _phase = FocusPhase.focus;
        _timeLeft = _phaseDurations[FocusPhase.focus]!;
      }
    });

    _showPhaseCompleteDialog();
  }

  void _showPhaseCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Fase Completada!'),
        content: Text(
          _phase == FocusPhase.focus
              ? '¡Sesión completada! Toma un descanso'
              : '¡Descanso completado! Comencemos a trabajar',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetTimer() {
    setState(() {
      _isActive = false;
      _timer?.cancel();
      _timeLeft = _phaseDurations[_phase]!;
    });
  }

  void _skipPhase() {
    setState(() {
      _timeLeft = 0;
    });
  }

  void _setPhase(FocusPhase phase) {
    setState(() {
      _phase = phase;
      _timeLeft = _phaseDurations[phase]!;
      _isActive = false;
      _timer?.cancel();
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progressPercent {
    return (_phaseDurations[_phase]! - _timeLeft) / _phaseDurations[_phase]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _phaseGradients[_phase]!,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _phaseLabels[_phase]!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Timer Circle
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: _progressPercent,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_timeLeft),
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isActive ? 'En progreso...' : 'Pausado',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: _resetTimer,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.refresh, color: Colors.white),
                        ),
                        const SizedBox(width: 24),
                        FloatingActionButton.large(
                          onPressed: _toggleTimer,
                          backgroundColor: Colors.white,
                          child: Icon(
                            _isActive ? Icons.pause : Icons.play_arrow,
                            color: _phaseGradients[_phase]![0],
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 24),
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _soundEnabled = !_soundEnabled;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(
                            _soundEnabled ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: _skipPhase,
                      child: const Text(
                        'Saltar fase',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats & Info
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              '"${_motivationalQuotes[_sessionsCompleted % _motivationalQuotes.length]}"',
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      _sessionsCompleted.toString(),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'Sesiones',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${(_sessionsCompleted * 25) ~/ 60}h ${(_sessionsCompleted * 25) % 60}m',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'Tiempo enfocado',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phase selector
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Cambiar modo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPhaseButton(
                                    '🎯',
                                    'Enfoque',
                                    FocusPhase.focus,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPhaseButton(
                                    '☕',
                                    'Corto',
                                    FocusPhase.shortBreak,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPhaseButton(
                                    '🌴',
                                    'Largo',
                                    FocusPhase.longBreak,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseButton(String emoji, String label, FocusPhase phase) {
    final isSelected = _phase == phase;
    
    return ElevatedButton(
      onPressed: () => _setPhase(phase),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? Colors.white 
            : Colors.white.withOpacity(0.2),
        foregroundColor: isSelected 
            ? _phaseGradients[phase]![0]
            : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
