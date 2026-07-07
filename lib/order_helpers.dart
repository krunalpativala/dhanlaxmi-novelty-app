part of 'main.dart';

double _numberFrom(dynamic value) => value is num ? value.toDouble() : 0;

int _intFrom(dynamic value) => value is int
    ? value
    : value is num
    ? value.toInt()
    : int.tryParse(value?.toString() ?? '') ?? 0;

double _itemLineTotal(dynamic item) {
  if (item is! Map) {
    return 0;
  }

  final savedLineTotal = _numberFrom(item['lineTotal']);
  if (savedLineTotal > 0) {
    return savedLineTotal;
  }

  return _numberFrom(item['price']) * _intFrom(item['quantity']);
}

double _orderTotalAmount(Map<String, dynamic> data) {
  final savedTotal = _numberFrom(data['totalAmount']);
  if (savedTotal > 0) {
    return savedTotal;
  }

  final items = data['items'] as List<dynamic>? ?? [];
  return items.fold(0, (total, item) => total + _itemLineTotal(item));
}

Future<void> _shareOrderPdf(
  String orderId,
  Map<String, dynamic> data,
  bool showPrice,
) async {
  final document = pw.Document();
  final items = data['items'] as List<dynamic>? ?? [];
  final totalAmount = _orderTotalAmount(data);
  final bool showPriceInPdf = _showPriceNotifier.value && showPrice;

  document.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Dhanlaxmi Novelty',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Wholesale Order'),
            pw.Text('Order ID: $orderId'),
            pw.Text(
              'Shop/Name: ${data['shopName'] ?? data['customerName'] ?? '-'}',
            ),
            if (data['deliveryAddress'] != null)
              pw.Text('Address: ${data['deliveryAddress']}'),
            pw.Text('Phone: ${data['phone'] ?? '-'}'),
            pw.Text(
              'Status: ${_statusLabel(data['status']?.toString() ?? 'new')}',
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: [
                'Item',
                'Category',
                'Qty',
                'Unit',
                if (showPriceInPdf) 'Price',
                if (showPriceInPdf) 'Total',
              ],
              data: items.map((item) {
                return [
                  item['name']?.toString() ?? '',
                  item['category']?.toString() ?? '',
                  item['quantity']?.toString() ?? '',
                  item['unit']?.toString() ?? '',
                  if (showPriceInPdf)
                    'Rs. ${((item['price'] as num?) ?? 0).toStringAsFixed(0)}',
                  if (showPriceInPdf)
                    'Rs. ${_itemLineTotal(item).toStringAsFixed(0)}',
                ];
              }).toList(),
            ),
            if (showPriceInPdf) pw.SizedBox(height: 14),
            if (showPriceInPdf)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Grand Total: Rs. ${totalAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            if ((data['note']?.toString() ?? '').isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text('Note: ${data['note']}'),
            ],
          ],
        );
      },
    ),
  );

  await Printing.sharePdf(
    bytes: await document.save(),
    filename: 'dhanlaxmi-order-$orderId.pdf',
  );
}

Future<void> _sendOrderOnWhatsApp(
  Map<String, dynamic> data,
  bool showPrice,
) async {
  final phone =
      data['phone']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  final items = data['items'] as List<dynamic>? ?? [];
  final totalAmount = _orderTotalAmount(data);
  final bool showPriceInMsg = _showPriceNotifier.value && showPrice;

  final lines = [
    'Dhanlaxmi Novelty Order',
    'Shop: ${data['shopName'] ?? '-'}',
    'Status: ${_statusLabel(data['status']?.toString() ?? 'new')}',
    '',
    for (final item in items)
      '${item['name']} x ${item['quantity']} ${item['unit'] ?? ''}${showPriceInMsg ? ' = Rs. ${_itemLineTotal(item).toStringAsFixed(0)}' : ''}',
    if (showPriceInMsg) '',
    if (showPriceInMsg) 'Total: Rs. ${totalAmount.toStringAsFixed(0)}',
  ];
  final message = Uri.encodeComponent(lines.join('\n'));
  final uri = Uri.parse(
    phone.isEmpty
        ? 'https://wa.me/?text=$message'
        : 'https://wa.me/91$phone?text=$message',
  );

  const channel = MethodChannel('d1/whatsapp');
  await channel.invokeMethod<void>('openWhatsApp', {'url': uri.toString()});
}
