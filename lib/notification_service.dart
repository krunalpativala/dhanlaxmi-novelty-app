part of 'main.dart';

class _NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    final androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _addNotification(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
        );
        _showLocalNotification(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
        );
      }
    });
  }

  static void _addNotification(String title, String body) {
    final notification = {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toString().split('.')[0],
    };
    notificationsNotifier.value = [
      notification,
      ...notificationsNotifier.value,
    ];
  }

  static Future<void> _showLocalNotification(String title, String body) async {
    if (kIsWeb) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'dhanlaxmi_channel',
      'Order Updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, details);
  }

  static Future<void> saveToken() async {
    if (kIsWeb) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }
}
