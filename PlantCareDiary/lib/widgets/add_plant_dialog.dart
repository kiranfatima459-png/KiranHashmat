import 'package:flutter/material.dart';
import '../models/plant.dart';

class AddPlantDialog extends StatefulWidget {
  const AddPlantDialog({super.key});

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _freqController = TextEditingController(text: '7');
  final _photoUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _freqController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Plant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plant Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.eco),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _freqController,
                decoration: const InputDecoration(
                  labelText: 'Watering Frequency (days)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value!) == null ? 'Enter a number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Photo URL (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final plant = Plant(
                id: '', // Supabase will generate UUID
                name: _nameController.text,
                species: _speciesController.text,
                wateringFrequency: int.parse(_freqController.text),
                lastWatered: DateTime.now(),
                photoUrl: _photoUrlController.text.isNotEmpty ? _photoUrlController.text : null,
              );
              Navigator.pop(context, plant);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
