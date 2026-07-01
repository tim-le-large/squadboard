import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../models/ticket_status.dart';
import 'ticket_card.dart';

class KanbanColumn extends StatelessWidget {
  const KanbanColumn({
    super.key,
    required this.status,
    required this.tickets,
    required this.onTicketTap,
    required this.onTicketDropped,
  });

  final TicketStatus status;
  final List<Ticket> tickets;
  final void Function(Ticket ticket) onTicketTap;
  final void Function(Ticket ticket, TicketStatus newStatus) onTicketDropped;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DragTarget<Ticket>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        onTicketDropped(details.data, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlighted
                ? scheme.primaryContainer.withValues(alpha: 0.3)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    status.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tickets.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return LongPressDraggable<Ticket>(
                      data: ticket,
                      feedback: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 260,
                          child: TicketCard(
                            ticket: ticket,
                            onTap: () {},
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.4,
                        child: TicketCard(
                          ticket: ticket,
                          onTap: () => onTicketTap(ticket),
                        ),
                      ),
                      child: TicketCard(
                        ticket: ticket,
                        onTap: () => onTicketTap(ticket),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
