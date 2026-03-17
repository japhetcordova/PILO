import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../domain/models/meal_record.dart';
import 'meal_providers.dart';

class MealCalendarScreen extends ConsumerStatefulWidget {
  const MealCalendarScreen({super.key});

  @override
  ConsumerState<MealCalendarScreen> createState() => _MealCalendarScreenState();
}

class _MealCalendarScreenState extends ConsumerState<MealCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<MealRecord> _getEventsForDay(DateTime day, List<MealRecord> allRecords) {
    return allRecords.where((record) {
      return isSameDay(record.date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(mealRecordsProvider);
    final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!, allRecords) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEAL TRACKER'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => _getEventsForDay(day, allRecords),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDay != null 
                        ? DateFormat('EEEE, MMMM d').format(_selectedDay!).toUpperCase()
                        : 'SELECT A DAY',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: selectedEvents.isEmpty
                        ? const Center(child: Text('No meals recorded for this day.'))
                        : ListView.builder(
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              final record = selectedEvents[index] as MealRecord;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: _buildMealIcon(record.mealType),
                                  title: Text(record.recipeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(record.mealType),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    onPressed: () => ref.read(mealRecordsProvider.notifier).deleteRecord(record.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealIcon(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'breakfast':
        icon = Icons.wb_sunny_outlined;
        color = Colors.orange;
        break;
      case 'lunch':
        icon = Icons.light_mode;
        color = Colors.blue;
        break;
      case 'dinner':
        icon = Icons.nightlight_round;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
