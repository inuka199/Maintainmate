

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:uuid/uuid.dart';
import '../models/service_record.dart';
import '../providers/service_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextDate;
  


  @override
  void dispose() {
    _itemController.dispose();
    _typeController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }



  Future<void> _selectDate(BuildContext context, bool isNextDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNextDate 
          ? (_nextDate ?? DateTime.now().add(const Duration(days: 90))) 
          : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isNextDate) {
          _nextDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  bool _isSaving = false;

  void _submit() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final itemName = _itemController.text;
      if (itemName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or enter an item name')),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        // Create the record
        final record = ServiceRecord(
          id: _uuid.v4(),
          itemName: itemName,
          type: _typeController.text,
          date: _selectedDate,
          cost: double.tryParse(_costController.text) ?? 0.0,
          notes: _notesController.text,
          nextDate: _nextDate,
        );

        // Attempt to save with a timeout
        // valid for offline support where firestore might take time to confirm with server
        await Provider.of<ServiceProvider>(context, listen: false)
            .addRecord(record)
            .timeout(const Duration(seconds: 5), onTimeout: () {
              // If it times out, we assume it's queued for offline sync
              return;
            });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving record: $e')),
          );
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Record')),
      body: Consumer<ServiceProvider>(
        builder: (context, provider, child) {
          final items = provider.uniqueItems;
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Item Selection
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return items.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _itemController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Initialize controller with current value if needed
                    if (_itemController.text.isNotEmpty && controller.text.isEmpty) {
                         controller.text = _itemController.text;
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: '(e.g. Toyota Camry)',
                        hintText: 'Select or type item name',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter item name' : null,
                      onSaved: (value) => _itemController.text = value ?? '',
                    );
                  },
                ),

                const SizedBox(height: 16),
                
                // Service Type
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Service/Repair Type'),
                  validator: (value) => value!.isEmpty ? 'Enter service type' : null,
                ),

                const SizedBox(height: 16),
                
                // Date
                ListTile(
                  title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),
                
                // Cost
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost',
                    prefixText: 'Rs ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter cost';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Optional Notes'),
                  maxLines: 3,
                ),



                const SizedBox(height: 16),
                
                // Next Date
                ListTile(
                  title: Text(_nextDate == null 
                      ? 'Set Next Maintenance Reminder' 
                      : 'Next Due: ${DateFormat('yyyy-MM-dd').format(_nextDate!)}'),
                  trailing: const Icon(Icons.notifications_active),
                  tileColor: _nextDate != null ? Colors.orange[100] : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => _selectDate(context, true),
                ),

                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Record', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
