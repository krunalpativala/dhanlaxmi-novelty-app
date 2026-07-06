part of 'main.dart';

final ValueNotifier<bool> _showPriceNotifier = ValueNotifier<bool>(true);
const String _priceVisibilityPassword = String.fromEnvironment(
  'PRICE_VISIBILITY_PASSWORD',
);

void _handlePriceVisibilityToggle(BuildContext context) {
  final passwordController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          _showPriceNotifier.value ? 'Hide Prices?' : 'Show Prices?',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showPriceNotifier.value
                  ? 'Prices hide karva mate password nakho.'
                  : 'Prices joava mate password nakho.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_priceVisibilityPassword.isNotEmpty &&
                  passwordController.text == _priceVisibilityPassword) {
                _showPriceNotifier.value = !_showPriceNotifier.value;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _showPriceNotifier.value
                          ? 'Prices are now visible.'
                          : 'Prices are now hidden.',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wrong password! Try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}
