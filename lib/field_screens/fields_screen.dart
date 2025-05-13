import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:projext/data/field_model.dart';
import 'package:projext/field_screens/field_detail.dart';

class FieldsListScreen extends StatelessWidget {
  const FieldsListScreen({super.key});

  Future<bool> _deleteField(BuildContext context, Field field) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Field'),
            content: Text('Are you sure you want to delete "${field.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final box = Hive.box<Field>('fields');
        await box.delete(field.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deleted "${field.title}"')));
        return true;
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete field: $e')));
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Fields'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Swipe left on a field to delete it'),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Field>>(
        valueListenable: Hive.box<Field>('fields').listenable(),
        builder: (context, box, _) {
          final fields = box.values.toList().cast<Field>();

          if (fields.isEmpty) {
            return const Center(child: Text('No fields saved yet'));
          }

          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              return Dismissible(
                key: Key(field.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await _deleteField(context, field);
                },
                child: ListTile(
                  title: Text(field.title),
                  subtitle: Text(
                    '${field.cropName} - ${field.monthsTillSown} months',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FieldDetailScreen(field: field),
                      ),
                    );
                  },
                  onLongPress: () => _deleteField(context, field),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
