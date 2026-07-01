import 'package:flutter_test/flutter_test.dart';
import 'package:squadboard/models/ticket_status.dart';

void main() {
  group('TicketStatus.fromValue', () {
    test('maps known values', () {
      expect(TicketStatus.fromValue('in_progress'), TicketStatus.inProgress);
      expect(TicketStatus.fromValue('done'), TicketStatus.done);
    });

    test('falls back to todo for unknown value', () {
      expect(TicketStatus.fromValue('unknown'), TicketStatus.todo);
    });
  });

  group('TicketPriority.fromValue', () {
    test('maps known values', () {
      expect(TicketPriority.fromValue('high'), TicketPriority.high);
      expect(TicketPriority.fromValue('low'), TicketPriority.low);
    });

    test('falls back to medium for unknown value', () {
      expect(TicketPriority.fromValue('urgent'), TicketPriority.medium);
    });
  });
}
