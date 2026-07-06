part of 'main.dart';

class _WholesaleBanner extends StatelessWidget {
  const _WholesaleBanner({
    required this.onOpenCart,
    this.isCustomerMode = false,
  });

  final VoidCallback onOpenCart;
  final bool isCustomerMode;

  @override
  Widget build(BuildContext context) {
    final language = languageNotifier.value;
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
            child: Text(
              isCustomerMode
                  ? AppLocalizations.text(language, 'customerShopBadge')
                  : 'Wholesale order book',
              style: const TextStyle(
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
          Text(
            isCustomerMode
                ? AppLocalizations.text(language, 'customerShopSubtitle')
                : 'Retailer selects products, adds quantities, and places orders directly to wholesaler via Firestore.',
            style: const TextStyle(color: Color(0xFFD1FAE5), height: 1.35),
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

class _ProductLargeCard extends StatelessWidget {
  const _ProductLargeCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.isCustomerMode = false,
  });

  final _CatalogProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isCustomerMode;

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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ProductDetailPage(
                        product: product,
                        quantity: quantity,
                        onAdd: onAdd,
                        onRemove: onRemove,
                        isCustomerMode: isCustomerMode,
                      ),
                    ),
                  );
                },
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
                    // Hide price for retailers (isCustomerMode is false for them)
                    if (!show || !isCustomerMode) return const SizedBox.shrink();
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
              if (!isCustomerMode && product.minimumOrderQuantity > 1)
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
                        if (!show || !isCustomerMode) {
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
    this.isCustomerMode = false,
  });

  final _CatalogProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isCustomerMode;

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
        _localQuantity = widget.isCustomerMode
            ? 1
            : widget.product.minimumOrderQuantity;
      } else {
        _localQuantity++;
      }
    });
    widget.onAdd();
  }

  void _decrement() {
    if (_localQuantity == 0) return;
    final minQty = widget.isCustomerMode
        ? 1
        : widget.product.minimumOrderQuantity;
    setState(() {
      if (_localQuantity <= minQty) {
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
                          if (!show || !widget.isCustomerMode) {
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
                      if (!widget.isCustomerMode)
                        _infoCard(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Min Order',
                          value:
                              '${product.minimumOrderQuantity} ${product.unit}',
                        ),
                      if (!widget.isCustomerMode) const SizedBox(width: 12),
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
                        if (!show || !widget.isCustomerMode) return const SizedBox.shrink();
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
    this.isCustomerMode = false,
  });

  final _CartLine line;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isCustomerMode;

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
                ValueListenableBuilder<bool>(
                  valueListenable: _showPriceNotifier,
                  builder: (context, show, child) {
                    if (!show || !isCustomerMode) {
                      return const Text(
                        'Price Hidden',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                        ),
                      );
                    }
                    return Text(
                      'Rs. ${line.product.price.toStringAsFixed(0)} x ${line.quantity} = Rs. ${lineTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F766E),
                      ),
                    );
                  },
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
  const _CartSummaryPanel({
    required this.cartLines,
    this.isCustomerMode = false,
  });

  final List<_CartLine> cartLines;
  final bool isCustomerMode;

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
            _CartSummaryRow(line: line, isCustomerMode: isCustomerMode),
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
              ValueListenableBuilder<bool>(
                valueListenable: _showPriceNotifier,
                builder: (context, show, child) {
                  if (!show || !isCustomerMode) {
                    return const Text(
                      'Price Hidden',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF64748B),
                      ),
                    );
                  }
                  return Text(
                    'Rs. ${totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F766E),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  const _CartSummaryRow({required this.line, this.isCustomerMode = false});

  final _CartLine line;
  final bool isCustomerMode;

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
              ValueListenableBuilder<bool>(
                valueListenable: _showPriceNotifier,
                builder: (context, show, child) {
                  if (!show || !isCustomerMode) {
                    return Text(
                      'Quantity: ${line.quantity} ${line.product.unit}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    );
                  }
                  return Text(
                    '${line.quantity} ${line.product.unit} x Rs. ${line.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _showPriceNotifier,
          builder: (context, show, child) {
            if (!show || !isCustomerMode) {
              return const SizedBox.shrink();
            }
            return Text(
              'Rs. ${lineTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            );
          },
        ),
      ],
    );
  }
}
