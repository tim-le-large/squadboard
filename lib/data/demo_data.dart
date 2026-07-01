import '../models/ticket_status.dart';

/// Synthetic teammates shown on the shared demo board and chat.
const demoTeamMembers = <DemoPersona>[
  DemoPersona(seedId: 'demo_seed_alice', name: 'Alice Chen'),
  DemoPersona(seedId: 'demo_seed_marco', name: 'Marco Weber'),
  DemoPersona(seedId: 'demo_seed_sara', name: 'Sara Müller'),
  DemoPersona(seedId: 'demo_seed_lea', name: 'Lea Park'),
];

class DemoPersona {
  const DemoPersona({required this.seedId, required this.name});

  final String seedId;
  final String name;
}

class DemoCommentSeed {
  const DemoCommentSeed({required this.authorIndex, required this.body});

  /// 0 = signed-in demo visitor, 1–4 = [demoTeamMembers].
  final int authorIndex;
  final String body;
}

class DemoChatSeed {
  const DemoChatSeed({
    required this.authorIndex,
    required this.body,
    required this.minutesAgo,
  });

  /// 0 = signed-in demo visitor, 1–4 = [demoTeamMembers].
  final int authorIndex;
  final String body;
  final int minutesAgo;
}

class DemoTicketSeed {
  const DemoTicketSeed({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.position,
    this.createdByIndex = 0,
    this.assigneeIndex = 0,
    this.comments = const [],
  });

  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final int position;
  final int createdByIndex;
  final int assigneeIndex;
  final List<DemoCommentSeed> comments;
}

/// Resolves demo author index to Firestore user id + display name.
({String id, String name}) resolveDemoMember(
  int index, {
  required String currentUserId,
  required String currentUserName,
}) {
  if (index == 0) {
    return (id: currentUserId, name: currentUserName);
  }
  final member = demoTeamMembers[index - 1];
  return (id: member.seedId, name: member.name);
}

const demoChatMessages = <DemoChatSeed>[
  DemoChatSeed(
    authorIndex: 1,
    body: 'Morning team — sprint planning at 10? ☀️',
    minutesAgo: 4320,
  ),
  DemoChatSeed(
    authorIndex: 2,
    body: 'Works for me. I can demo the Kanban drag-and-drop.',
    minutesAgo: 4280,
  ),
  DemoChatSeed(
    authorIndex: 3,
    body: 'Welcome to the shared SquadBoard demo 👋',
    minutesAgo: 3600,
  ),
  DemoChatSeed(
    authorIndex: 4,
    body: 'Try the Board tab — cards update in real time.',
    minutesAgo: 3540,
  ),
  DemoChatSeed(
    authorIndex: 0,
    body: 'Just joined — this looks great on mobile web!',
    minutesAgo: 3480,
  ),
  DemoChatSeed(
    authorIndex: 1,
    body: 'Sprint focus: portfolio polish + live demos.',
    minutesAgo: 2880,
  ),
  DemoChatSeed(
    authorIndex: 2,
    body: 'Can someone review the ticket comment thread UX?',
    minutesAgo: 2400,
  ),
  DemoChatSeed(
    authorIndex: 3,
    body: 'Deployed to squadboard.lelarge.dev — DNS is live.',
    minutesAgo: 2160,
  ),
  DemoChatSeed(
    authorIndex: 4,
    body: 'Push notifications need Cloud Functions on Blaze.',
    minutesAgo: 1920,
  ),
  DemoChatSeed(
    authorIndex: 1,
    body: 'I moved “FCM push notifications” to In Progress.',
    minutesAgo: 1440,
  ),
  DemoChatSeed(
    authorIndex: 2,
    body: 'Firestore rules are locked down — only members can read.',
    minutesAgo: 1200,
  ),
  DemoChatSeed(
    authorIndex: 3,
    body: 'Who owns the landing page copy for lelarge.dev?',
    minutesAgo: 960,
  ),
  DemoChatSeed(
    authorIndex: 4,
    body: 'I’ll take the hero section — Alice can do project cards.',
    minutesAgo: 900,
  ),
  DemoChatSeed(
    authorIndex: 0,
    body: 'Ticket comments work too — open any card on the board.',
    minutesAgo: 720,
  ),
  DemoChatSeed(
    authorIndex: 1,
    body: 'Coffee break ☕ — back in 15.',
    minutesAgo: 480,
  ),
  DemoChatSeed(
    authorIndex: 2,
    body: 'QA: invite code join works in incognito.',
    minutesAgo: 360,
  ),
  DemoChatSeed(
    authorIndex: 3,
    body: 'FinFlow + SquadBoard + KaGo — portfolio trio complete 🎉',
    minutesAgo: 240,
  ),
  DemoChatSeed(
    authorIndex: 4,
    body: 'Anyone free for a quick sync at 15:00?',
    minutesAgo: 60,
  ),
];

