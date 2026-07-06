part of 'main.dart';

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
          label: Text(
            isSubmitting
                ? AppLocalizations.text(language, 'submittingOrder')
                : AppLocalizations.text(language, 'submitOrder'),
          ),
        ),
      ],
    );
  }
}

class _OrdersPage extends StatelessWidget {
  const _OrdersPage({required this.language, this.isCustomer = false});

  final AppLanguage language;
  final bool isCustomer;

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
          .where(
            Filter.or(
              Filter('retailerUid', isEqualTo: user.uid),
              Filter('customerUid', isEqualTo: user.uid),
            ),
          )
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
            message: AppLocalizations.text(
              language,
              isCustomer ? 'firstCustomerOrderPrompt' : 'firstOrderPrompt',
            ),
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
