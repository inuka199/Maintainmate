import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/service_provider.dart';

class UpcomingServicesScreen extends StatelessWidget {
  const UpcomingServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Services Reminder')),
      body: Consumer<ServiceProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          // Filter for future dates, treating today as upcoming/due
          final reminders = provider.records
              .where((r) => r.nextDate != null && 
                  (r.nextDate!.isAfter(now) || DateUtils.isSameDay(r.nextDate!, now)))
              .toList();

          // Sort by nearest date first
          reminders.sort((a, b) => a.nextDate!.compareTo(b.nextDate!));

          if (reminders.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming service reminders.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = reminders[index];
              final dateStr = DateFormat('yyyy-MM-dd').format(record.nextDate!);
              
              // Display format: Item | service type | date
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        record.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('|', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        record.type,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('|', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.blue, 
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
