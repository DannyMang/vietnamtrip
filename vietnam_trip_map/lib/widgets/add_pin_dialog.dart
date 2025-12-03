import 'package:flutter/material.dart' hide Color;
import 'package:flutter/material.dart' as material show Color;
import 'package:mapbox_search/mapbox_search.dart';
import 'location_search_widget.dart';
import '../models/pin.dart';

class AddPinDialog extends StatefulWidget {
  final Function(Pin) onPinAdded;

  const AddPinDialog({
    super.key,
    required this.onPinAdded,
  });

  @override
  State<AddPinDialog> createState() => _AddPinDialogState();
}

class _AddPinDialogState extends State<AddPinDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  PinType _selectedType = PinType.activity;
  MapBoxPlace? _selectedLocation;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search and select a location')),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _selectedLocation!.placeName ?? 'Unknown Place'
        : _titleController.text.trim();

    final coords = _selectedLocation!.geometry!.coordinates!;

    final pin = Pin(
      title: title,
      description: _descriptionController.text.trim(),
      latitude: coords.lat,
      longitude: coords.long,
      type: _selectedType,
    );

    widget.onPinAdded(pin);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add New Place',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Search Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              LocationSearchWidget(
                onLocationSelected: (place) {
                  setState(() {
                    _selectedLocation = place;
                    if (_titleController.text.trim().isEmpty) {
                      _titleController.text = place.placeName ?? '';
                    }
                  });
                },
              ),
              if (_selectedLocation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedLocation!.placeName ?? 'Location selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PinType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.emoji),
                        const SizedBox(width: 4),
                        Text(type.value),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                    },
                    selectedColor: _getTypeColor(type),
                    backgroundColor: Colors.grey.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title (optional)',
                  hintText: 'Custom name for this place',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add notes about this place...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Place',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(PinType type) {
    switch (type) {
      case PinType.shopping:
        return Colors.pink.shade200;
      case PinType.activity:
        return Colors.purple.shade200;
      case PinType.food:
        return Colors.orange.shade200;
      case PinType.beauty:
        return Colors.pink.shade200;
      case PinType.hotel:
        return Colors.blue.shade200;
    }
  }
}
