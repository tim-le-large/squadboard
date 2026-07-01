import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'ticket_card.dart';

bool get useImmediateKanbanDrag =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux;

class KanbanDraggableTicket extends StatelessWidget {
  const KanbanDraggableTicket({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onDragStarted,
    this.onDragEnd,
  });

  final Ticket ticket;
  final VoidCallback onTap;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final child = TicketCard(ticket: ticket, onTap: onTap);
    final childWhenDragging = Opacity(
      opacity: 0.35,
      child: TicketCard(ticket: ticket, onTap: onTap),
    );
    final feedback = Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 260,
        child: TicketCard(ticket: ticket, onTap: () {}),
      ),
    );

    if (useImmediateKanbanDrag) {
      return MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Draggable<Ticket>(
          data: ticket,
          feedback: feedback,
          childWhenDragging: childWhenDragging,
          rootOverlay: true,
          onDragStarted: onDragStarted,
          onDragEnd: (_) => onDragEnd?.call(),
          child: child,
        ),
      );
    }

    return LongPressDraggable<Ticket>(
      data: ticket,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      hapticFeedbackOnStart: true,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      child: child,
    );
  }
}
