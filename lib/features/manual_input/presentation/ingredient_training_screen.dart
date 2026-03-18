import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../inventory/domain/models/custom_ingredient.dart';

class IngredientTrainingScreen extends ConsumerStatefulWidget {
  final String initialName;

  const IngredientTrainingScreen({super.key, this.initialName = ''});

  @override
  ConsumerState<IngredientTrainingScreen> createState() => _IngredientTrainingScreenState();
}

class _IngredientTrainingScreenState extends ConsumerState<IngredientTrainingScreen> {
  late TextEditingController _nameController;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _usesController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _usesController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _saveTraining() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<CustomIngredient>('custom_ingredients');
      final newIngredient = CustomIngredient(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        commonUses: _usesController.text.trim(),
        color: _colorController.text.trim(),
        dateAdded: DateTime.now(),
      );

      await box.put(newIngredient.id, newIngredient);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Taught Pilo about ${_nameController.text}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teach Pilo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help Pilo learn about local ingredients',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This offline knowledge helps Pilo generate better, accurate recipes using your local ingredients.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  hintText: 'e.g. Batuan, Kangkong',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 500,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  labelText: 'Description / Flavor Profile',
                  hintText: 'e.g. Sour fruit, leafy green',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usesController,
                maxLength: 500,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  labelText: 'Common Uses',
                  hintText: 'e.g. Used for souring soup (Sinigang)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  labelText: 'Color / Appearance',
                  hintText: 'e.g. Small round green fruit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTraining,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('SAVE TO PILO\'S BRAIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
