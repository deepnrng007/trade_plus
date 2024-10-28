import 'package:flutter/material.dart';

class SearchInputWidget extends StatelessWidget {
  final Function(String) onTextChanged;

  const SearchInputWidget({super.key, required this.onTextChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
            labelText: 'Search',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.white),
        onChanged: onTextChanged,
      ),
    );
  }
}
