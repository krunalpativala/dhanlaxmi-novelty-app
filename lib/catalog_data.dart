part of 'main.dart';

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
