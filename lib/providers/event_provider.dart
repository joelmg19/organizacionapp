import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_calendar/device_calendar.dart' as dc;
import '../models/calendar_event.dart';

class EventProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dc.DeviceCalendarPlugin _deviceCalendarPlugin = dc.DeviceCalendarPlugin();

  List<CalendarEvent> _firebaseEvents = [];
  List<CalendarEvent> _deviceEvents = [];

  List<CalendarEvent> get events {
    final allEvents = [..._firebaseEvents, ..._deviceEvents];
    allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allEvents;
  }

  List<CalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    return events.where((e) => e.startTime.isAfter(now)).toList();
  }

  EventProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToFirebaseEvents(user.uid);
      } else {
        _firebaseEvents = [];
        _deviceEvents = [];
        notifyListeners();
      }
    });
  }

  void _listenToFirebaseEvents(String userId) {
    _db.collection('users').doc(userId).collection('events')
        .snapshots()
        .listen((snapshot) {
      _firebaseEvents = snapshot.docs.map((doc) => CalendarEvent.fromJson(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  Future<void> addEvent(CalendarEvent event) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('events').doc(event.id).set(event.toJson());
  }

  Future<void> syncDeviceCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) return;
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        _deviceEvents.clear();
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 30));
        final endDate = now.add(const Duration(days: 365));

        for (var cal in calendarsResult.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            cal.id,
            dc.RetrieveEventsParams(startDate: startDate, endDate: endDate),
          );

          if (eventsResult.isSuccess && eventsResult.data != null) {
            for (var e in eventsResult.data!) {
              if (e.start != null && e.end != null) {
                final startDt = DateTime(e.start!.year, e.start!.month, e.start!.day, e.start!.hour, e.start!.minute);
                final endDt = DateTime(e.end!.year, e.end!.month, e.end!.day, e.end!.hour, e.end!.minute);

                _deviceEvents.add(CalendarEvent(
                  id: e.eventId ?? '',
                  title: e.title ?? 'Sin título',
                  description: e.description ?? '',
                  startTime: startDt,
                  endTime: endDt,
                  color: Colors.blueGrey,
                  isDeviceEvent: true,
                  category: 'Sistema', // <- CATEGORÍA AUTOMÁTICA
                ));
              }
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al sincronizar calendario: $e");
    }
  }

  void clearDeviceEvents() {
    _deviceEvents.clear();
    notifyListeners();
  }
}