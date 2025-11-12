import 'package:flutter/material.dart';

class PlaceSuggestion {
  final String id;
  final String description;
  final String display;

  PlaceSuggestion({
    required this.id,
    required this.description,
    required this.display,
  });
}

class PlaceDetail {
  final String name;
  final String address;
  final double? lat;
  final double? lng;

  PlaceDetail({required this.name, required this.address, this.lat, this.lng});
}

typedef OnChanged = void Function(String value);

class PlaceAutocompleteInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final OnChanged? onChanged;

  const PlaceAutocompleteInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.label = 'Enter location',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  icon: const Icon(Icons.clear),
                )
                : null,
      ),
      onChanged: onChanged,
    );
  }
}
