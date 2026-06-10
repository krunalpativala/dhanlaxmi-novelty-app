import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

enum AppLanguage { english, gujarati }

extension AppLanguageDisplay on AppLanguage {
  String get displayName => this == AppLanguage.english ? 'English' : 'ગુજરાતી';
}

final ValueNotifier<AppLanguage> languageNotifier =
    ValueNotifier<AppLanguage>(AppLanguage.english);

class AppLocalizations {
  static const Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.english: {
      'orderSuccess': 'Order submitted successfully!',
      'mustLoginFirst': 'Please log in before submitting an order.',
      'shopNamePhoneRequired': 'Shop name and mobile number are required.',
      'firebaseOrderPermission':
          'Grant the retailer permission to create orders in Firestore rules.',
      'orderSubmitFailed': 'Order submission failed. Please try again.',
      'error': 'Error: ',
      'selectLanguage': 'Select language',
      'languagePrompt': 'Please choose a language',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'logout': 'Logout',
      'notifications': 'Notifications',
      'cart': 'Cart',
      'showPrices': 'Show Prices',
      'hidePrices': 'Hide Prices',
      'catalog': 'Catalog',
      'orders': 'Orders',
      'account': 'Account',
      'wholesaleOrderApp': 'Wholesale order app',
      'retailerAccount': 'Retailer account',
      'wholesalerOrdersInfoTitle': 'How wholesaler will see orders',
      'wholesalerOrdersInfoLine1':
          'Every submitted order saves in Firestore collection: orders',
      'wholesalerOrdersInfoLine2':
          'Each order has shopName, phone, note, status, quantity and items.',
      'wholesalerOrdersInfoLine3':
          'Wholesaler can open Firebase Console and review new orders.',
      'save': 'Save',
      'noCategories': 'No categories',
      'addCategoryHint':
          'Add a category so the catalog can update dynamically from products.',
      'registrationSent':
          'Registration request sent. You can log in after admin approval.',
      'emailAlreadyInUse': 'An account already exists with this email.',
      'emailRequired': 'Email is required.',
      'invalidEmail': 'Please enter a valid email address.',
      'emailPasswordIncorrect': 'Email or password is incorrect.',
      'weakPassword': 'Password must be at least 6 characters.',
      'enableEmailPasswordSignIn':
          'Enable Email/Password sign-in in Firebase Authentication.',
      'networkError': 'Check your internet connection and try again.',
      'createAccountInfo':
          'Create an account to book wholesale orders.',
      'loginInfo': 'Log in to place wholesale orders.',
      'passwordMismatch': 'Passwords do not match.',
      'cartEmptyTitle': 'Cart is empty',
      'cartEmptyMessage': 'Add items to the cart from the catalog.',
      'cartItems': 'Cart items',
      'retailerDetails': 'Retailer details',
      'shopNameLabel': 'Shop name',
      'phoneLabel': 'Phone / WhatsApp number',
      'orderNoteLabel': 'Order note',
      'submitOrder': 'Submit order',
      'submittingOrder': 'Submitting order...',
      'loginRequired': 'Login required',
      'loginToViewOrders': 'Log in to view your orders.',
      'ordersLoadFailed': 'Orders failed to load',
      'ordersLoadHelp':
          'Check Firestore rules/index. Orders appear in Firestore after submission.',
      'firstOrderPrompt': 'Place your first wholesale order from the cart.',
      'orderStatusUpdated': 'Order status set to {status}.',
      'statusUpdateFailed': 'Status update failed. Please try again.',
      'categoryReadPermission': 'Check category read permission.',
      'categoriesLoadFailed':
          'Categories failed to load. Please enter them manually.',
      'base64ImageError':
          'Cannot save Base64 image. Upload using the Select button.',
      'addProductHelp':
          'Add a product so the catalog updates automatically from Firestore.',
    },
    AppLanguage.gujarati: {
      'orderSuccess': 'ઓર્ડર સફળતાપૂર્વક મોકલી દીધો છે!',
      'mustLoginFirst': 'તમારે પહેલા લોગ-ઈન કરવું પડશે.',
      'shopNamePhoneRequired': 'દુકાનનું નામ અને મોબાઈલ નંબર લખવો જરૂરી છે.',
      'firebaseOrderPermission':
          'Firestore rules માં retailer ને orders create permission આપો.',
      'orderSubmitFailed': 'Order submit નથિ થાયો. ફરી try કરો.',
      'error': 'ભૂલ: ',
      'selectLanguage': 'ભાષા પસંદ કરો',
      'languagePrompt': 'કૃપા કરીને ભાષા પસંદ કરો',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'logout': 'Logout',
      'notifications': 'અહેવાલો',
      'cart': 'કાર્ટ',
      'showPrices': 'કિંમત બતાવો',
      'hidePrices': 'કિંમત છુપાવો',
      'catalog': 'Catalog',
      'orders': 'Orders',
      'account': 'Account',
      'wholesaleOrderApp': 'Wholesale order app',
      'retailerAccount': 'Retailer account',
      'wholesalerOrdersInfoTitle': 'How wholesaler will see orders',
      'wholesalerOrdersInfoLine1':
          'Every submitted order saves in Firestore collection: orders',
      'wholesalerOrdersInfoLine2':
          'Each order has shopName, phone, note, status, quantity and items.',
      'wholesalerOrdersInfoLine3':
          'Wholesaler can open Firebase Console and review new orders.',
      'save': 'Save',
      'noCategories': 'No categories',
      'addCategoryHint':
          'Add a category so the catalog can update dynamically from products.',
      'registrationSent':
          'Registration request sent. You can log in after admin approval.',
      'emailAlreadyInUse': 'An account already exists with this email.',
      'emailRequired': 'Email is required.',
      'invalidEmail': 'Please enter a valid email address.',
      'emailPasswordIncorrect': 'Email or password is incorrect.',
      'weakPassword': 'Password must be at least 6 characters.',
      'enableEmailPasswordSignIn':
          'Enable Email/Password sign-in in Firebase Authentication.',
      'networkError': 'Check your internet connection and try again.',
      'createAccountInfo':
          'Create an account to book wholesale orders.',
      'loginInfo': 'Log in to place wholesale orders.',
      'passwordMismatch': 'Passwords do not match.',
      'cartEmptyTitle': 'Cart is empty',
      'cartEmptyMessage': 'Add items to the cart from the catalog.',
      'cartItems': 'Cart items',
      'retailerDetails': 'Retailer details',
      'shopNameLabel': 'Shop name',
      'phoneLabel': 'Phone / WhatsApp number',
      'orderNoteLabel': 'Order note',
      'submitOrder': 'Submit order',
      'submittingOrder': 'Submitting order...',
      'loginRequired': 'Login required',
      'loginToViewOrders': 'Log in to view your orders.',
      'ordersLoadFailed': 'Orders failed to load',
      'ordersLoadHelp':
          'Check Firestore rules/index. Orders appear in Firestore after submission.',
      'firstOrderPrompt': 'Place your first wholesale order from the cart.',
      'orderStatusUpdated': 'Order status set to {status}.',
      'statusUpdateFailed': 'Status update failed. Please try again.',
      'categoryReadPermission': 'Check category read permission.',
      'categoriesLoadFailed':
          'Categories failed to load. Please enter them manually.',
      'base64ImageError':
          'Cannot save Base64 image. Upload using the Select button.',
      'addProductHelp':
          'Add a product so the catalog updates automatically from Firestore.',
    },
  };

  static String text(AppLanguage language, String key) =>
      _translations[language]?[key] ?? key;
}

class _LanguageSettings {
  static const _prefKey = 'appLanguage';

  static Future<AppLanguage> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey);
    if (value == AppLanguage.gujarati.name) {
      return AppLanguage.gujarati;
    }
    return AppLanguage.english;
  }

  static Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, language.name);
  }
}

