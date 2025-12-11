
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_record.dart';

class DatabaseService {
  final CollectionReference _recordsCollection =
      FirebaseFirestore.instance.collection('service_records');

  // Add a new record
  Future<void> addRecord(ServiceRecord record) async {
    await _recordsCollection.doc(record.id).set(record.toMap());
  }

  // Get all records stream
  Stream<List<ServiceRecord>> getRecords() {
    return _recordsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceRecord.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Delete a record
  Future<void> deleteRecord(String id) async {
    await _recordsCollection.doc(id).delete();
  }

  // Update a record (optional, reusing addRecord with same ID works for set)
  Future<void> updateRecord(ServiceRecord record) async {
    await _recordsCollection.doc(record.id).update(record.toMap());
  }
}
