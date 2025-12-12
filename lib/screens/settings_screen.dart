
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/service_record.dart';
import '../providers/service_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = Provider.of<ServiceProvider>(context, listen: false);
      final records = provider.records;
      final exportList = records.map((r) {
        var map = r.toMap();
        // Convert Timestamps to ISO Strings for JSON
        map['date'] = r.date.toIso8601String();
        if (r.nextDate != null) map['nextDate'] = r.nextDate!.toIso8601String();
        // Remove id to avoid conflicts on import or keep it? Keep it for update checks.
        return map;
      }).toList();

      final jsonString = jsonEncode(exportList);
      
      final xFile = XFile.fromData(
        utf8.encode(jsonString),
        mimeType: 'application/json',
        name: 'service_records_export.json',
      );
      
      await Share.shareXFiles([xFile], text: 'Service App Backup');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final pickedFile = result.files.single;
        String content;
        
        if (pickedFile.path != null) {
          // Mobile/Desktop with path
          content = await XFile(pickedFile.path!).readAsString();
        } else if (pickedFile.bytes != null) {
          // Web or bytes provided
          content = utf8.decode(pickedFile.bytes!);
        } else {
          throw Exception('Cannot read file content');
        }

        List<dynamic> jsonList = jsonDecode(content);
        
        final provider = Provider.of<ServiceProvider>(context, listen: false);
        int count = 0;
        
        for (var map in jsonList) {
          // Convert ISO strings back to Timestamps/Dates or handle in specific helper
          // Our model fromMap expects Timestamps for firestore.
          // Depending on how strict we are, we might need a separate fromJson or adjust.
          // Simpler: Manual mapping here.
          
          try {
             String id = map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
             DateTime date = DateTime.parse(map['date']);
             DateTime? nextDate = map['nextDate'] != null ? DateTime.parse(map['nextDate']) : null;
             
             ServiceRecord record = ServiceRecord(
               id: id,
               itemName: map['itemName'],
               type: map['type'],
               date: date,
               cost: (map['cost'] as num).toDouble(),
               notes: map['notes'],
               nextDate: nextDate,
             );
             
             await provider.addRecord(record);
             count++;
          } catch (e) {
            print("Skipping invalid record: $e");
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $count records')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Backup your records to a JSON file'),
            onTap: () => _exportData(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a JSON file'),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }
}
