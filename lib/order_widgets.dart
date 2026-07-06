part of 'main.dart';

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
                  data['shopName']?.toString().isNotEmpty == true
                      ? data['shopName'].toString()
                      : data['customerName']?.toString() ?? 'Order',
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
              'User name: ${data['retailerName'] ?? data['customerName'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            if (data['deliveryAddress'] != null) ...[
              Text(
                'Address: ${data['deliveryAddress']}',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 3),
            ],
            Text(
              'Phone: ${data['phone'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            if (data['paymentMethod'] != null) ...[
              const SizedBox(height: 3),
              Text(
                'Payment: ${data['paymentMethod'] == 'cod' ? 'Cash on delivery' : 'Online'}',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
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
              if (data['customerName'] != null)
                Text('Customer: ${data['customerName']}'),
              if (data['deliveryAddress'] != null)
                Text('Address: ${data['deliveryAddress']}'),
              if (data['paymentMethod'] != null)
                Text('Payment: ${data['paymentMethod']}'),
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
