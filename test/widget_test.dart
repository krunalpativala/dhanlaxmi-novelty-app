import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:d1/main.dart';

void main() {
  testWidgets('Login and sign up screen loads', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthPage()));

    expect(find.text('Dhanlaxmi Novelty'), findsOneWidget);
    expect(find.text('Retailer login'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('New retailer? Create account'));
    await tester.pump();

    expect(find.text('Create retailer account'), findsOneWidget);
    expect(find.text('Retailer name'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });
}
