
import 'package:flutter/foundation.dart';
import '../models/service_record.dart';
import '../services/database_service.dart';

class ServiceProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<ServiceRecord> _records = [];
  bool _isLoading = false;

  List<ServiceRecord> get records => _records;
  bool get isLoading => _isLoading;

  // Stream subscription could be used, but for simplicity we might just listen in UI or here.
  // Better to expose a Stream or use StreamProvider, but let's stick to ChangeNotifier for logic encapsulation.
  // Actually, for real-time updates, listening to the stream here is good.

  ServiceProvider() {
    _listenToRecords();
  }

  void _listenToRecords() {
    _isLoading = true;
    // notifyListeners(); // Removed to avoid calling during build if lazily created
    
    _databaseService.getRecords().listen((records) {
      _records = records;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
       print("Error listening to records: $error");
       _isLoading = false;
       notifyListeners();
    });
  }

  Future<void> addRecord(ServiceRecord record) async {
    await _databaseService.addRecord(record);
  }

  Future<void> deleteRecord(String id) async {
    await _databaseService.deleteRecord(id);
  }

  // Get unique items for dropdown
  List<String> get uniqueItems {
    return _records.map((e) => e.itemName).toSet().toList();
  }
  
  // Calculate total cost
  double get totalCost {
    return _records.fold(0.0, (sum, item) => sum + item.cost);
  }

  // Group by item
  Map<String, List<ServiceRecord>> get recordsByItem {
    Map<String, List<ServiceRecord>> grouped = {};
    for (var record in _records) {
      if (!grouped.containsKey(record.itemName)) {
        grouped[record.itemName] = [];
      }
      grouped[record.itemName]!.add(record);
    }
    return grouped;
  }
}
