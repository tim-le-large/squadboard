import 'package:flutter/material.dart';

import '../models/ticket_status.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TicketPriority priority;

  Color _color(ColorScheme scheme) {
    return switch (priority) {
      TicketPriority.low => scheme.tertiary,
      TicketPriority.medium => scheme.primary,
      TicketPriority.high => scheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _color(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        priority.label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
