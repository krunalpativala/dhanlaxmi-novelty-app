part of 'main.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order status set to $status.')));
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
                  message:
                      'New retailer or customer orders will appear here after submission.',
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
