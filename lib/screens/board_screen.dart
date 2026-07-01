import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../models/ticket_status.dart';
import '../models/workspace.dart';
import '../providers/tickets_provider.dart';
import '../widgets/kanban_column.dart';
import 'add_ticket_sheet.dart';
import 'ticket_detail_screen.dart';

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key, required this.workspace});

  final Workspace workspace;

  Future<void> _onTicketDropped(
    WidgetRef ref,
    Ticket ticket,
    TicketStatus newStatus,
    List<Ticket> allTickets,
  ) async {
    if (ticket.status == newStatus) return;

    final columnTickets = ticketsForStatus(allTickets, newStatus);
    final newPosition = columnTickets.isEmpty
        ? 0
        : columnTickets.last.position + 1;

    await ref.read(ticketActionsProvider).move(
          ticket: ticket,
          newStatus: newStatus,
          newPosition: newPosition,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Board error: $error')),
      data: (tickets) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: TicketStatus.values.map((status) {
                    final columnTickets = ticketsForStatus(tickets, status);
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 180,
                      child: KanbanColumn(
                        status: status,
                        tickets: columnTickets,
                        onTicketTap: (ticket) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TicketDetailScreen(
                                workspace: workspace,
                                ticket: ticket,
                              ),
                            ),
                          );
                        },
                        onTicketDropped: (ticket, newStatus) {
                          _onTicketDropped(ref, ticket, newStatus, tickets);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddTicketSheet(workspace: workspace),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New ticket'),
              ),
            ),
          ],
        );
      },
    );
  }
}
