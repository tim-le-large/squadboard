import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/workspace.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ensureUserProfile();
  }

  Future<void> signUp(String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await _ensureUserProfile(displayName: displayName);
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Stream<AppUser?> watchCurrentAppUser() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  Future<void> _ensureUserProfile({String? displayName}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (doc.exists) return;

    final name = displayName ?? user.displayName ?? user.email?.split('@').first ?? 'User';
    await ref.set({
      'email': user.email ?? '',
      'displayName': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class WorkspaceRepository {
  WorkspaceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _workspaces =>
      _firestore.collection('workspaces');

  Stream<Workspace?> watchWorkspace(String workspaceId) {
    return _workspaces.doc(workspaceId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Workspace.fromFirestore(doc);
    });
  }

  Future<Workspace> createWorkspace({
    required String userId,
    required String name,
  }) async {
    final inviteCode = _generateInviteCode();
    final ref = _workspaces.doc();
    final workspace = Workspace(
      id: ref.id,
      name: name,
      ownerId: userId,
      memberIds: [userId],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    await ref.set(workspace.toFirestore());
    await _firestore.collection('invite_codes').doc(inviteCode).set({
      'workspaceId': ref.id,
    });
    await _firestore.collection('users').doc(userId).update({
      'workspaceId': ref.id,
    });

    return workspace;
  }

  Future<Workspace> joinWorkspace({
    required String userId,
    required String inviteCode,
  }) async {
    final code = inviteCode.trim().toUpperCase();
    final inviteDoc =
        await _firestore.collection('invite_codes').doc(code).get();

    if (!inviteDoc.exists) {
      throw Exception('Invite code not found');
    }

    final workspaceId = inviteDoc.data()?['workspaceId'] as String?;
    if (workspaceId == null) {
      throw Exception('Invalid invite code');
    }

    await _workspaces.doc(workspaceId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
    await _firestore.collection('users').doc(userId).update({
      'workspaceId': workspaceId,
    });

    final doc = await _workspaces.doc(workspaceId).get();
    if (!doc.exists) {
      throw Exception('Workspace not found');
    }
    return Workspace.fromFirestore(doc);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
