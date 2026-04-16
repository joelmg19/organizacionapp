import 'package:flutter/material.dart';
import 'package:producti_app/models/calendar_event.dart';
import 'package:producti_app/data/mock_data.dart';

class EventProvider extends ChangeNotifier {
  List<CalendarEvent> _events = [];

  EventProvider() {
    _events = List.from(MockData.mockEvents);
  }

  List<CalendarEvent> get events => _events;

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.startTime.year == day.year &&
             event.startTime.month == day.month &&
             event.startTime.day == day.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<CalendarEvent> get todayEvents {
    return getEventsForDay(DateTime.now());
  }

  List<CalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) => event.startTime.isAfter(now))
        .toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(CalendarEvent event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }

  Map<DateTime, List<CalendarEvent>> getMonthlyEventMap(DateTime month) {
    final Map<DateTime, List<CalendarEvent>> eventMap = {};
    
    for (var event in _events) {
      if (event.startTime.year == month.year && 
          event.startTime.month == month.month) {
        final dateKey = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        eventMap.putIfAbsent(dateKey, () => []);
        eventMap[dateKey]!.add(event);
      }
    }
    
    return eventMap;
  }
}
