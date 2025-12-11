import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRecord {
  final String id;
  final String itemName;
  final String type;
  final DateTime date;
  final double cost;
  final String? notes;

  final DateTime? nextDate;

  ServiceRecord({
    required this.id,
    required this.itemName,
    required this.type,
    required this.date,
    required this.cost,
    this.notes,
    this.nextDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'type': type,
      'date': Timestamp.fromDate(date),
      'cost': cost,
      'notes': notes,
      'nextDate': nextDate != null ? Timestamp.fromDate(nextDate!) : null,
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceRecord(
      id: docId,
      itemName: map['itemName'] ?? '',
      type: map['type'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      cost: (map['cost'] as num).toDouble(),
      notes: map['notes'],
      nextDate: map['nextDate'] != null ? (map['nextDate'] as Timestamp).toDate() : null,
    );
  }
}
