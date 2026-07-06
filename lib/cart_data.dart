part of 'main.dart';

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
