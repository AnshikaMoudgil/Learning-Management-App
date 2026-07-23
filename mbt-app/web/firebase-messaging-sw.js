importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyA9AvLo32W2D0-JpGdO7-4yd-rjyKjMQ34',
  appId: '1:1080778754825:web:0794c073915cd6a6c861d8',
  messagingSenderId: '1080778754825',
  projectId: 'mbt-app-9576b',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/favicon.png',
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
