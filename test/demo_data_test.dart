import 'package:flutter_test/flutter_test.dart';
import 'package:squadboard/data/demo_data.dart';

void main() {
  group('resolveDemoMember', () {
    const userId = 'real-user-id';
    const userName = 'Demo Visitor';

    test('index 0 maps to signed-in user', () {
      final member = resolveDemoMember(
        0,
        currentUserId: userId,
        currentUserName: userName,
      );
      expect(member.id, userId);
      expect(member.name, userName);
    });

    test('index 1 maps to first synthetic teammate', () {
      final member = resolveDemoMember(
        1,
        currentUserId: userId,
        currentUserName: userName,
      );
      expect(member.id, demoTeamMembers.first.seedId);
      expect(member.name, demoTeamMembers.first.name);
    });
  });

  group('rich demo content', () {
    test('has full kanban board seed', () {
      expect(richDemoTickets, hasLength(14));
    });

    test('has multi-user chat conversation', () {
      expect(demoChatMessages.length, greaterThanOrEqualTo(10));
      final authors = demoChatMessages.map((m) => m.authorIndex).toSet();
      expect(authors.length, greaterThan(1));
    });
  });
}
