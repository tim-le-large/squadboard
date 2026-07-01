import 'package:flutter_test/flutter_test.dart';
import 'package:squadboard/models/ticket.dart';
import 'package:squadboard/models/ticket_status.dart';
import 'package:squadboard/providers/tickets_provider.dart';

Ticket _ticket({
  required String id,
  required TicketStatus status,
  required int position,
}) {
  final now = DateTime(2026, 6, 1);
  return Ticket(
    id: id,
    workspaceId: 'workspace-1',
    title: 'Ticket $id',
    description: '',
    status: status,
    priority: TicketPriority.medium,
    position: position,
    createdBy: 'user-1',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ticketsForStatus', () {
    final tickets = [
      _ticket(id: 'a', status: TicketStatus.todo, position: 2),
      _ticket(id: 'b', status: TicketStatus.inProgress, position: 0),
      _ticket(id: 'c', status: TicketStatus.todo, position: 0),
      _ticket(id: 'd', status: TicketStatus.done, position: 1),
    ];

    test('filters by status', () {
      final todo = ticketsForStatus(tickets, TicketStatus.todo);
      expect(todo, hasLength(2));
      expect(todo.map((t) => t.id), ['c', 'a']);
    });

    test('sorts by position ascending', () {
      final inProgress = ticketsForStatus(tickets, TicketStatus.inProgress);
      expect(inProgress.single.id, 'b');
    });

    test('returns empty list when no tickets match', () {
      expect(ticketsForStatus([], TicketStatus.done), isEmpty);
    });
  });
}
