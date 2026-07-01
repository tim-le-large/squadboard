import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../models/ticket_status.dart';
import '../repositories/ticket_repository.dart';
import 'core_providers.dart';

final ticketsProvider = StreamProvider<List<Ticket>>((ref) {
  final workspace = ref.watch(workspaceProvider).valueOrNull;
  if (workspace == null) return Stream.value([]);
  return ref.watch(ticketRepositoryProvider).watchTickets(workspace.id);
});

List<Ticket> ticketsForStatus(List<Ticket> tickets, TicketStatus status) {
  return tickets.where((t) => t.status == status).toList()
    ..sort((a, b) => a.position.compareTo(b.position));
}

final ticketActionsProvider = Provider<TicketActions>((ref) {
  return TicketActions(ref);
});

class TicketActions {
  TicketActions(this._ref);

  final Ref _ref;

  TicketRepository get _repo => _ref.read(ticketRepositoryProvider);

  Future<void> create({
    required String workspaceId,
    required String title,
    required String description,
    required TicketPriority priority,
    required String createdBy,
    String? assigneeId,
    String? assigneeName,
  }) {
    return _repo.createTicket(
      workspaceId: workspaceId,
      title: title,
      description: description,
      priority: priority,
      createdBy: createdBy,
      assigneeId: assigneeId,
      assigneeName: assigneeName,
    );
  }

  Future<void> move({
    required Ticket ticket,
    required TicketStatus newStatus,
    required int newPosition,
  }) {
    return _repo.moveTicket(
      ticket: ticket,
      newStatus: newStatus,
      newPosition: newPosition,
    );
  }

  Future<void> update(Ticket ticket) => _repo.updateTicket(ticket);

  Future<void> delete(Ticket ticket) => _repo.deleteTicket(ticket);
}
