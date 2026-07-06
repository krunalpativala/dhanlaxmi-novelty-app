part of 'main.dart';

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
            content: Text(
              '${AppLocalizations.text(languageNotifier.value, 'error')}$e',
            ),
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
              _AccountPage(language: language, onSignOut: _signOut),
            ];

            return Scaffold(
              appBar: AppBar(
                title: _BrandHeader(
                  subtitle: AppLocalizations.text(
                    language,
                    'wholesaleOrderApp',
                  ),
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
                            tooltip: AppLocalizations.text(
                              language,
                              'notifications',
                            ),
                            onPressed: () {
                              setState(() => _selectedTab = 3);
                            },
                            icon: const Icon(Icons.notifications_outlined),
                          )
                        : Badge.count(
                            count: _notifications.length,
                            child: IconButton.filledTonal(
                              tooltip: AppLocalizations.text(
                                language,
                                'notifications',
                              ),
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
