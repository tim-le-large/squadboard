const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require('firebase-functions/v2/firestore');

initializeApp();

const db = getFirestore();

async function tokensForMembers(memberIds, excludeUserId) {
  const tokens = new Set();

  for (const memberId of memberIds) {
    if (memberId === excludeUserId) continue;
    const userDoc = await db.collection('users').doc(memberId).get();
    const userTokens = userDoc.data()?.fcmTokens ?? [];
    for (const token of userTokens) {
      if (typeof token === 'string' && token.length > 0) {
        tokens.add(token);
      }
    }
  }

  return [...tokens];
}

async function sendPush(tokens, notification, data) {
  if (tokens.length === 0) return;

  const messaging = getMessaging();
  const batchSize = 500;

  for (let i = 0; i < tokens.length; i += batchSize) {
    const chunk = tokens.slice(i, i + batchSize);
    await messaging.sendEachForMulticast({
      tokens: chunk,
      notification,
      data,
      webpush: {
        fcmOptions: {
          link: 'https://squadboard.lelarge.dev',
        },
      },
    });
  }
}

exports.notifyOnChatMessage = onDocumentCreated(
  'workspaces/{workspaceId}/messages/{messageId}',
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const workspaceId = event.params.workspaceId;
    const workspaceDoc = await db.collection('workspaces').doc(workspaceId).get();
    const memberIds = workspaceDoc.data()?.memberIds ?? [];

    const tokens = await tokensForMembers(memberIds, message.userId);
    const userName = message.userName ?? 'Someone';
    const body = message.body ?? '';

    await sendPush(
      tokens,
      {
        title: `New message from ${userName}`,
        body: body.length > 120 ? `${body.slice(0, 117)}...` : body,
      },
      {
        type: 'chat',
        workspaceId,
      },
    );
  },
);

exports.notifyOnTicketAssigned = onDocumentUpdated(
  'workspaces/{workspaceId}/tickets/{ticketId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const newAssignee = after.assigneeId;
    const oldAssignee = before.assigneeId;
    if (!newAssignee || newAssignee === oldAssignee) return;

    await notifyAssignee(newAssignee, after.title, event.params);
  },
);

exports.notifyOnTicketCreatedWithAssignee = onDocumentCreated(
  'workspaces/{workspaceId}/tickets/{ticketId}',
  async (event) => {
    const ticket = event.data?.data();
    if (!ticket?.assigneeId) return;

    const creatorId = ticket.createdBy;
    if (creatorId && creatorId === ticket.assigneeId) return;

    await notifyAssignee(ticket.assigneeId, ticket.title, event.params);
  },
);

async function notifyAssignee(assigneeId, title, params) {
  const userDoc = await db.collection('users').doc(assigneeId).get();
  const tokens = userDoc.data()?.fcmTokens ?? [];
  if (tokens.length === 0) return;

  await sendPush(
    tokens,
    {
      title: 'Ticket assigned to you',
      body: title ?? 'Ticket',
    },
    {
      type: 'ticket',
      workspaceId: params.workspaceId,
      ticketId: params.ticketId,
    },
  );
}
