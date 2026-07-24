import 'package:flutter/material.dart';

class DateFilter extends StatelessWidget {
  final String title;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const DateFilter({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            selectedDate == null
                ? title
                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
          ),
        ),
      ),
    );
  }
}
