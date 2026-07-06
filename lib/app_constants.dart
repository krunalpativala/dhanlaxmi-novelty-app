part of 'main.dart';

const List<String> _orderStatuses = [
  'new',
  'pending',
  'confirmed',
  'packed',
  'delivered',
];

const List<String> _adminStatusFilters = [
  'all',
  'new',
  'pending',
  'confirmed',
  'packed',
  'delivered',
];

String _statusLabel(String status) {
  switch (status) {
    case 'all':
      return 'All';
    case 'new':
      return 'New';
    case 'pending':
      return 'Pending';
    case 'confirmed':
      return 'Confirmed';
    case 'packed':
      return 'Packed';
    case 'delivered':
      return 'Delivered';
    default:
      return status;
  }
}
