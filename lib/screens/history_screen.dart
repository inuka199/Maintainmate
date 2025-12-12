
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/service_record.dart';
import '../providers/service_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _filterItem;
  String _filterNameQuery = '';
  // Cost Range could be added, keeping simple for now as per "simple list view" first
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service History')),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by type or notes...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => _filterNameQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<ServiceProvider>(builder: (context, provider, child) {
                  final items = provider.uniqueItems;
                  return DropdownButton<String>(
                    value: _filterItem,
                    hint: const Text("All Items"),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All Items")),
                      ...items.map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    ],
                    onChanged: (val) => setState(() => _filterItem = val),
                  );
                }),
              ],
            ),
          ),
          
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Apply Filters
                final filteredRecords = provider.records.where((r) {
                  final matchesItem = _filterItem == null || r.itemName == _filterItem;
                  final matchesQuery = _filterNameQuery.isEmpty || 
                      r.type.toLowerCase().contains(_filterNameQuery.toLowerCase()) || 
                      (r.notes?.toLowerCase().contains(_filterNameQuery.toLowerCase()) ?? false);
                  return matchesItem && matchesQuery;
                }).toList();

                if (filteredRecords.isEmpty) {
                  return const Center(child: Text("No records found"));
                }

                // Group by Item if no specific item selected, or just list sorted by date
                // User asked for "group by item".
                // If "All Items" selected, we construct a grouped view.
                
                final grouped = <String, List<ServiceRecord>>{};
                for (var r in filteredRecords) {
                  if (!grouped.containsKey(r.itemName)) grouped[r.itemName] = [];
                  grouped[r.itemName]!.add(r);
                }

                return ListView(
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.grey[200],
                          width: double.infinity,
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ...entry.value.map((record) => _buildRecordItem(context, record, provider)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, ServiceRecord record, ServiceProvider provider) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Record?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.deleteRecord(record.id);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.build, color: Colors.blue),
        ),
        title: Text(record.type, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('yyyy-MM-dd').format(record.date)),
            if (record.notes != null && record.notes!.isNotEmpty)
              Text(record.notes!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Text(
          'Rs ${record.cost.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        onTap: () {
          // Could show details dialog
        },
      ),
    );
  }
}
