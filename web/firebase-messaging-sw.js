importScripts(
  'https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyDBzRQvSjobGENfSAJr-3-hP5A_7hLfLyE',
  authDomain: 'squadboard-83ed4.firebaseapp.com',
  projectId: 'squadboard-83ed4',
  storageBucket: 'squadboard-83ed4.firebasestorage.app',
  messagingSenderId: '74934708586',
  appId: '1:74934708586:web:e9d9d97b3f308cd0541d13',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title ?? 'SquadBoard';
  const options = {
    body: payload.notification?.body ?? '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
  };
  return self.registration.showNotification(title, options);
});
