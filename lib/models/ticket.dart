import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticket_status.dart';

class Ticket {
  const Ticket({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.position,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.assigneeId,
    this.assigneeName,
  });

  final String id;
  final String workspaceId;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final int position;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assigneeId;
  final String? assigneeName;

  factory Ticket.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return Ticket(
      id: doc.id,
      workspaceId: workspaceId,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: TicketStatus.fromValue(data['status'] as String? ?? 'todo'),
      priority: TicketPriority.fromValue(data['priority'] as String? ?? 'medium'),
      position: data['position'] as int? ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assigneeId: data['assigneeId'] as String?,
      assigneeName: data['assigneeName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority.value,
        'position': position,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        if (assigneeId != null) 'assigneeId': assigneeId,
        if (assigneeName != null) 'assigneeName': assigneeName,
      };

  Ticket copyWith({
    String? title,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    int? position,
    String? assigneeId,
    String? assigneeName,
    bool clearAssignee = false,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: id,
      workspaceId: workspaceId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      position: position ?? this.position,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      assigneeName:
          clearAssignee ? null : (assigneeName ?? this.assigneeName),
    );
  }
}
