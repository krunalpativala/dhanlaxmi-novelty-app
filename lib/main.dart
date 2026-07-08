import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

part 'app_constants.dart';
part 'cart_data.dart';
part 'catalog_data.dart';
part 'image_upload.dart';
part 'language.dart';
part 'notification_service.dart';
part 'order_helpers.dart';
part 'price_visibility.dart';
part 'shared_widgets.dart';
part 'order_widgets.dart';
part 'product_widgets.dart';
part 'admin_pages.dart';
part 'user_tabs.dart';
part 'catalog_pages.dart';
part 'customer_pages.dart';
part 'shop_pages.dart';
part 'admin_users_page.dart';
part 'auth_pages.dart';
part 'app_shell.dart';

extension AppLanguageDisplay on AppLanguage {
  String get displayName => this == AppLanguage.english ? 'English' : 'ગુજરાતી';
}

final ValueNotifier<AppLanguage> languageNotifier = ValueNotifier<AppLanguage>(
  AppLanguage.english,
);

class AppLocalizations {
  static const Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.english: {
      'orderSuccess': 'Order submitted successfully!',
      'mustLoginFirst': 'Please log in before submitting an order.',
      'shopNamePhoneRequired': 'Shop name and mobile number are required.',
      'firebaseOrderPermission':
          'Grant the retailer permission to create orders in Firestore rules.',
      'orderSubmitFailed': 'Order submission failed. Please try again.',
      'error': 'Error: ',
      'selectLanguage': 'Select language',
      'languagePrompt': 'Please choose a language',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'logout': 'Logout',
      'notifications': 'Notifications',
      'cart': 'Cart',
      'showPrices': 'Show Prices',
      'hidePrices': 'Hide Prices',
      'catalog': 'Catalog',
      'orders': 'Orders',
      'account': 'Account',
      'wholesaleOrderApp': 'Wholesale order app',
      'retailerAccount': 'Retailer account',
      'wholesalerOrdersInfoTitle': 'How wholesaler will see orders',
      'wholesalerOrdersInfoLine1':
          'Every submitted order saves in Firestore collection: orders',
      'wholesalerOrdersInfoLine2':
          'Each order has shopName, phone, note, status, quantity and items.',
      'wholesalerOrdersInfoLine3':
          'Wholesaler can open Firebase Console and review new orders.',
      'save': 'Save',
      'noCategories': 'No categories',
      'addCategoryHint':
          'Add a category so the catalog can update dynamically from products.',
      'registrationSent':
          'Registration request sent. You can log in after admin approval.',
      'emailAlreadyInUse': 'An account already exists with this email.',
      'emailRequired': 'Email is required.',
      'invalidEmail': 'Please enter a valid email address.',
      'emailPasswordIncorrect': 'Email or password is incorrect.',
      'weakPassword': 'Password must be at least 6 characters.',
      'enableEmailPasswordSignIn':
          'Enable Email/Password sign-in in Firebase Authentication.',
      'networkError': 'Check your internet connection and try again.',
      'createAccountInfo':
          'Create an account. Admin will approve you as retailer or customer.',
      'loginInfo': 'Log in to place wholesale orders.',
      'customerAccount': 'Customer account',
      'customerDetails': 'Delivery details',
      'deliveryAddressLabel': 'Delivery address',
      'paymentMethodLabel': 'Payment method',
      'paymentMethodCOD': 'Cash on delivery',
      'paymentMethodOnline': 'Online payment',
      'paymentInfoOnline':
          'Online payment is currently saved as payment pending for now.',
      'placeOrder': 'Place order',
      'customerPhoneRequired':
          'Delivery address and phone number are required.',
      'customerShopBadge': 'Online shopping',
      'customerShopSubtitle':
          'Browse products, add to cart, and place orders with delivery and payment.',
      'customerOrdersInfoTitle': 'Your orders',
      'customerOrdersInfoLine1': 'Every order is saved in your Orders tab.',
      'customerOrdersInfoLine2':
          'Track status: pending, confirmed, packed, delivered.',
      'customerOrdersInfoLine3':
          'Pay cash on delivery or choose online payment.',
      'firstCustomerOrderPrompt':
          'Browse the catalog and place your first order.',
      'passwordMismatch': 'Passwords do not match.',
      'cartEmptyTitle': 'Cart is empty',
      'cartEmptyMessage': 'Add items to the cart from the catalog.',
    'cartDisabled': 'Cart is disabled for this mode.',
      'cartItems': 'Cart items',
      'retailerDetails': 'Retailer details',
      'shopNameLabel': 'Shop name',
      'phoneLabel': 'Phone / WhatsApp number',
      'orderNoteLabel': 'Order note',
      'submitOrder': 'Submit order',
      'submittingOrder': 'Submitting order...',
      'loginRequired': 'Login required',
      'loginToViewOrders': 'Log in to view your orders.',
      'ordersLoadFailed': 'Orders failed to load',
      'ordersLoadHelp':
          'Check Firestore rules/index. Orders appear in Firestore after submission.',
      'firstOrderPrompt': 'Place your first wholesale order from the cart.',
      'orderStatusUpdated': 'Order status set to {status}.',
      'statusUpdateFailed': 'Status update failed. Please try again.',
      'categoryReadPermission': 'Check category read permission.',
      'categoriesLoadFailed':
          'Categories failed to load. Please enter them manually.',
      'base64ImageError':
          'Cannot save Base64 image. Upload using the Select button.',
      'addProductHelp':
          'Add a product so the catalog updates automatically from Firestore.',
      'noOrdersYet': 'No orders yet',
      'passwordLengthError': 'Password must be at least 6 characters.',
      'createAccount': 'Create account',
      'login': 'Login',
      'signUpInfo': 'Create your account and wait for admin approval.',
      'loginContinue': 'Login to continue.',
      'fullName': 'Full name',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm password',
      'alreadyHaveAccount': 'Already have an account? Login',
      'newUserCreateAccount': 'New user? Create account',
    },
    AppLanguage.gujarati: {
      'orderSuccess': 'ઓર્ડર સફળતાપૂર્વક મોકલી દીધો છે!',
      'mustLoginFirst': 'તમારે પહેલા લોગ-ઈન કરવું પડશે.',
      'shopNamePhoneRequired': 'દુકાનનું નામ અને મોબાઈલ નંબર લખવો જરૂરી છે.',
      'firebaseOrderPermission':
          'Firestore rules માં retailer ને orders create permission આપો.',
      'orderSubmitFailed': 'Order submit નથિ થાયો. ફરી try કરો.',
      'error': 'ભૂલ: ',
      'selectLanguage': 'ભાષા પસંદ કરો',
      'languagePrompt': 'કૃપા કરીને ભાષા પસંદ કરો',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'logout': 'Logout',
      'notifications': 'અહેવાલો',
      'cart': 'કાર્ટ',
      'showPrices': 'કિંમત બતાવો',
      'hidePrices': 'કિંમત છુપાવો',
      'catalog': 'Catalog',
      'orders': 'Orders',
      'account': 'Account',
      'wholesaleOrderApp': 'Wholesale order app',
      'retailerAccount': 'Retailer account',
      'wholesalerOrdersInfoTitle': 'How wholesaler will see orders',
      'wholesalerOrdersInfoLine1':
          'Every submitted order saves in Firestore collection: orders',
      'wholesalerOrdersInfoLine2':
          'Each order has shopName, phone, note, status, quantity and items.',
      'wholesalerOrdersInfoLine3':
          'Wholesaler can open Firebase Console and review new orders.',
      'save': 'Save',
      'noCategories': 'No categories',
      'addCategoryHint':
          'Add a category so the catalog can update dynamically from products.',
      'registrationSent':
          'Registration request sent. You can log in after admin approval.',
      'emailAlreadyInUse': 'An account already exists with this email.',
      'emailRequired': 'Email is required.',
      'invalidEmail': 'Please enter a valid email address.',
      'emailPasswordIncorrect': 'Email or password is incorrect.',
      'weakPassword': 'Password must be at least 6 characters.',
      'enableEmailPasswordSignIn':
          'Enable Email/Password sign-in in Firebase Authentication.',
      'networkError': 'Check your internet connection and try again.',
      'createAccountInfo':
          'આખું વ્હોલસેલ ઓર્ડર માટે એકાઉન્ટ બનાવો. એડમિન તમને રિટેલર અથવા કસ્ટમર તરીકે મંજૂર કરશે.',
      'loginInfo': 'વ્હોલસેલ ઓર્ડર મૂકવા માટે લોગિન કરો.',
      'customerAccount': 'Customer account',
      'customerDetails': 'ડિલિવરી વિગતો',
      'deliveryAddressLabel': 'ડિલિવરી સરનામું',
      'paymentMethodLabel': 'ચુકવણી રીત',
      'paymentMethodCOD': 'નગદ પર ડિલિવરી',
      'paymentMethodOnline': 'ઓનલાઇન ચુકવણી',
      'paymentInfoOnline':
          'ઓનલાઇન ચુકવણી હાલમાં પેમેન્ટ પેન્ડિંગ તરીકે સાચવવામાં આવે છે.',
      'placeOrder': 'ઓર્ડર મૂકવો',
      'customerPhoneRequired': 'ડિલિવરી સરનામું અને ફોન નંબર લખવો જરૂરી છે.',
      'customerShopBadge': 'ઓનલાઇન શોપિંગ',
      'customerShopSubtitle':
          'ઉત્પાદનો જુઓ, કાર્ટમાં ઉમેરો અને ડિલિવરી અને ચુકવણી સાથે ઓર્ડર મૂકો.',
      'customerOrdersInfoTitle': 'તમારા ઓર્ડર',
      'customerOrdersInfoLine1': 'દરેક ઓર્ડર તમારા Orders ટેબમાં સાચવાય છે.',
      'customerOrdersInfoLine2':
          'સ્થિતિ ટ્રેક કરો: pending, confirmed, packed, delivered.',
      'customerOrdersInfoLine3': 'નગદ પર ડિલિવરી અથવા ઓનલાઇન ચુકવણી પસંદ કરો.',
      'firstCustomerOrderPrompt': 'કેટલોગમાંથી તમારો પહેલો ઓર્ડર મૂકો.',
      'passwordMismatch': 'Passwords do not match.',
      'cartEmptyTitle': 'Cart is empty',
      'cartEmptyMessage': 'Add items to the cart from the catalog.',
    'cartDisabled': 'આ મોડ માટે કાર્ટ બંધ છે.',
      'cartItems': 'Cart items',
      'retailerDetails': 'Retailer details',
      'shopNameLabel': 'Shop name',
      'phoneLabel': 'Phone / WhatsApp number',
      'orderNoteLabel': 'Order note',
      'submitOrder': 'Submit order',
      'submittingOrder': 'Submitting order...',
      'loginRequired': 'Login required',
      'loginToViewOrders': 'Log in to view your orders.',
      'ordersLoadFailed': 'Orders failed to load',
      'ordersLoadHelp':
          'Check Firestore rules/index. Orders appear in Firestore after submission.',
      'firstOrderPrompt': 'Place your first wholesale order from the cart.',
      'orderStatusUpdated': 'Order status set to {status}.',
      'statusUpdateFailed': 'Status update failed. Please try again.',
      'categoryReadPermission': 'Check category read permission.',
      'categoriesLoadFailed':
          'Categories failed to load. Please enter them manually.',
      'base64ImageError':
          'Cannot save Base64 image. Upload using the Select button.',
      'addProductHelp':
          'Add a product so the catalog updates automatically from Firestore.',
      'noOrdersYet': 'હજુ સુધી કોઈ ઓર્ડર નથી',
      'passwordLengthError': 'પાસવર્ડ ઓછામાં ઓછો 6 અક્ષરનો હોવો જોઈએ.',
      'createAccount': 'એકાઉન્ટ બનાવો',
      'login': 'લોગિન',
      'signUpInfo': 'તમારું એકાઉન્ટ બનાવો અને એડમિન મંજૂરીની રાહ જુઓ.',
      'loginContinue': 'ચાલુ રાખવા માટે લોગિન કરો.',
      'fullName': 'પૂરું નામ',
      'email': 'ઈમેઈલ',
      'password': 'પાસવર્ડ',
      'confirmPassword': 'પાસવર્ડની પુષ્ટિ કરો',
      'alreadyHaveAccount': 'પહેલેથી જ એકાઉન્ટ છે? લોગિન કરો',
      'newUserCreateAccount': 'નવા વપરાશકર્તા? એકાઉન્ટ બનાવો',
    },
  };

  static String text(AppLanguage language, String key) =>
      _translations[language]?[key] ?? key;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notifications
  await _NotificationService.initialize();

  languageNotifier.value = await _LanguageSettings.loadLanguage();

  runApp(const DhanlaxmiNoveltyApp());
}

String _firestoreError(FirebaseException error) {
  if (error.code == 'permission-denied') {
    return AppLocalizations.text(
      languageNotifier.value,
      'firebaseOrderPermission',
    );
  }
  return error.message ??
      AppLocalizations.text(languageNotifier.value, 'orderSubmitFailed');
}