const richDemoTickets = [
  DemoTicketSeed(
    title: 'Welcome to SquadBoard',
    description: 'Drag tickets between columns. Open a card to read and add comments.',
    status: TicketStatus.todo,
    priority: TicketPriority.high,
    position: 0,
    createdByIndex: 3,
    assigneeIndex: 0,
    comments: [
      DemoCommentSeed(
        authorIndex: 3,
        body: 'Start here if you are new to the demo.',
      ),
      DemoCommentSeed(
        authorIndex: 1,
        body: 'Works great on desktop and mobile web.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Design landing page',
    description: 'Hero section + project cards for lelarge.dev with live demo links.',
    status: TicketStatus.todo,
    priority: TicketPriority.medium,
    position: 1,
    createdByIndex: 1,
    assigneeIndex: 4,
    comments: [
      DemoCommentSeed(
        authorIndex: 4,
        body: 'Match FinFlow / SquadBoard color accents.',
      ),
      DemoCommentSeed(
        authorIndex: 1,
        body: 'Draft ready in Figma — link in README.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Set up Firebase indexes',
    description: 'Deploy composite indexes for status + position queries.',
    status: TicketStatus.todo,
    priority: TicketPriority.low,
    position: 2,
    createdByIndex: 2,
    assigneeIndex: 2,
  ),
  DemoTicketSeed(
    title: 'Implement CSV bank import',
    description: 'Parse German bank exports and auto-categorize transactions.',
    status: TicketStatus.todo,
    priority: TicketPriority.medium,
    position: 3,
    createdByIndex: 0,
    assigneeIndex: 3,
    comments: [
      DemoCommentSeed(
        authorIndex: 3,
        body: 'FinFlow ticket — might pair with Marco on parsing.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Kanban drag-and-drop polish',
    description: 'Smoother animations and touch targets on mobile web.',
    status: TicketStatus.inProgress,
    priority: TicketPriority.high,
    position: 0,
    createdByIndex: 2,
    assigneeIndex: 2,
    comments: [
      DemoCommentSeed(
        authorIndex: 2,
        body: 'Long-press to drag on touch devices.',
      ),
      DemoCommentSeed(
        authorIndex: 1,
        body: 'Column highlight on hover works — ship it.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Realtime team chat',
    description: 'Firestore snapshots for messages with scroll-to-bottom.',
    status: TicketStatus.inProgress,
    priority: TicketPriority.medium,
    position: 1,
    createdByIndex: 3,
    assigneeIndex: 3,
    comments: [
      DemoCommentSeed(
        authorIndex: 3,
        body: 'Latency feels instant on localhost.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'FCM push notifications',
    description: 'Cloud Functions for chat messages and ticket assignments.',
    status: TicketStatus.inProgress,
    priority: TicketPriority.high,
    position: 2,
    createdByIndex: 1,
    assigneeIndex: 1,
    comments: [
      DemoCommentSeed(
        authorIndex: 4,
        body: 'VAPID key is in GitHub secrets.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Invite code onboarding',
    description: 'Create or join workspace with 6-character codes.',
    status: TicketStatus.inProgress,
    priority: TicketPriority.low,
    position: 3,
    createdByIndex: 4,
    assigneeIndex: 4,
  ),
  DemoTicketSeed(
    title: 'Ship v1 to GitHub Pages',
    description: 'CI build with dart-define secrets and custom domain.',
    status: TicketStatus.done,
    priority: TicketPriority.high,
    position: 0,
    createdByIndex: 2,
    assigneeIndex: 2,
    comments: [
      DemoCommentSeed(
        authorIndex: 2,
        body: 'Live at squadboard.lelarge.dev',
      ),
      DemoCommentSeed(
        authorIndex: 0,
        body: 'CI green on main.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Firestore security rules',
    description: 'Member-only access for workspaces, tickets, and chat.',
    status: TicketStatus.done,
    priority: TicketPriority.high,
    position: 1,
    createdByIndex: 3,
    assigneeIndex: 3,
    comments: [
      DemoCommentSeed(
        authorIndex: 1,
        body: 'Reviewed — no open reads.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'One-click live demo',
    description: 'Shared demo account with auto-seeded workspace data.',
    status: TicketStatus.done,
    priority: TicketPriority.medium,
    position: 2,
    createdByIndex: 1,
    assigneeIndex: 0,
  ),
  DemoTicketSeed(
    title: 'Ticket detail + comments',
    description: 'Thread per ticket with status and priority dropdowns.',
    status: TicketStatus.done,
    priority: TicketPriority.medium,
    position: 3,
    createdByIndex: 4,
    assigneeIndex: 4,
    comments: [
      DemoCommentSeed(
        authorIndex: 2,
        body: 'Status dropdown saves on change.',
      ),
    ],
  ),
  DemoTicketSeed(
    title: 'Portfolio case study',
    description: 'Write short README sections for recruiters and clients.',
    status: TicketStatus.done,
    priority: TicketPriority.low,
    position: 4,
    createdByIndex: 0,
    assigneeIndex: 1,
  ),
  DemoTicketSeed(
    title: 'Add FinFlow to lelarge.dev',
    description: 'Projects section with live demo and GitHub links.',
    status: TicketStatus.done,
    priority: TicketPriority.low,
    position: 5,
    createdByIndex: 3,
    assigneeIndex: 3,
  ),
];
