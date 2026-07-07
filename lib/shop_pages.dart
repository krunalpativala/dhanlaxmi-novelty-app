part of 'main.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _CartDisabledPage extends StatelessWidget {
  const _CartDisabledPage({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.text(language, 'cartDisabled') ??
                  'Cart is disabled for this app mode.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
class _ShopHomePageState extends State<ShopHomePage> {
  // Cart is intentionally disabled on retailer side (UI-only removal).
  // Keep the structure present so shared widgets compile, but treat it as empty.
  final Map<String, _CartLine> _cart = {};
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final List<Map<String, dynamic>> _notifications = [];
  int _selectedTab = 0;
  bool _isSubmitting = false;
  bool _isCartLoading = true;

  // Retailer side: expose zero totals so cart UI stays hidden.
  int get _totalQuantity => 0;

  int get _totalProducts => 0;

  double get _cartTotalAmount => 0.0;

  @override
  void initState() {
    super.initState();
    // Do not load cart for retailer side.
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

    // Cart persistence disabled for retailer side.
    return null;
  }

  Future<void> _loadCartFromFirestore() async {
    // No-op for retailer side.
    if (mounted) setState(() => _isCartLoading = false);
  }

  Future<void> _saveCartToFirestore() async {
    // Cart persistence disabled for retailer side.
  }

  void _addProduct(_CatalogProduct product) {
    // Cart disabled for retailer side: do nothing.
  }

  void _decreaseProduct(_CatalogProduct product) {
    // Cart disabled for retailer side: do nothing.
  }

  Future<void> _submitOrder() async {
    // Cart/order submission disabled for retailer side.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.text(languageNotifier.value, 'cartDisabled'),
          ),
        ),
      );
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
              // Cart UI is disabled on retailer side; show informational page instead.
              _CartDisabledPage(language: language),
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
