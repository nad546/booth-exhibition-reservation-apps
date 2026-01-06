import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateRange;
  const EventCard({super.key, required this.title, required this.subtitle, required this.dateRange});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(dateRange, style: const TextStyle(fontSize: 12))]),
      ),
    );
  }
}