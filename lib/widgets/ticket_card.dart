import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'priority_badge.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  final Ticket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (ticket.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ticket.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  PriorityBadge(priority: ticket.priority),
                  const Spacer(),
                  if (ticket.assigneeName != null)
                    Tooltip(
                      message: ticket.assigneeName!,
                      child: CircleAvatar(
                        radius: 12,
                        child: Text(
                          ticket.assigneeName!.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
