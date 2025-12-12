
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/service_record.dart';
import '../providers/service_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Consumer<ServiceProvider>(
        builder: (context, provider, child) {
          if (provider.records.isEmpty) {
            return const Center(child: Text("No data for reports"));
          }
          
          final totalCost = provider.totalCost;
          final byItem = provider.recordsByItem;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total Summary
              Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("Total Expenses", style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text("Rs ${totalCost.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text("Cost per Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...byItem.entries.map((e) {
                final itemTotal = e.value.fold(0.0, (sum, r) => sum + r.cost);
                final percent = totalCost > 0 ? itemTotal / totalCost : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key),
                          Text("Rs ${itemTotal.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: percent, backgroundColor: Colors.grey[200], color: _getColorForIndex(e.key.hashCode)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              const Text("Monthly Maintenance Cost", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxMonthlyCost(provider.records) * 1.2,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(_getMonthLabel(value.toInt()), style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _getMonthlyData(provider.records),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    return colors[index.abs() % colors.length];
  }

  double _getMaxMonthlyCost(List<ServiceRecord> records) {
    final monthly = _calculateMonthlyCosts(records);
    if (monthly.isEmpty) return 100;
    return monthly.values.reduce((curr, next) => curr > next ? curr : next);
  }

  Map<int, double> _calculateMonthlyCosts(List<ServiceRecord> records) {
    Map<int, double> monthly = {};
    for (var r in records) {
      // Simple logic: Group by month index (0-11) of current year, or just generic months
      // Better: Group by Month-Year but chart space is limited. 
      // Let's assume show last 6 months or just group by month of year purely for demo
      // User asked "Monthly maintenance cost". Let's show current year months.
      if (r.date.year == DateTime.now().year) {
        monthly[r.date.month] = (monthly[r.date.month] ?? 0) + r.cost;
      }
    }
    return monthly;
  }

  List<BarChartGroupData> _getMonthlyData(List<ServiceRecord> records) {
    final monthly = _calculateMonthlyCosts(records);
    return List.generate(12, (index) {
      final monthIndex = index + 1;
      return BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: monthly[monthIndex] ?? 0,
            color: Colors.blueAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  String _getMonthLabel(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
