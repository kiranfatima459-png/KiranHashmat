import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';

class PlantDialog extends StatefulWidget {
  final Plant? plant;

  const PlantDialog({super.key, this.plant});

  @override
  State<PlantDialog> createState() => _PlantDialogState();
}

class _PlantDialogState extends State<PlantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _freqController;
  late TextEditingController _photoUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant?.name ?? '');
    _speciesController = TextEditingController(text: widget.plant?.species ?? '');
    _freqController = TextEditingController(text: widget.plant?.wateringFrequency.toString() ?? '7');
    _photoUrlController = TextEditingController(text: widget.plant?.photoUrl ?? '');
  }

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
    final isEditing = widget.plant != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? "Modify Essence" : "Summon New Life",
                    style: GoogleFonts.philosopher(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildField(_nameController, 'Plant Name', Icons.badge_outlined),
                  const SizedBox(height: 16),
                  _buildField(_speciesController, 'Species (e.g. Aloe)', Icons.eco_outlined),
                  const SizedBox(height: 16),
                  _buildField(_freqController, 'Watering Interval (Days)', Icons.timer_outlined, isNumber: true),
                  const SizedBox(height: 16),
                  _buildField(_photoUrlController, 'Portrait URL', Icons.camera_alt_outlined),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Return", style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00C853).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              isEditing ? "Save Changes" : "Create Magic",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        filled: true,
        fillColor: const Color(0xFFF1F8E9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: Colors.green[800], fontSize: 14),
      ),
      validator: (value) => value == null || value.isEmpty ? "Required field" : null,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final plant = Plant(
        id: widget.plant?.id ?? '',
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        wateringFrequency: int.parse(_freqController.text),
        lastWatered: widget.plant?.lastWatered ?? DateTime.now(),
        photoUrl: _photoUrlController.text.trim().isNotEmpty ? _photoUrlController.text.trim() : null,
      );
      Navigator.pop(context, plant);
    }
  }
}