Future<void> showLanguageSelectorDialog(BuildContext context) async {
  final initialLanguage = languageNotifier.value;
  await showDialog<void>(
    context: context,
    builder: (context) {
      var selectedLanguage = initialLanguage;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.text(initialLanguage, 'selectLanguage')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values
                .map(
                  (lang) => RadioListTile<AppLanguage>(
                    value: lang,
                    // ignore: deprecated_member_use
                    groupValue: selectedLanguage,
                    title: Text(lang.displayName),
                    // ignore: deprecated_member_use
                    onChanged: (selected) async {
                      if (selected == null) return;
                      setState(() => selectedLanguage = selected);
                      languageNotifier.value = selected;
                      await _LanguageSettings.saveLanguage(selected);
                    },
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.text(initialLanguage, 'save')),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notifications
  await _NotificationService.initialize();

  languageNotifier.value = await _LanguageSettings.loadLanguage();

  runApp(const DhanlaxmiNoveltyApp());
}

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

    // Request permissions
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Handle foreground messages
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

    // 2. Listen for New Orders (For Admin)
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
                  final shop = data?['shopName'] ?? 'Unknown Shop';
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const AuthPage();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final role = userSnapshot.data?.data()?['role']?.toString();
            if (role == 'admin' || _adminEmails.contains(user.email)) {
              return const AdminHomePage();
            }
            if (role == 'retailer') {
              return const ShopHomePage();
            }

            return const _PendingApprovalPage();
          },
        );
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isSignUp) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = credential.user;
        final name = _nameController.text.trim();
        await user?.updateDisplayName(name);

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'name': name,
                'email': email,
                'role': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });
        }

        if (mounted) {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration request sent. You can log in after admin approval.',
              ),
            ),
          );
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _errorText = _friendlyAuthError(error));
    } catch (_) {
      setState(() => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'configuration-not-found':
      case 'configuration_not_found':
        return 'Enable Email/Password sign-in in Firebase Authentication.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorText = null;
      _formKey.currentState?.reset();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(subtitle: 'Wholesale retailer orders'),
                    const SizedBox(height: 28),
                    Text(
                      _isSignUp ? 'Create retailer account' : 'Retailer login',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Order book karva mate account banao.'
                          : 'Wholesale order mukva login karo.',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 22),
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Retailer name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = (value ?? '').trim();
                        if (email.isEmpty) {
                          return 'Email is required.';
                        }
                        if (!email.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: _isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isSignUp) {
                          _submit();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() => _hidePassword = !_hidePassword);
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Password minimum 6 characters no rakho.';
                        }
                        return null;
                      },
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                    ],
                    if (_errorText != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBox(message: _errorText!),
                    ],
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isSignUp ? Icons.person_add_alt_1 : Icons.login,
                            ),
                      label: Text(_isSignUp ? 'Sign up' : 'Login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : _toggleMode,
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Login'
                            : 'New retailer? Create account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  final Map<String, _CartLine> _cart = {};
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final List<Map<String, dynamic>> _notifications = [];
  int _selectedTab = 0;
  bool _isSubmitting = false;
  bool _isCartLoading = true;

  int get _totalQuantity =>
      _cart.values.fold(0, (total, line) => total + line.quantity);

  int get _totalProducts => _cart.length;

  double get _cartTotalAmount => _cart.values.fold(
    0,
    (total, line) => total + (line.product.price * line.quantity),
  );

  @override
  void initState() {
    super.initState();
    _loadCartFromFirestore();
    _notifications.addAll(_NotificationService.notificationsNotifier.value);
    _NotificationService.notificationsNotifier.addListener(
      _onNotificationsChanged,
    );
  }

  void _onNotificationsChanged() {
    if (mounted) {
      setState(() {
        _notifications.clear();
        _notifications.addAll(_NotificationService.notificationsNotifier.value);
      });
    }
  }

  @override
  void dispose() {
    _NotificationService.notificationsNotifier.removeListener(
      _onNotificationsChanged,
    );
    _shopNameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>>? get _cartDocument {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance.collection('carts').doc(user.uid);
  }

  Future<void> _loadCartFromFirestore() async {
    final cartDocument = _cartDocument;
    if (cartDocument == null) {
      setState(() => _isCartLoading = false);
      return;
    }

    try {
      final snapshot = await cartDocument.get();
      final data = snapshot.data();
      final items = data?['items'] as List<dynamic>? ?? [];
      final loadedCart = <String, _CartLine>{};

      for (final item in items) {
        if (item is! Map) {
          continue;
        }

        final productId = item['productId']?.toString();
        final product =
            _findProductById(productId) ?? _productFromCartItem(item);
        final quantity = item['quantity'];

        if (product != null && quantity is int && quantity > 0) {
          loadedCart[product.id] = _CartLine(
            product: product,
            quantity: quantity,
          );
        }
      }

      if (mounted) {
        setState(() {
          _cart
            ..clear()
            ..addAll(loadedCart);
          _shopNameController.text = data?['shopName']?.toString() ?? '';
          _phoneController.text = data?['phone']?.toString() ?? '';
          _noteController.text = data?['note']?.toString() ?? '';
          _isCartLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCartLoading = false);
      }
    }
  }

  Future<void> _saveCartToFirestore() async {
    final cartDocument = _cartDocument;
    if (cartDocument == null) {
      return;
    }

    if (_cart.isEmpty) {
      try {
        await cartDocument.delete().timeout(const Duration(seconds: 5));
      } catch (_) {}
      return;
    }

    try {
      final cartData = {
        'retailerUid': FirebaseAuth.instance.currentUser?.uid,
        'retailerName': FirebaseAuth.instance.currentUser?.displayName ?? '',
        'shopName': _shopNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'note': _noteController.text.trim(),
        'totalProducts': _totalProducts,
        'totalQuantity': _totalQuantity,
        'items': _cart.values.map((line) => line.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      const maxCartDocBytes =
          900 * 1024; // Keep a safe margin under Firestore's 1MB limit.
      final cartPayloadBytes = utf8.encode(jsonEncode(cartData)).length;
      if (cartPayloadBytes > maxCartDocBytes) {
        debugPrint(
          'Cart sync skipped: document payload $cartPayloadBytes bytes exceeds safe limit $maxCartDocBytes bytes.',
        );
        return;
      }

      await cartDocument.set(cartData).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Cart sync skip: $e');
    }
  }

  void _addProduct(_CatalogProduct product) {
    setState(() {
      final existing = _cart[product.id];
      _cart[product.id] = _CartLine(
        product: product,
        quantity: existing == null
            ? product.minimumOrderQuantity
            : existing.quantity + 1,
      );
    });
    _saveCartToFirestore();
  }

  void _decreaseProduct(_CatalogProduct product) {
    final existing = _cart[product.id];
    if (existing == null) {
      return;
    }

    setState(() {
      if (existing.quantity <= product.minimumOrderQuantity) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = _CartLine(
          product: product,
          quantity: existing.quantity - 1,
        );
      }
    });
    _saveCartToFirestore();
  }

  Future<void> _submitOrder() async {
    if (_cart.isEmpty || _isSubmitting) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('તમારે પહેલા લોગ-ઈન કરવું પડશે.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _selectedTab = 4); // Account tab પર મોકલી આપશે
      return;
    }

    final shopName = _shopNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (shopName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('દુકાનનું નામ અને મોબાઈલ નંબર લખવો જરૂરી છે.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      debugPrint('Starting order submission...');
      final orderItems = _cart.values
          .map(
            (line) => {
              'productId': line.product.id,
              'name': line.product.name,
              'category': line.product.category,
              'unit': line.product.unit,
              'price': line.product.price,
              'minimumOrderQuantity': line.product.minimumOrderQuantity,
              'lineTotal': line.product.price * line.quantity,
              'imageUrl': line.product.imageUrl,
              'quantity': line.quantity,
            },
          )
          .toList();

      final orderData = {
        'retailerUid': user.uid,
        'retailerName': user.displayName ?? '',
        'shopName': shopName,
        'phone': phone,
        'note': _noteController.text.trim(),
        'status': 'new',
        'totalProducts': _totalProducts,
        'totalQuantity': _totalQuantity,
        'totalAmount': _cartTotalAmount,
        'items': orderItems,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Firestore માં ઓર્ડર એડ કરો
      await FirebaseFirestore.instance
          .collection('orders')
          .add(orderData)
          .timeout(const Duration(seconds: 15));

      // કાર્ટ ડોક્યુમેન્ટ ડીલીટ કરો
      if (_cartDocument != null) {
        await _cartDocument!.delete().catchError((_) => null);
      }

      setState(() {
        _cart.clear();
        _selectedTab = 2; // Orders page
        _noteController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.text(languageNotifier.value, 'orderSuccess'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseException catch (error) {
      debugPrint('Firebase Error: ${error.code}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_firestoreError(error)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.text(languageNotifier.value, 'error')}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _firestoreError(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return AppLocalizations.text(
        languageNotifier.value,
        'firebaseOrderPermission',
      );
    }
    return error.message ??
        AppLocalizations.text(languageNotifier.value, 'orderSubmitFailed');
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCartLoading) {
      return const _LoadingScreen();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, productsSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('categories')
              .where('active', isEqualTo: true)
              .snapshots(),
          builder: (context, categoriesSnapshot) {
            final allCategories = _categoriesFromProductDocs(
              productsSnapshot.data?.docs ?? [],
              categoriesSnapshot.data?.docs ?? [],
            );

            final language = languageNotifier.value;
            final displayCategories = <_CatalogCategory>[];
            displayCategories.add(
              _CatalogCategory(
                name: 'All items',
                icon: Icons.grid_view_outlined,
                color: const Color(0xFF0F766E),
                products: allCategories.expand((c) => c.products).toList(),
                imageUrl: '',
              ),
            );
            displayCategories.addAll(allCategories);

            final pages = [
              _CatalogPage(
                categories: displayCategories,
                cart: _cart,
                onAdd: _addProduct,
                onRemove: _decreaseProduct,
                onOpenCart: () {
                  setState(() => _selectedTab = 1);
                },
              ),
              _CartPage(
                language: language,
                cartLines: _cart.values.toList(),
                shopNameController: _shopNameController,
                phoneController: _phoneController,
                noteController: _noteController,
                isSubmitting: _isSubmitting,
                onAdd: _addProduct,
                onRemove: _decreaseProduct,
                onDetailsChanged: _saveCartToFirestore,
                onSubmit: _submitOrder,
              ),
              _OrdersPage(language: language),
              _NotificationsPage(notifications: _notifications),
              _AccountPage(
                language: language,
                onSignOut: _signOut,
              ),
            ];

            return Scaffold(
              appBar: AppBar(
                title: _BrandHeader(
                  subtitle: AppLocalizations.text(language, 'wholesaleOrderApp'),
                ),
                actions: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _showPriceNotifier,
                    builder: (context, show, child) {
                      return IconButton(
                        tooltip: show
                            ? AppLocalizations.text(language, 'hidePrices')
                            : AppLocalizations.text(language, 'showPrices'),
                        icon: Icon(
                          show ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => _handlePriceVisibilityToggle(context),
                      );
                    },
                  ),
                  if (_totalQuantity > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Badge.count(
                        count: _totalQuantity,
                        child: IconButton.filledTonal(
                          tooltip: AppLocalizations.text(language, 'cart'),
                          onPressed: () {
                            setState(() => _selectedTab = 1);
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _notifications.isEmpty
                        ? IconButton(
                            tooltip: AppLocalizations.text(language, 'notifications'),
                            onPressed: () {
                              setState(() => _selectedTab = 3);
                            },
                            icon: const Icon(Icons.notifications_outlined),
                          )
                        : Badge.count(
                            count: _notifications.length,
                            child: IconButton.filledTonal(
                              tooltip: AppLocalizations.text(language, 'notifications'),
                              onPressed: () {
                                setState(() => _selectedTab = 3);
                              },
                              icon: const Icon(Icons.notifications_active),
                            ),
                          ),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.text(language, 'selectLanguage'),
                    onPressed: () => showLanguageSelectorDialog(context),
                    icon: const Icon(Icons.language),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.text(language, 'logout'),
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: pages[_selectedTab],
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedTab == 3
                    ? 2
                    : (_selectedTab == 4 ? 3 : _selectedTab),
                onDestinationSelected: (index) {
                  final tabIndex = index == 3 ? 4 : index;
                  setState(() => _selectedTab = tabIndex);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.inventory_2_outlined),
                    selectedIcon: const Icon(Icons.inventory_2),
                    label: AppLocalizations.text(language, 'catalog'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    selectedIcon: const Icon(Icons.shopping_cart),
                    label: AppLocalizations.text(language, 'cart'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long),
                    label: AppLocalizations.text(language, 'orders'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: AppLocalizations.text(language, 'account'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CatalogPage extends StatelessWidget {
  const _CatalogPage({
    required this.categories,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenCart,
  });

  final List<_CatalogCategory> categories;
  final Map<String, _CartLine> cart;
  final ValueChanged<_CatalogProduct> onAdd;
  final ValueChanged<_CatalogProduct> onRemove;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _WholesaleBanner(onOpenCart: onOpenCart),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: const Text(
              'Select Category',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.separated(
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryLargeCard(
                category: category,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _CategoryProductsPage(
                        category: category,
                        cart: cart,
                        onAdd: onAdd,
                        onRemove: onRemove,
                        onOpenCart: onOpenCart,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _CategoryLargeCard extends StatelessWidget {
  const _CategoryLargeCard({required this.category, required this.onTap});

  final _CatalogCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 250,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: category.imageUrl.isEmpty
                  ? Container(
                      color: category.color.withValues(alpha: 0.1),
                      child: Icon(
                        category.icon,
                        size: 80,
                        color: category.color.withValues(alpha: 0.2),
                      ),
                    )
                  : _ImageFromSource(
                      source: category.imageUrl,
                      fallbackIcon: category.icon,
                      fallbackColor: category.color,
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category.products.length} Items Available',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProductsPage extends StatefulWidget {
  const _CategoryProductsPage({
    required this.category,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenCart,
  });

  final _CatalogCategory category;
  final Map<String, _CartLine> cart;
  final ValueChanged<_CatalogProduct> onAdd;
  final ValueChanged<_CatalogProduct> onRemove;
  final VoidCallback onOpenCart;

  @override
  State<_CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<_CategoryProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late RangeValues _priceRange;
  late double _sliderMax;

  @override
  void initState() {
    super.initState();
    double maxP = 0;
    for (final p in widget.category.products) {
      if (p.price > maxP) maxP = p.price;
    }
    _sliderMax = maxP < 1000 ? 1000.0 : maxP;
    _priceRange = RangeValues(0.0, _sliderMax);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.category.products.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesText =
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
      final matchesPrice =
          p.price >= _priceRange.start && p.price <= _priceRange.end;
      return matchesText && matchesPrice;
    }).toList();

    final totalQuantity = widget.cart.values.fold(
      0,
      (total, line) => total + line.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          if (totalQuantity > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Badge.count(
                count: totalQuantity,
                child: IconButton.filledTonal(
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onOpenCart();
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search in ${widget.category.name}',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Price range',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0.0,
                  max: _sliderMax,
                  divisions: _sliderMax <= 1000
                      ? (_sliderMax / 50).round().clamp(1, 20)
                      : 20,
                  labels: RangeLabels(
                    '₹${_priceRange.start.toInt()}',
                    '₹${_priceRange.end.toInt()}',
                  ),
                  onChanged: (r) => setState(() => _priceRange = r),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const _EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No products found',
                    message: 'Try changing the search or price range.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductLargeCard(
                        product: product,
                        quantity: widget.cart[product.id]?.quantity ?? 0,
                        onAdd: () {
                          widget.onAdd(product);
                          setState(() {});
                        },
                        onRemove: () {
                          widget.onRemove(product);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CartPage extends StatelessWidget {
  const _CartPage({
    required this.language,
    required this.cartLines,
    required this.shopNameController,
    required this.phoneController,
    required this.noteController,
    required this.isSubmitting,
    required this.onAdd,
    required this.onRemove,
    required this.onDetailsChanged,
    required this.onSubmit,
  });

  final AppLanguage language;
  final List<_CartLine> cartLines;
  final TextEditingController shopNameController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final bool isSubmitting;
  final ValueChanged<_CatalogProduct> onAdd;
  final ValueChanged<_CatalogProduct> onRemove;
  final VoidCallback onDetailsChanged;
  final VoidCallback onSubmit;

  int get totalQuantity =>
      cartLines.fold(0, (total, line) => total + line.quantity);

  double get totalAmount => cartLines.fold(
    0,
    (total, line) => total + (line.product.price * line.quantity),
  );

  @override
  Widget build(BuildContext context) {
    if (cartLines.isEmpty) {
      return _EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: AppLocalizations.text(language, 'cartEmptyTitle'),
        message: AppLocalizations.text(language, 'cartEmptyMessage'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryStrip(
          title: '${cartLines.length} products',
          subtitle:
              '$totalQuantity total quantity | Rs. ${totalAmount.toStringAsFixed(0)} total',
          icon: Icons.shopping_cart_checkout,
        ),
        const SizedBox(height: 14),
        Text(
          AppLocalizations.text(language, 'cartItems'),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        for (final line in cartLines) ...[
          _CartLineTile(
            line: line,
            onAdd: () => onAdd(line.product),
            onRemove: () => onRemove(line.product),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        _CartSummaryPanel(cartLines: cartLines),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.text(language, 'retailerDetails'),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: shopNameController,
          onChanged: (_) => onDetailsChanged(),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: AppLocalizations.text(language, 'shopNameLabel'),
            prefixIcon: const Icon(Icons.storefront_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          onChanged: (_) => onDetailsChanged(),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: AppLocalizations.text(language, 'phoneLabel'),
            prefixIcon: const Icon(Icons.call_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          onChanged: (_) => onDetailsChanged(),
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: AppLocalizations.text(language, 'orderNoteLabel'),
            prefixIcon: const Icon(Icons.note_alt_outlined),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: isSubmitting ? null : onSubmit,
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: Text(isSubmitting
              ? AppLocalizations.text(language, 'submittingOrder')
              : AppLocalizations.text(language, 'submitOrder')),
        ),
      ],
    );
  }
}

class _OrdersPage extends StatelessWidget {
  const _OrdersPage({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _EmptyState(
        icon: Icons.login,
        title: AppLocalizations.text(language, 'loginRequired'),
        message: AppLocalizations.text(language, 'loginToViewOrders'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('retailerUid', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.warning_amber_outlined,
            title: AppLocalizations.text(language, 'ordersLoadFailed'),
            message: AppLocalizations.text(language, 'ordersLoadHelp'),
          );
        }

        final docs = [...snapshot.data?.docs ?? []];
        docs.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });
        if (docs.isEmpty) {
          return _EmptyState(
            icon: Icons.receipt_long_outlined,
            title: AppLocalizations.text(language, 'noOrdersYet'),
            message: AppLocalizations.text(language, 'firstOrderPrompt'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _OrderTile(
              orderId: docs[index].id,
              data: docs[index].data(),
            );
          },
        );
      },
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({required this.notifications});

  final List<Map<String, dynamic>> notifications;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _EmptyState(
        icon: Icons.notifications_none_outlined,
        title: 'No notifications',
        message: 'Notifications will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.notifications_active,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              notification['title']?.toString() ?? 'Notification',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              notification['body']?.toString() ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              notification['timestamp']?.toString() ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({required this.language, required this.onSignOut});

  final AppLanguage language;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryStrip(
          title: user?.displayName?.isNotEmpty == true
              ? user!.displayName!
              : AppLocalizations.text(language, 'retailerAccount'),
          subtitle: AppLocalizations.text(language, 'retailerAccount'),
          icon: Icons.person,
        ),
        const SizedBox(height: 14),
        _InfoPanel(
          title: AppLocalizations.text(language, 'wholesalerOrdersInfoTitle'),
          lines: [
            AppLocalizations.text(language, 'wholesalerOrdersInfoLine1'),
            AppLocalizations.text(language, 'wholesalerOrdersInfoLine2'),
            AppLocalizations.text(language, 'wholesalerOrdersInfoLine3'),
          ],
        ),
        const SizedBox(height: 14),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.text(language, 'selectLanguage')),
          subtitle: Text(language.displayName),
          onTap: () => showLanguageSelectorDialog(context),
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: Text(AppLocalizations.text(language, 'logout')),
        ),
      ],
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _statusFilter = 'all';
  int _selectedAdminTab = 0;

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'status': status,
            'statusUpdatedAt': FieldValue.serverTimestamp(),
            'statusUpdatedBy': FirebaseAuth.instance.currentUser?.uid,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status set to $status.')),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.code == 'permission-denied'
                  ? 'Admin permission required.'
                  : 'Status update failed. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _BrandHeader(subtitle: 'Wholesaler admin dashboard'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _showPriceNotifier,
            builder: (context, show, child) {
              return IconButton(
                tooltip: show ? 'Hide Prices' : 'Show Prices',
                icon: Icon(show ? Icons.visibility : Icons.visibility_off),
                onPressed: () => _handlePriceVisibilityToggle(context),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _selectedAdminTab == 0
          ? _AdminOrdersPage(
              statusFilter: _statusFilter,
              onStatusFilterChanged: (filter) {
                setState(() => _statusFilter = filter);
              },
              onStatusChanged: _updateOrderStatus,
            )
          : _selectedAdminTab == 1
          ? const _AdminProductsPage()
          : _selectedAdminTab == 2
          ? const _AdminCategoriesPage()
          : const _AdminUsersPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedAdminTab,
        onDestinationSelected: (index) {
          setState(() => _selectedAdminTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_outlined),
            selectedIcon: Icon(Icons.person_add),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}

class _AdminOrdersPage extends StatelessWidget {
  const _AdminOrdersPage({
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.onStatusChanged,
  });

  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final void Function(String orderId, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            scrollDirection: Axis.horizontal,
            itemCount: _adminStatusFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _adminStatusFilters[index];
              return ChoiceChip(
                label: Text(_statusLabel(filter)),
                selected: statusFilter == filter,
                onSelected: (_) => onStatusFilterChanged(filter),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingScreen();
              }

              if (snapshot.hasError) {
                return const _EmptyState(
                  icon: Icons.warning_amber_outlined,
                  title: 'Orders failed to load',
                  message: 'Check Firestore rules/index settings.',
                );
              }

              final allDocs = snapshot.data?.docs ?? [];
              final docs = statusFilter == 'all'
                  ? allDocs
                  : allDocs.where((doc) {
                      return doc.data()['status'] == statusFilter;
                    }).toList();
              if (docs.isEmpty) {
                return const _EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders found',
                  message: 'New retailer orders will appear here after submission.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return _OrderTile(
                    orderId: doc.id,
                    data: doc.data(),
                    showRetailerDetails: true,
                    onStatusChanged: (status) =>
                        onStatusChanged(doc.id, status),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminProductsPage extends StatelessWidget {
  const _AdminProductsPage();

  Future<void> _openProductForm(
    BuildContext context, {
    QueryDocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final data = doc?.data();
    final nameController = TextEditingController(
      text: data?['name']?.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: data?['category']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: data?['description']?.toString() ?? '',
    );
    final unitController = TextEditingController(
      text: data?['unit']?.toString() ?? 'pcs',
    );
    final priceController = TextEditingController(
      text: (data?['price'] ?? '').toString(),
    );
    final moqController = TextEditingController(
      text: (data?['minimumOrderQuantity'] ?? '1').toString(),
    );
    final imageController = TextEditingController(
      text: data?['imageUrl']?.toString() ?? '',
    );
    var selectedImageUrl = imageController.text;
    var isUploadingImage = false;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> categories = [];
    try {
      final categoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('active', isEqualTo: true)
          .get();
      categories = [...categoriesSnapshot.docs];
      categories.sort((a, b) {
        final aOrder = a.data()['sortOrder'];
        final bOrder = b.data()['sortOrder'];
        final aValue = aOrder is int ? aOrder : 0;
        final bValue = bOrder is int ? bOrder : 0;
        return aValue.compareTo(bValue);
      });
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.code == 'permission-denied'
                  ? 'Check category read permission.'
                  : 'Categories failed to load. Please enter them manually.',
            ),
          ),
        );
      }
    }
    if (!context.mounted) {
      return;
    }
    String? selectedCategoryId;
    if (categories.isNotEmpty) {
      selectedCategoryId = categories
          .firstWhere(
            (doc) => doc.data()['name']?.toString() == categoryController.text,
            orElse: () => categories.first,
          )
          .id;
      categoryController.text =
          categories
              .firstWhere((doc) => doc.id == selectedCategoryId)
              .data()['name']
              ?.toString() ??
          categoryController.text;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(doc == null ? 'Add product' : 'Edit product'),
          content: StatefulBuilder(
            builder: (dialogContext, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: categories.map((doc) {
                          final categoryName =
                              doc.data()['name']?.toString() ?? '';
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(categoryName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryId = value;
                            final match = categories.firstWhere(
                              (doc) => doc.id == value,
                              orElse: () => categories.first,
                            );
                            categoryController.text =
                                match.data()['name']?.toString() ?? '';
                          });
                        },
                      )
                    else
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unitController,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: moqController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minimum order quantity',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ImagePickerField(
                      label: 'Product image',
                      imageUrl: selectedImageUrl,
                      isUploading: isUploadingImage,
                      onPick: () async {
                        setState(() => isUploadingImage = true);
                        final downloadUrl = await _pickAndUploadImage(
                          context,
                          'product_images',
                        );
                        setState(() {
                          isUploadingImage = false;
                          if (downloadUrl != null) {
                            selectedImageUrl = downloadUrl;
                            imageController.text = downloadUrl;
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final category = selectedCategoryId != null
                    ? categories
                              .firstWhere((doc) => doc.id == selectedCategoryId)
                              .data()['name']
                              ?.toString()
                              .trim() ??
                          categoryController.text.trim()
                    : categoryController.text.trim();
                if (name.isEmpty || category.isEmpty) {
                  return;
                }

                if (selectedImageUrl.startsWith('data:image')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cannot save Base64 image. Upload using the Select button.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final moq = int.tryParse(moqController.text.trim()) ?? 1;
                final productData = <String, dynamic>{
                  'name': name,
                  'category': category,
                  'description': descriptionController.text.trim(),
                  'unit': unitController.text.trim().isEmpty
                      ? 'pcs'
                      : unitController.text.trim(),
                  'price': price,
                  'minimumOrderQuantity': moq < 1 ? 1 : moq,
                  'imageUrl': selectedImageUrl.trim(),
                  'categoryId': selectedCategoryId,
                  'active': true,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (doc == null) {
                  await FirebaseFirestore.instance.collection('products').add({
                    ...productData,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  // Update updates existing fields and DELETES imageData to keep it clean
                  await doc.reference.update({
                    ...productData,
                    'imageData': FieldValue.delete(),
                  });
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // Keep dialog controllers alive until Flutter fully tears down the route.
    // Disposing immediately after Navigator.pop can trip TextField dependents
    // during the dialog closing animation on some devices.
  }

  Future<void> _deleteProduct(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    await doc.reference.update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingScreen();
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const _EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Firebase products',
              message:
                  'Add a product so the catalog updates automatically from Firestore.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final product = _CatalogProduct.fromFirestore(doc);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _ProductThumb(product: product),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.category} | Rs. ${product.price.toStringAsFixed(0)} | MOQ ${product.minimumOrderQuantity}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => _openProductForm(context, doc: doc),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteProduct(doc),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
    );
  }
}

class _AdminCategoriesPage extends StatelessWidget {
  const _AdminCategoriesPage();

  Future<void> _openCategoryForm(
    BuildContext context, {
    QueryDocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final data = doc?.data();
    final nameController = TextEditingController(
      text: data?['name']?.toString() ?? '',
    );
    final imageController = TextEditingController(
      text: data?['imageUrl']?.toString() ?? '',
    );
    var selectedImageUrl = imageController.text;
    var isUploadingImage = false;
    final sortController = TextEditingController(
      text: (data?['sortOrder'] ?? '0').toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(doc == null ? 'Add category' : 'Edit category'),
          content: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ImagePickerField(
                    label: 'Category image',
                    imageUrl: selectedImageUrl,
                    isUploading: isUploadingImage,
                    onPick: () async {
                      setState(() => isUploadingImage = true);
                      final downloadUrl = await _pickAndUploadImage(
                        context,
                        'category_images',
                      );
                      setState(() {
                        isUploadingImage = false;
                        if (downloadUrl != null) {
                          selectedImageUrl = downloadUrl;
                          imageController.text = downloadUrl;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: sortController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sort order'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }

                if (selectedImageUrl.startsWith('data:image')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cannot save Base64 image. Upload using the Select button.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final data = <String, dynamic>{
                  'name': name,
                  'imageUrl': selectedImageUrl.trim(),
                  'sortOrder': int.tryParse(sortController.text.trim()) ?? 0,
                  'active': true,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (doc == null) {
                  await FirebaseFirestore.instance.collection('categories').add(
                    {...data, 'createdAt': FieldValue.serverTimestamp()},
                  );
                } else {
                  // Ensure imageData is removed during update
                  await doc.reference.update({
                    ...data,
                    'imageData': FieldValue.delete(),
                  });
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // Keep dialog controllers alive until Flutter fully tears down the route.
    // Disposing immediately after Navigator.pop can trip TextField dependents
    // during the dialog closing animation on some devices.
  }

  Future<void> _deleteCategory(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    await doc.reference.update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingScreen();
          }

          final docs = [...snapshot.data?.docs ?? []];
          docs.sort((a, b) {
            final aOrder = a.data()['sortOrder'];
            final bOrder = b.data()['sortOrder'];
            final aValue = aOrder is int ? aOrder : 0;
            final bValue = bOrder is int ? bOrder : 0;
            return aValue.compareTo(bValue);
          });

          if (docs.isEmpty) {
            return const _EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories',
              message:
                  'Add a category. Use the same category name in the product form.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = data['name']?.toString() ?? 'Category';
              final imageUrl =
                  data['imageUrl']?.toString() ??
                  data['imageData']?.toString() ??
                  '';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _colorForCategory(name).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imageUrl.isEmpty
                          ? Icon(
                              _iconForCategory(name),
                              color: _colorForCategory(name),
                            )
                          : _ImageFromSource(
                              source: imageUrl,
                              fallbackIcon: _iconForCategory(name),
                              fallbackColor: _colorForCategory(name),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sort: ${data['sortOrder'] ?? 0}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => _openCategoryForm(context, doc: doc),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteCategory(doc),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCategoryForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Category'),
      ),
    );
  }
}

class _WholesaleBanner extends StatelessWidget {
  const _WholesaleBanner({required this.onOpenCart});

  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12372A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC857),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Wholesale order book',
              style: TextStyle(
                color: Color(0xFF12372A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Toran, Jummar, Mandir Set ane festival novelty items',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Retailer selects products, adds quantities, and places orders directly to wholesaler via Firestore.',
            style: TextStyle(color: Color(0xFFD1FAE5), height: 1.35),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Review cart'),
          ),
        ],
      ),
    );
  }
}

void _openProductImage(BuildContext context, _CatalogProduct product) {
  if (product.imageUrl.trim().isEmpty) {
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _ProductImageFullscreenPage(
        source: product.imageUrl,
        fallbackIcon: product.icon,
        fallbackColor: product.color,
        heroTag: 'product-card-image-${product.id}',
      ),
    ),
  );
}

class _ProductLargeCard extends StatelessWidget {
  const _ProductLargeCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final _CatalogProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: product.imageUrl.trim().isEmpty
                    ? null
                    : () => _openProductImage(context, product),
                child: Hero(
                  tag: 'product-card-image-${product.id}',
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: product.imageUrl.isEmpty
                        ? Container(
                            color: product.color.withValues(alpha: 0.1),
                            child: Icon(
                              product.icon,
                              size: 80,
                              color: product.color,
                            ),
                          )
                        : _ImageFromSource(
                            source: product.imageUrl,
                            fallbackIcon: product.icon,
                            fallbackColor: product.color,
                          ),
                  ),
                ),
              ),
              if (product.imageUrl.trim().isNotEmpty)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.zoom_out_map,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showPriceNotifier,
                  builder: (context, show, child) {
                    if (!show) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (product.minimumOrderQuantity > 1)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MOQ: ${product.minimumOrderQuantity} ${product.unit}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : 'High quality ${product.category} item.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _showPriceNotifier,
                      builder: (context, show, child) {
                        if (!show) {
                          return const Expanded(
                            child: Text(
                              'Price Hidden',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Price',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${(product.price * (quantity > 0 ? quantity : 1)).toStringAsFixed(0)}',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 0 ? onRemove : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: theme.colorScheme.primary,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add_circle),
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailPage extends StatefulWidget {
  const _ProductDetailPage({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final _CatalogProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  State<_ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<_ProductDetailPage> {
  late int _localQuantity;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.quantity;
  }

  @override
  void didUpdateWidget(covariant _ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity &&
        widget.quantity != _localQuantity) {
      setState(() {
        _localQuantity = widget.quantity;
      });
    }
  }

  void _increment() {
    setState(() {
      if (_localQuantity == 0) {
        _localQuantity = widget.product.minimumOrderQuantity;
      } else {
        _localQuantity++;
      }
    });
    widget.onAdd();
  }

  void _decrement() {
    if (_localQuantity == 0) return;
    setState(() {
      if (_localQuantity <= widget.product.minimumOrderQuantity) {
        _localQuantity = 0;
      } else {
        _localQuantity--;
      }
    });
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    final totalPrice = product.price * _localQuantity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                if (product.imageUrl.trim().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _ProductImageFullscreenPage(
                            source: product.imageUrl,
                            fallbackIcon: product.icon,
                            fallbackColor: product.color,
                            heroTag: 'product-image-${product.id}',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'product-image-${product.id}',
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                        ),
                        child: _ImageFromSource(
                          source: product.imageUrl,
                          fallbackIcon: product.icon,
                          fallbackColor: product.color,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: product.color.withValues(alpha: 0.1),
                    child: Icon(product.icon, size: 100, color: product.color),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tap to zoom',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: product.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                product.category,
                                style: TextStyle(
                                  color: product.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _showPriceNotifier,
                        builder: (context, show, child) {
                          if (!show) {
                            return const Expanded(
                              child: Text(
                                'Price Hidden',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'per ${product.unit}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Order Info
                  Row(
                    children: [
                      _infoCard(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Min Order',
                        value:
                            '${product.minimumOrderQuantity} ${product.unit}',
                      ),
                      const SizedBox(width: 12),
                      _infoCard(
                        icon: Icons.shopping_cart_outlined,
                        label: 'In Cart',
                        value: _localQuantity > 0
                            ? '$_localQuantity ${product.unit}'
                            : 'Empty',
                        highlight: _localQuantity > 0,
                        highlightColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),

                  if (_localQuantity > 0) ...[
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: _showPriceNotifier,
                      builder: (context, show, child) {
                        if (!show) return const SizedBox.shrink();
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'No description available for this product.',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 120), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _localQuantity > 0 ? _decrement : null,
                    icon: const Icon(Icons.remove),
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_localQuantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _increment,
                    icon: const Icon(Icons.add),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: _increment,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  _localQuantity > 0 ? 'Add More' : 'Add to Cart',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
    Color? highlightColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlight
              ? (highlightColor?.withValues(alpha: 0.05) ??
                    const Color(0xFFF8FAFC))
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight
                ? (highlightColor?.withValues(alpha: 0.2) ??
                      const Color(0xFFE2E8F0))
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: highlight ? highlightColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: highlight ? highlightColor : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImageFullscreenPage extends StatelessWidget {
  const _ProductImageFullscreenPage({
    required this.source,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.heroTag,
  });

  final String source;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity!.abs() > 300) {
            Navigator.of(context).pop();
          }
        },
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 1.0,
              maxScale: 4.0,
              panEnabled: true,
              child: AspectRatio(
                aspectRatio: 1,
                child: _ImageFromSource(
                  source: source,
                  fallbackIcon: fallbackIcon,
                  fallbackColor: fallbackColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.product, this.size = 54});

  final _CatalogProduct product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl.trim();

    return Container(
      height: size,
      width: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: product.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl.isEmpty
          ? Icon(product.icon, color: product.color)
          : _ImageFromSource(
              source: imageUrl,
              fallbackIcon: product.icon,
              fallbackColor: product.color,
            ),
    );
  }
}

class _ImageFromSource extends StatelessWidget {
  const _ImageFromSource({
    required this.source,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final String source;
  final IconData fallbackIcon;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) {
      return Center(child: Icon(fallbackIcon, color: fallbackColor, size: 48));
    }

    if (source.startsWith('data:image')) {
      final commaIndex = source.indexOf(',');
      if (commaIndex > -1) {
        try {
          final bytes = base64Decode(source.substring(commaIndex + 1));
          return Image.memory(bytes, fit: BoxFit.cover);
        } catch (_) {
          return Center(
            child: Icon(fallbackIcon, color: fallbackColor, size: 48),
          );
        }
      }
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (_, _, _) =>
          Center(child: Icon(fallbackIcon, color: fallbackColor, size: 48)),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.label,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
  });

  final String label;
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl.trim().isEmpty
                ? const Icon(Icons.image_outlined)
                : _ImageFromSource(
                    source: imageUrl,
                    fallbackIcon: Icons.broken_image,
                    fallbackColor: const Color(0xFF64748B),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: isUploading ? null : onPick,
            icon: isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_library_outlined),
            label: Text(isUploading ? 'Uploading' : 'Select'),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return IconButton.filled(
        tooltip: 'Add',
        onPressed: onAdd,
        icon: const Icon(Icons.add),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Remove',
          onPressed: onRemove,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        IconButton.filled(
          tooltip: 'Add',
          onPressed: onAdd,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onAdd,
    required this.onRemove,
  });

  final _CartLine line;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final lineTotal = line.product.price * line.quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(product: line.product),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${line.product.category} / ${line.product.unit}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs. ${line.product.price.toStringAsFixed(0)} x ${line.quantity} = Rs. ${lineTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityStepper(
            quantity: line.quantity,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
        ],
      ),
    );
  }
}

class _CartSummaryPanel extends StatelessWidget {
  const _CartSummaryPanel({required this.cartLines});

  final List<_CartLine> cartLines;

  int get totalQuantity =>
      cartLines.fold(0, (total, line) => total + line.quantity);

  double get totalAmount => cartLines.fold(
    0,
    (total, line) => total + (line.product.price * line.quantity),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final line in cartLines) ...[
            _CartSummaryRow(line: line),
            const Divider(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total ($totalQuantity pcs)',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Rs. ${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  const _CartSummaryRow({required this.line});

  final _CartLine line;

  @override
  Widget build(BuildContext context) {
    final lineTotal = line.product.price * line.quantity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 42,
            height: 42,
            child: _ProductThumb(product: line.product, size: 42),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                '${line.quantity} ${line.product.unit} x Rs. ${line.product.price.toStringAsFixed(0)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Rs. ${lineTotal.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

double _numberFrom(dynamic value) => value is num ? value.toDouble() : 0;

int _intFrom(dynamic value) => value is int
    ? value
    : value is num
    ? value.toInt()
    : int.tryParse(value?.toString() ?? '') ?? 0;

double _itemLineTotal(dynamic item) {
  if (item is! Map) {
    return 0;
  }

  final savedLineTotal = _numberFrom(item['lineTotal']);
  if (savedLineTotal > 0) {
    return savedLineTotal;
  }

  return _numberFrom(item['price']) * _intFrom(item['quantity']);
}

double _orderTotalAmount(Map<String, dynamic> data) {
  final savedTotal = _numberFrom(data['totalAmount']);
  if (savedTotal > 0) {
    return savedTotal;
  }

  final items = data['items'] as List<dynamic>? ?? [];
  return items.fold(0, (total, item) => total + _itemLineTotal(item));
}

class _OrderItemThumb extends StatelessWidget {
  const _OrderItemThumb({required this.item});

  final Map<dynamic, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['imageUrl']?.toString().trim() ?? '';
    final category = item['category']?.toString() ?? '';
    final icon = _iconForCategory(category);
    final color = _colorForCategory(category);

    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl.isEmpty
          ? Icon(icon, color: color)
          : _ImageFromSource(
              source: imageUrl,
              fallbackIcon: icon,
              fallbackColor: color,
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.orderId,
    required this.data,
    this.showRetailerDetails = false,
    this.onStatusChanged,
  });

  final String orderId;
  final Map<String, dynamic> data;
  final bool showRetailerDetails;
  final ValueChanged<String>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List<dynamic>? ?? []);
    final status = data['status']?.toString() ?? 'new';
    final totalAmount = _orderTotalAmount(data);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data['shopName']?.toString() ?? 'Order',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              onStatusChanged == null
                  ? Chip(
                      label: Text(_statusLabel(status).toUpperCase()),
                      visualDensity: VisualDensity.compact,
                    )
                  : DropdownButton<String>(
                      value: _orderStatuses.contains(status) ? status : 'new',
                      items: _orderStatuses
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_statusLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onStatusChanged!(value);
                        }
                      },
                    ),
            ],
          ),
          const SizedBox(height: 6),
          if (showRetailerDetails) ...[
            Text(
              'User name: ${data['retailerName'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              'Phone: ${data['phone'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Order ID: $orderId',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 10),
          for (final item in items.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (item is Map) ...[
                    _OrderItemThumb(item: item),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      '${item['name']} x ${item['quantity']} ${item['unit']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'Rs. ${_itemLineTotal(item).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          if (items.length > 4)
            Text(
              '+${items.length - 4} more items',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          if ((data['note']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Note: ${data['note']}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${data['totalQuantity'] ?? items.length} total quantity',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
              Text(
                'Total: Rs. ${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showOrderDetails(context, orderId, data),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Details'),
              ),
              OutlinedButton.icon(
                onPressed: () => _shareOrderPdf(orderId, data),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF'),
              ),
              OutlinedButton.icon(
                onPressed: () => _sendOrderOnWhatsApp(data),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp'),
              ),
              if ((onStatusChanged == null && status == 'new') ||
                  onStatusChanged != null)
                OutlinedButton.icon(
                  onPressed: () => _handleDeleteOrder(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order?'),
        content: const Text('Are you sure? Aa order delete thai jashe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Yes, Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order successfully delete kari didho.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Order delete nathi thayo.')),
          );
        }
      }
    }
  }
}

void _showOrderDetails(
  BuildContext context,
  String orderId,
  Map<String, dynamic> data,
) {
  final items = data['items'] as List<dynamic>? ?? [];
  final totalAmount = _orderTotalAmount(data);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.92,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                data['shopName']?.toString() ?? 'Order details',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text('Order ID: $orderId'),
              Text(
                'Status: ${_statusLabel(data['status']?.toString() ?? 'new')}',
              ),
              Text('Phone: ${data['phone'] ?? '-'}'),
              const SizedBox(height: 14),
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: item is Map ? _OrderItemThumb(item: item) : null,
                  title: Text(item['name']?.toString() ?? 'Item'),
                  subtitle: Text(
                    '${item['category'] ?? ''} | ${item['quantity']} ${item['unit'] ?? 'pcs'} x Rs. ${((item['price'] as num?) ?? 0).toStringAsFixed(0)}',
                  ),
                  trailing: Text(
                    'Rs. ${_itemLineTotal(item).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              const Divider(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Grand total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    'Rs. ${totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _shareOrderPdf(orderId, data),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Share / print PDF'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _shareOrderPdf(String orderId, Map<String, dynamic> data) async {
  final document = pw.Document();
  final items = data['items'] as List<dynamic>? ?? [];
  final totalAmount = _orderTotalAmount(data);

  document.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Dhanlaxmi Novelty',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Wholesale Order'),
            pw.Text('Order ID: $orderId'),
            pw.Text('Shop: ${data['shopName'] ?? '-'}'),
            pw.Text('Phone: ${data['phone'] ?? '-'}'),
            pw.Text(
              'Status: ${_statusLabel(data['status']?.toString() ?? 'new')}',
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Category', 'Qty', 'Unit', 'Price', 'Total'],
              data: items.map((item) {
                return [
                  item['name']?.toString() ?? '',
                  item['category']?.toString() ?? '',
                  item['quantity']?.toString() ?? '',
                  item['unit']?.toString() ?? '',
                  'Rs. ${((item['price'] as num?) ?? 0).toStringAsFixed(0)}',
                  'Rs. ${_itemLineTotal(item).toStringAsFixed(0)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 14),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: Rs. ${totalAmount.toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if ((data['note']?.toString() ?? '').isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text('Note: ${data['note']}'),
            ],
          ],
        );
      },
    ),
  );

  await Printing.sharePdf(
    bytes: await document.save(),
    filename: 'dhanlaxmi-order-$orderId.pdf',
  );
}

Future<void> _sendOrderOnWhatsApp(Map<String, dynamic> data) async {
  final phone =
      data['phone']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  final items = data['items'] as List<dynamic>? ?? [];
  final totalAmount = _orderTotalAmount(data);
  final lines = [
    'Dhanlaxmi Novelty Order',
    'Shop: ${data['shopName'] ?? '-'}',
    'Status: ${_statusLabel(data['status']?.toString() ?? 'new')}',
    '',
    for (final item in items)
      '${item['name']} x ${item['quantity']} ${item['unit'] ?? ''} = Rs. ${_itemLineTotal(item).toStringAsFixed(0)}',
    '',
    'Total: Rs. ${totalAmount.toStringAsFixed(0)}',
  ];
  final message = Uri.encodeComponent(lines.join('\n'));
  final uri = Uri.parse(
    phone.isEmpty
        ? 'https://wa.me/?text=$message'
        : 'https://wa.me/91$phone?text=$message',
  );

  const channel = MethodChannel('d1/whatsapp');
  await channel.invokeMethod<void>('openWhatsApp', {'url': uri.toString()});
}

Future<String?> _pickAndUploadImage(BuildContext context, String folder) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _showUploadError(context, 'Please log in before uploading images.');
    return null;
  }

  XFile? picked;
  try {
    picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 75,
    );
  } on PlatformException catch (error) {
    debugPrint('Image picker failed: ${error.code} ${error.message}');
    if (context.mounted) {
      _showUploadError(
        context,
        'Gallery could not open. Allow photo permission and try again.',
      );
    }
    return null;
  }

  if (picked == null) {
    return null;
  }

  try {
    final fileBytes = await picked.readAsBytes();
    const maxUploadBytes = 5 * 1024 * 1024;
    if (fileBytes.length >= maxUploadBytes) {
      if (context.mounted) {
        _showUploadError(
          context,
          'Image must be smaller than 5 MB. Please select a different image.',
        );
      }
      return null;
    }

    final contentType = _contentTypeForImage(picked);
    if (contentType == null) {
      if (context.mounted) {
        _showUploadError(
          context,
          'Please select a JPG, PNG, GIF, or WEBP image.',
        );
      }
      return null;
    }

    final safeFolder = folder.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fileExtension = _extensionForContentType(contentType);
    final fileName =
        '${user.uid}_${DateTime.now().microsecondsSinceEpoch}.$fileExtension';

    final upload = await _uploadImageToCloudinary(
      folder: safeFolder,
      fileName: fileName,
      fileBytes: fileBytes,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload thai gai.')));
    }
    return upload;
  } catch (error) {
    debugPrint('Image upload failed: $error');
    if (context.mounted) {
      _showUploadError(
        context,
        'Image upload failed. Please try again.',
      );
    }
    return null;
  }
}

Future<String> _uploadImageToCloudinary({
  required String folder,
  required String fileName,
  required Uint8List fileBytes,
}) async {
  final uri = Uri.https('api.cloudinary.com', '/v1_1/dyonkudly/image/upload');
  final publicId = fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = 'Dhanlaxmi'
    ..fields['folder'] = folder
    ..fields['public_id'] = publicId
    ..files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

  debugPrint('Trying Cloudinary image upload: folder=$folder file=$fileName');

  final response = await http.Response.fromStream(await request.send());
  if (response.statusCode < 200 || response.statusCode >= 300) {
    debugPrint(
      'Cloudinary upload failed: ${response.statusCode} ${response.body}',
    );
    throw Exception(_friendlyCloudinaryError(response));
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final secureUrl = data['secure_url']?.toString();
  if (secureUrl == null || secureUrl.isEmpty) {
    throw Exception('Cloudinary image URL missing.');
  }

  return secureUrl;
}

String? _contentTypeForImage(XFile image) {
  final mimeType = image.mimeType?.toLowerCase();
  if (mimeType != null && mimeType.startsWith('image/')) {
    return mimeType;
  }

  final path = image.path.toLowerCase();
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (path.endsWith('.png')) {
    return 'image/png';
  }
  if (path.endsWith('.gif')) {
    return 'image/gif';
  }
  if (path.endsWith('.webp')) {
    return 'image/webp';
  }
  return null;
}

String _extensionForContentType(String contentType) {
  switch (contentType) {
    case 'image/png':
      return 'png';
    case 'image/gif':
      return 'gif';
    case 'image/webp':
      return 'webp';
    default:
      return 'jpg';
  }
}

String _friendlyCloudinaryError(http.Response response) {
  try {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final message = (data['error'] as Map<String, dynamic>?)?['message']
        ?.toString();
    if (message != null && message.isNotEmpty) {
      return 'Cloudinary upload failed: $message';
    }
  } catch (_) {
    // Fall back to the generic message below.
  }

  if (response.statusCode == 400 || response.statusCode == 401) {
    return 'Check your Cloudinary cloud name and upload preset.';
  }
  return 'Cloudinary upload failed. Please try again.';
}

void _showUploadError(BuildContext context, String message) {
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF1E3A8A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final line in lines) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(line)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.storefront, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dhanlaxmi Novelty',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFBE123C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF9F1239),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogCategory {
  const _CatalogCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.products,
    this.imageUrl = '',
  });

  final String name;
  final IconData icon;
  final Color color;
  final List<_CatalogProduct> products;
  final String imageUrl;
}

class _CatalogProduct {
  const _CatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.unit,
    required this.icon,
    required this.color,
    this.price = 0,
    this.minimumOrderQuantity = 1,
    this.imageUrl = '',
  });

  factory _CatalogProduct.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final category = data['category']?.toString() ?? 'Other Novelty';
    final priceValue = data['price'];
    final moqValue = data['minimumOrderQuantity'];

    return _CatalogProduct(
      id: doc.id,
      name: data['name']?.toString() ?? 'Product',
      category: category,
      description: data['description']?.toString() ?? '',
      unit: data['unit']?.toString() ?? 'pcs',
      icon: _iconForCategory(category),
      color: _colorForCategory(category),
      price: priceValue is num ? priceValue.toDouble() : 0.0,
      minimumOrderQuantity: moqValue is int ? moqValue : 1,
      imageUrl: data['imageUrl']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String category;
  final String description;
  final String unit;
  final IconData icon;
  final Color color;
  final double price;
  final int minimumOrderQuantity;
  final String imageUrl;
}

class _CartLine {
  const _CartLine({required this.product, required this.quantity});

  final _CatalogProduct product;
  final int quantity;

  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'name': product.name,
      'category': product.category,
      'unit': product.unit,
      'price': product.price,
      'minimumOrderQuantity': product.minimumOrderQuantity,
      'lineTotal': product.price * quantity,
      'imageUrl': product.imageUrl,
      'quantity': quantity,
    };
  }
}

_CatalogProduct? _findProductById(String? productId) {
  if (productId == null) {
    return null;
  }

  for (final category in _catalogCategories) {
    for (final product in category.products) {
      if (product.id == productId) {
        return product;
      }
    }
  }

  return null;
}

_CatalogProduct? _productFromCartItem(Map<dynamic, dynamic> item) {
  final productId = item['productId']?.toString();
  final name = item['name']?.toString();
  if (productId == null || name == null) {
    return null;
  }

  final category = item['category']?.toString() ?? 'Other Novelty';
  final price = item['price'];
  final moq = item['minimumOrderQuantity'];

  return _CatalogProduct(
    id: productId,
    name: name,
    category: category,
    description: item['description']?.toString() ?? '',
    unit: item['unit']?.toString() ?? 'pcs',
    icon: _iconForCategory(category),
    color: _colorForCategory(category),
    price: price is num ? price.toDouble() : 0,
    minimumOrderQuantity: moq is int ? moq : 1,
    imageUrl: item['imageUrl']?.toString() ?? '',
  );
}

List<_CatalogCategory> _categoriesFromProductDocs(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> productDocs,
  List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs,
) {
  if (productDocs.isEmpty) {
    return _catalogCategories;
  }

  final groups = <String, List<_CatalogProduct>>{};
  for (final doc in productDocs) {
    final product = _CatalogProduct.fromFirestore(doc);
    groups.putIfAbsent(product.category, () => []).add(product);
  }

  if (categoryDocs.isEmpty) {
    return groups.entries.map((entry) {
      return _CatalogCategory(
        name: entry.key,
        icon: _iconForCategory(entry.key),
        color: _colorForCategory(entry.key),
        products: entry.value,
        imageUrl: '',
      );
    }).toList();
  }

  final categories = [...categoryDocs];
  categories.sort((a, b) {
    final aOrder = a.data()['sortOrder'];
    final bOrder = b.data()['sortOrder'];
    final aValue = aOrder is int ? aOrder : 0;
    final bValue = bOrder is int ? bOrder : 0;
    return aValue.compareTo(bValue);
  });

  final orderedCategories = <_CatalogCategory>[];
  for (final doc in categories) {
    final name = doc.data()['name']?.toString() ?? '';
    final imageUrl = doc.data()['imageUrl']?.toString() ?? '';
    final products = groups.remove(name) ?? [];
    if (products.isNotEmpty) {
      orderedCategories.add(
        _CatalogCategory(
          name: name,
          icon: _iconForCategory(name),
          color: _colorForCategory(name),
          products: products,
          imageUrl: imageUrl,
        ),
      );
    }
  }

  for (final entry in groups.entries) {
    orderedCategories.add(
      _CatalogCategory(
        name: entry.key,
        icon: _iconForCategory(entry.key),
        color: _colorForCategory(entry.key),
        products: entry.value,
        imageUrl: '',
      ),
    );
  }

  return orderedCategories.isEmpty ? _catalogCategories : orderedCategories;
}

IconData _iconForCategory(String category) {
  final value = category.toLowerCase();
  if (value.contains('toran')) {
    return Icons.vertical_align_top;
  }
  if (value.contains('jummar')) {
    return Icons.light_outlined;
  }
  if (value.contains('mandir')) {
    return Icons.temple_hindu_outlined;
  }
  if (value.contains('matki')) {
    return Icons.local_florist_outlined;
  }
  if (value.contains('chuddi')) {
    return Icons.circle_outlined;
  }
  return Icons.category_outlined;
}

Color _colorForCategory(String category) {
  final value = category.toLowerCase();
  if (value.contains('toran')) {
    return const Color(0xFF0F766E);
  }
  if (value.contains('jummar')) {
    return const Color(0xFF7C3AED);
  }
  if (value.contains('mandir')) {
    return const Color(0xFFE76F51);
  }
  if (value.contains('matki')) {
    return const Color(0xFFB45309);
  }
  if (value.contains('chuddi')) {
    return const Color(0xFFDB2777);
  }
  return const Color(0xFF2563EB);
}

const List<String> _orderStatuses = ['new', 'confirmed', 'packed', 'delivered'];

const List<String> _adminStatusFilters = [
  'all',
  'new',
  'confirmed',
  'packed',
  'delivered',
];

const Set<String> _adminEmails = {'krunalpativala@gmail.com'};

final ValueNotifier<bool> _showPriceNotifier = ValueNotifier<bool>(true);
const String _priceVisibilityPassword =
    String.fromEnvironment('PRICE_VISIBILITY_PASSWORD');

void _handlePriceVisibilityToggle(BuildContext context) {
  final passwordController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          _showPriceNotifier.value ? 'Hide Prices?' : 'Show Prices?',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showPriceNotifier.value
                  ? 'Prices hide karva mate password nakho.'
                  : 'Prices joava mate password nakho.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_priceVisibilityPassword.isNotEmpty &&
                  passwordController.text == _priceVisibilityPassword) {
                _showPriceNotifier.value = !_showPriceNotifier.value;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _showPriceNotifier.value
                          ? 'Prices are now visible.'
                          : 'Prices are now hidden.',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wrong password! Try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

class _PendingApprovalPage extends StatelessWidget {
  const _PendingApprovalPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval pending'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.hourglass_top, size: 72, color: Colors.amber),
              SizedBox(height: 24),
              Text(
                'Your registration request has been sent to the admin. You can log in after approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Please wait for admin approval or contact support if required.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUsersPage extends StatelessWidget {
  const _AdminUsersPage();

  Future<void> _updateUserRole(
    BuildContext context,
    String userId,
    String newRole,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role updated to $newRole.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update role.')));
      }
    }
  }

  Future<void> _deleteUser(
    BuildContext context,
    String userId,
    String userName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully.'),
            ),
          );
        }
      } on FirebaseException catch (e) {
        if (context.mounted) {
          String errorMsg = 'Delete failed.';
          if (e.code == 'permission-denied') {
            errorMsg = 'Permission denied. Check Firestore rules.';
          } else {
            errorMsg = 'Error: ${e.message}';
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final name = data['name']?.toString() ?? 'Unknown';
            final role = data['role']?.toString() ?? 'pending';
            final createdAt = data['createdAt'] as Timestamp?;
            final createdText = createdAt != null
                ? createdAt.toDate().toLocal().toString().split('.').first
                : 'Date unknown';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getRoleColor(
                          role,
                        ).withValues(alpha: 0.1),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: _getRoleColor(role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User name: $name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: _getRoleColor(role),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Joined: $createdText',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (role != 'admin')
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'admin'),
                          icon: const Icon(Icons.security, size: 18),
                          label: const Text(
                            'Make Admin',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      if (role == 'pending')
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'retailer'),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      if (role == 'retailer')
                        TextButton.icon(
                          onPressed: () =>
                              _updateUserRole(context, doc.id, 'pending'),
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text(
                            'Suspend',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      IconButton(
                        onPressed: () => _deleteUser(context, doc.id, name),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Delete User',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'retailer':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'all':
      return 'All';
    case 'new':
      return 'New';
    case 'confirmed':
      return 'Confirmed';
    case 'packed':
      return 'Packed';
    case 'delivered':
      return 'Delivered';
    default:
      return status;
  }
}

const List<_CatalogCategory> _catalogCategories = [
  _CatalogCategory(
    name: 'Toran',
    icon: Icons.vertical_align_top,
    color: Color(0xFF0F766E),
    products: [
      _CatalogProduct(
        id: 'toran_regular',
        name: 'Regular Toran',
        category: 'Toran',
        description: 'Door decoration toran for daily and festival sale.',
        unit: 'pcs',
        icon: Icons.vertical_align_top,
        color: Color(0xFF0F766E),
      ),
      _CatalogProduct(
        id: 'mandir_toran',
        name: 'Mandir Toran',
        category: 'Toran',
        description: 'Small toran for mandir and pooja setup.',
        unit: 'pcs',
        icon: Icons.temple_hindu_outlined,
        color: Color(0xFF0F766E),
      ),
      _CatalogProduct(
        id: 'toran_premium',
        name: 'Premium Toran',
        category: 'Toran',
        description: 'Decorative toran with richer festive work.',
        unit: 'pcs',
        icon: Icons.auto_awesome,
        color: Color(0xFF0F766E),
      ),
    ],
  ),
  _CatalogCategory(
    name: 'Jummar',
    icon: Icons.light_outlined,
    color: Color(0xFF7C3AED),
    products: [
      _CatalogProduct(
        id: 'jummar_regular',
        name: 'Regular Jummar',
        category: 'Jummar',
        description: 'Hanging decorative jummar for home and shop.',
        unit: 'pcs',
        icon: Icons.light_outlined,
        color: Color(0xFF7C3AED),
      ),
      _CatalogProduct(
        id: 'mandir_jummar',
        name: 'Mandir Jummar',
        category: 'Jummar',
        description: 'Compact mandir hanging jummar set.',
        unit: 'pcs',
        icon: Icons.temple_hindu_outlined,
        color: Color(0xFF7C3AED),
      ),
      _CatalogProduct(
        id: 'toran_jummar_set',
        name: 'Toran Jummar Set',
        category: 'Jummar',
        description: 'Matched toran and jummar wholesale set.',
        unit: 'set',
        icon: Icons.dashboard_customize_outlined,
        color: Color(0xFF7C3AED),
      ),
    ],
  ),
  _CatalogCategory(
    name: 'Mandir Set',
    icon: Icons.temple_hindu_outlined,
    color: Color(0xFFE76F51),
    products: [
      _CatalogProduct(
        id: 'mandir_set_regular',
        name: 'Mandir Set',
        category: 'Mandir Set',
        description: 'Ready mandir decoration set for pooja counter.',
        unit: 'set',
        icon: Icons.temple_hindu_outlined,
        color: Color(0xFFE76F51),
      ),
      _CatalogProduct(
        id: 'mandir_toran_jummar_set',
        name: 'Mandir Toran Jummar Set',
        category: 'Mandir Set',
        description: 'Complete mandir toran and jummar combo.',
        unit: 'set',
        icon: Icons.inventory_2_outlined,
        color: Color(0xFFE76F51),
      ),
      _CatalogProduct(
        id: 'mandir_decor_mix',
        name: 'Mandir Decor Mix',
        category: 'Mandir Set',
        description: 'Assorted mandir decoration wholesale pack.',
        unit: 'pack',
        icon: Icons.all_inbox_outlined,
        color: Color(0xFFE76F51),
      ),
    ],
  ),
  _CatalogCategory(
    name: 'Matki',
    icon: Icons.local_florist_outlined,
    color: Color(0xFFB45309),
    products: [
      _CatalogProduct(
        id: 'matki_regular',
        name: 'Matki',
        category: 'Matki',
        description: 'Decorative matki for festival and home decor.',
        unit: 'pcs',
        icon: Icons.local_florist_outlined,
        color: Color(0xFFB45309),
      ),
      _CatalogProduct(
        id: 'matki_set',
        name: 'Matki Set',
        category: 'Matki',
        description: 'Matched matki group for retail display.',
        unit: 'set',
        icon: Icons.data_object_outlined,
        color: Color(0xFFB45309),
      ),
      _CatalogProduct(
        id: 'decorated_matki',
        name: 'Decorated Matki',
        category: 'Matki',
        description: 'Matki with decorative work for premium sale.',
        unit: 'pcs',
        icon: Icons.auto_awesome,
        color: Color(0xFFB45309),
      ),
    ],
  ),
  _CatalogCategory(
    name: 'Khbha Chuddi',
    icon: Icons.circle_outlined,
    color: Color(0xFFDB2777),
    products: [
      _CatalogProduct(
        id: 'khbha_chuddi_regular',
        name: 'Khbha Chuddi',
        category: 'Khbha Chuddi',
        description: 'Wholesale khbha chuddi item for novelty retailers.',
        unit: 'dozen',
        icon: Icons.circle_outlined,
        color: Color(0xFFDB2777),
      ),
      _CatalogProduct(
        id: 'khbha_chuddi_mix',
        name: 'Khbha Chuddi Mix',
        category: 'Khbha Chuddi',
        description: 'Assorted mix for counter display and fast sale.',
        unit: 'pack',
        icon: Icons.blur_circular_outlined,
        color: Color(0xFFDB2777),
      ),
    ],
  ),
  _CatalogCategory(
    name: 'Other Novelty',
    icon: Icons.category_outlined,
    color: Color(0xFF2563EB),
    products: [
      _CatalogProduct(
        id: 'festival_mix',
        name: 'Festival Novelty Mix',
        category: 'Other Novelty',
        description: 'Assorted festival products for retailer order.',
        unit: 'pack',
        icon: Icons.celebration_outlined,
        color: Color(0xFF2563EB),
      ),
      _CatalogProduct(
        id: 'decor_mix',
        name: 'Decor Mix',
        category: 'Other Novelty',
        description: 'Popular decor item mix for wholesale buyers.',
        unit: 'pack',
        icon: Icons.category_outlined,
        color: Color(0xFF2563EB),
      ),
    ],
  ),
];
