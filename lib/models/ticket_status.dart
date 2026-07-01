enum TicketStatus {
  todo('todo', 'To Do'),
  inProgress('in_progress', 'In Progress'),
  done('done', 'Done');

  const TicketStatus(this.value, this.label);

  final String value;
  final String label;

  static TicketStatus fromValue(String value) {
    return TicketStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => TicketStatus.todo,
    );
  }
}

enum TicketPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const TicketPriority(this.value, this.label);

  final String value;
  final String label;

  static TicketPriority fromValue(String value) {
    return TicketPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TicketPriority.medium,
    );
  }
}
