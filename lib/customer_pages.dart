part of 'main.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final Map<String, _CartLine> _cart = {};
  final _deliveryAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _paymentMethod = 'cod';
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

  DocumentReference<Map<String, dynamic>>? get _cartDocument {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection('carts').doc(user.uid);
  }

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
    _deliveryAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          _deliveryAddressController.text =
              data?['deliveryAddress']?.toString() ?? '';
          _phoneController.text = data?['phone']?.toString() ?? '';
          _paymentMethod = data?['paymentMethod']?.toString() ?? 'cod';
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
        'customerUid': FirebaseAuth.instance.currentUser?.uid,
        'customerName': FirebaseAuth.instance.currentUser?.displayName ?? '',
        'deliveryAddress': _deliveryAddressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'paymentMethod': _paymentMethod,
        'totalProducts': _totalProducts,
        'totalQuantity': _totalQuantity,
        'items': _cart.values.map((line) => line.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      const maxCartDocBytes = 900 * 1024;
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
        quantity: existing == null ? 1 : existing.quantity + 1,
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
      if (existing.quantity <= 1) {
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
        SnackBar(
          content: Text(
            AppLocalizations.text(languageNotifier.value, 'mustLoginFirst'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _selectedTab = 4);
      return;
    }

    final deliveryAddress = _deliveryAddressController.text.trim();
    final phone = _phoneController.text.trim();
    if (deliveryAddress.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(
              languageNotifier.value,
              'customerPhoneRequired',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final orderItems = _cart.values
          .map(
            (line) => {
              'productId': line.product.id,
              'name': line.product.name,
              'category': line.product.category,
              'unit': line.product.unit,
              'price': line.product.price,
              'lineTotal': line.product.price * line.quantity,
              'imageUrl': line.product.imageUrl,
              'quantity': line.quantity,
            },
          )
          .toList();

      final orderData = {
        'customerUid': user.uid,
        'customerName': user.displayName ?? '',
        'deliveryAddress': deliveryAddress,
        'phone': phone,
        'paymentMethod': _paymentMethod,
        'status': 'pending',
        'totalProducts': _totalProducts,
        'totalQuantity': _totalQuantity,
        'totalAmount': _cartTotalAmount,
        'items': orderItems,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .add(orderData)
          .timeout(const Duration(seconds: 15));

      if (_cartDocument != null) {
        await _cartDocument!.delete().catchError((_) => null);
      }

      setState(() {
        _cart.clear();
        _deliveryAddressController.clear();
        _phoneController.clear();
        _paymentMethod = 'cod';
        _selectedTab = 2;
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

  void _handlePaymentChange(String? value) {
    if (value == null) {
      return;
    }
    setState(() {
      _paymentMethod = value;
    });
    _saveCartToFirestore();
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
                isCustomerMode: true,
              ),
              _CustomerCartPage(
                language: language,
                cartLines: _cart.values.toList(),
                deliveryAddressController: _deliveryAddressController,
                phoneController: _phoneController,
                paymentMethod: _paymentMethod,
                isSubmitting: _isSubmitting,
                onAdd: _addProduct,
                onRemove: _decreaseProduct,
                onDetailsChanged: _saveCartToFirestore,
                onPaymentChanged: _handlePaymentChange,
                onSubmit: _submitOrder,
              ),
              _OrdersPage(language: language, isCustomer: true),
              _NotificationsPage(notifications: _notifications),
              _CustomerAccountPage(language: language, onSignOut: _signOut),
            ];

            return Scaffold(
              appBar: AppBar(
                title: _BrandHeader(subtitle: 'Customer shopping'),
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

class _CustomerCartPage extends StatelessWidget {
  const _CustomerCartPage({
    required this.language,
    required this.cartLines,
    required this.deliveryAddressController,
    required this.phoneController,
    required this.paymentMethod,
    required this.isSubmitting,
    required this.onAdd,
    required this.onRemove,
    required this.onDetailsChanged,
    required this.onPaymentChanged,
    required this.onSubmit,
  });

  final AppLanguage language;
  final List<_CartLine> cartLines;
  final TextEditingController deliveryAddressController;
  final TextEditingController phoneController;
  final String paymentMethod;
  final bool isSubmitting;
  final ValueChanged<_CatalogProduct> onAdd;
  final ValueChanged<_CatalogProduct> onRemove;
  final VoidCallback onDetailsChanged;
  final ValueChanged<String?> onPaymentChanged;
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
            isCustomerMode: true,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        _CartSummaryPanel(cartLines: cartLines, isCustomerMode: true),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.text(language, 'customerDetails'),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: deliveryAddressController,
          onChanged: (_) => onDetailsChanged(),
          textInputAction: TextInputAction.next,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: AppLocalizations.text(language, 'deliveryAddressLabel'),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          onChanged: (_) => onDetailsChanged(),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: AppLocalizations.text(language, 'phoneLabel'),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.text(language, 'paymentMethodLabel'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.text(language, 'paymentMethodCOD')),
          value: 'cod',
          groupValue: paymentMethod,
          onChanged: onPaymentChanged,
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.text(language, 'paymentMethodOnline')),
          value: 'online',
          groupValue: paymentMethod,
          onChanged: onPaymentChanged,
        ),
        if (paymentMethod == 'online') ...[
          const SizedBox(height: 8),
          Text(
            AppLocalizations.text(language, 'paymentInfoOnline'),
            style: const TextStyle(color: Color(0xFF475569)),
          ),
        ],
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
          label: Text(AppLocalizations.text(language, 'placeOrder')),
        ),
      ],
    );
  }
}

class _CustomerAccountPage extends StatelessWidget {
  const _CustomerAccountPage({required this.language, required this.onSignOut});

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
              : AppLocalizations.text(language, 'customerAccount'),
          subtitle: AppLocalizations.text(language, 'customerAccount'),
          icon: Icons.person,
        ),
        const SizedBox(height: 14),
        _InfoPanel(
          title: AppLocalizations.text(language, 'customerOrdersInfoTitle'),
          lines: [
            AppLocalizations.text(language, 'customerOrdersInfoLine1'),
            AppLocalizations.text(language, 'customerOrdersInfoLine2'),
            AppLocalizations.text(language, 'customerOrdersInfoLine3'),
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
