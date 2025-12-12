
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import 'add_record_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'upcoming_services_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Tracker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Summary Cards
                        Consumer<ServiceProvider>(
                          builder: (context, provider, child) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Upcoming Service',
                                    _getNextServiceDate(provider),
                                    Colors.orangeAccent,
                                    Icons.calendar_today,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const UpcomingServicesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Total Cost',
                                    'Rs ${provider.totalCost.toStringAsFixed(2)}',
                                    Colors.greenAccent,
                                    Icons.attach_money,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Main Actions
                        _buildActionButton(
                          context,
                          'Add New Record',
                          Icons.add_circle_outline,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildActionButton(
                          context,
                          'View History',
                          Icons.history,
                          Colors.purple,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryScreen()),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildActionButton(
                          context,
                          'Reports',
                          Icons.bar_chart,
                          Colors.teal,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Decorative Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: Image.asset(
                      'assets/images/vehicle_v3.png',
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getNextServiceDate(ServiceProvider provider) {
    // Logic to find the nearest next date
    // This is a simple implementation, actual logic might need to filter future dates
    final records = provider.records;
    final futureRecords = records
        .where((r) => r.nextDate != null && r.nextDate!.isAfter(DateTime.now()))
        .toList();
    
    if (futureRecords.isEmpty) return "None";
    
    futureRecords.sort((a, b) => a.nextDate!.compareTo(b.nextDate!));
    return DateFormat('MMM dd, yyyy').format(futureRecords.first.nextDate!);
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color, IconData icon, {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      clipBehavior: Clip.hardEdge, // Ensure ink splash is clipped
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
