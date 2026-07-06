part of 'main.dart';

class _CatalogPage extends StatelessWidget {
  const _CatalogPage({
    required this.categories,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenCart,
    this.isCustomerMode = false,
  });

  final List<_CatalogCategory> categories;
  final Map<String, _CartLine> cart;
  final ValueChanged<_CatalogProduct> onAdd;
  final ValueChanged<_CatalogProduct> onRemove;
  final VoidCallback onOpenCart;
  final bool isCustomerMode;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _WholesaleBanner(
              onOpenCart: onOpenCart,
              isCustomerMode: isCustomerMode,
            ),
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
                        isCustomerMode: isCustomerMode,
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
    this.isCustomerMode = false,
  });

  final _CatalogCategory category;
  final Map<String, _CartLine> cart;
  final ValueChanged<_CatalogProduct> onAdd;
  final ValueChanged<_CatalogProduct> onRemove;
  final VoidCallback onOpenCart;
  final bool isCustomerMode;

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
                        isCustomerMode: widget.isCustomerMode,
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
