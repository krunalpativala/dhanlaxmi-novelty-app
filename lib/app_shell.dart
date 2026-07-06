part of 'main.dart';

class DhanlaxmiNoveltyApp extends StatelessWidget {
  const DhanlaxmiNoveltyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0F766E);

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: languageNotifier,
      builder: (context, language, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dhanlaxmi Novelty',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seed),
            scaffoldBackgroundColor: const Color(0xFFF7F7F2),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            useMaterial3: true,
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF1F2933),
              displayColor: const Color(0xFF1F2933),
            ),
          ),
          home: const NotificationGate(child: AuthGate()),
        );
      },
    );
  }
}

class NotificationGate extends StatefulWidget {
  const NotificationGate({super.key, required this.child});
  final Widget child;

  @override
  State<NotificationGate> createState() => _NotificationGateState();
}

class _NotificationGateState extends State<NotificationGate> {
  @override
  void initState() {
    super.initState();
    _NotificationService.saveToken();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return widget.child;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnap) {
            final role = userSnap.data?.data()?['role']?.toString();
            return _RealtimeNotificationManager(
              userId: user.uid,
              role: role ?? 'retailer',
              child: widget.child,
            );
          },
        );
      },
    );
  }
}

class _RealtimeNotificationManager extends StatefulWidget {
  const _RealtimeNotificationManager({
    required this.userId,
    required this.role,
    required this.child,
  });
  final String userId;
  final String role;
  final Widget child;

  @override
  State<_RealtimeNotificationManager> createState() =>
      _RealtimeNotificationManagerState();
}

class _RealtimeNotificationManagerState
    extends State<_RealtimeNotificationManager> {
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _NotificationService.saveToken();
    _setupListeners();
  }

  @override
  void didUpdateWidget(_RealtimeNotificationManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || oldWidget.role != widget.role) {
      _cancelListeners();
      _NotificationService.saveToken();
      _setupListeners();
    }
  }

  @override
  void dispose() {
    _cancelListeners();
    super.dispose();
  }

  void _cancelListeners() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void _setupListeners() {
    // 1. Listen for Order Status Updates (For Retailers)
    if (widget.role == 'retailer') {
      final subscription = FirebaseFirestore.instance
          .collection('orders')
          .where('retailerUid', isEqualTo: widget.userId)
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                final data = change.doc.data();
                final status = data?['status'] ?? 'new';
                final shop = data?['shopName'] ?? 'Order';
                _NotificationService._showLocalNotification(
                  'Order Update: $shop',
                  'Aapka order status ab "$status" hai.',
                );
              }
            }
          });
      _subscriptions.add(subscription);
    }

    // 2. Listen for Order Status Updates (For Customers)
    if (widget.role == 'customer') {
      final subscription = FirebaseFirestore.instance
          .collection('orders')
          .where('customerUid', isEqualTo: widget.userId)
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                final data = change.doc.data();
                final status = data?['status'] ?? 'pending';
                _NotificationService._showLocalNotification(
                  'Order Update',
                  'Aapka order status ab "$status" hai.',
                );
              }
            }
          });
      _subscriptions.add(subscription);
    }

    // 3. Listen for New Orders (For Admin)
    if (widget.role == 'admin') {
      final subscription = FirebaseFirestore.instance
          .collection('orders')
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                // Avoid showing notification for old orders on first load
                final data = change.doc.data();
                final createdAt = data?['createdAt'] as Timestamp?;
                if (createdAt != null &&
                    createdAt.toDate().isAfter(
                      DateTime.now().subtract(const Duration(minutes: 1)),
                    )) {
                  final shop =
                      data?['shopName'] ?? data?['customerName'] ?? 'New Order';
                  _NotificationService._showLocalNotification(
                    'New Order Received! 🛍️',
                    'Naya order aaya hai: $shop',
                  );
                }
              }
            }
          });
      _subscriptions.add(subscription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
