import 'dart:convert';
import 'dart:html' as html;

/// Web-specific implementation of storage operations
class WebStorageImplementation {
  static const String _prefix = 'cat_hotel_pos_';
  static const String _usersKey = '${_prefix}users';
  static const String _customersKey = '${_prefix}customers';
  static const String _petsKey = '${_prefix}pets';
  static const String _roomsKey = '${_prefix}rooms';
  static const String _bookingsKey = '${_prefix}bookings';
  static const String _auditLogsKey = '${_prefix}audit_logs';
  static const String _posCartsKey = '${_prefix}pos_carts';
  static const String _posTransactionsKey = '${_prefix}pos_transactions';
  static const String _inventoryKey = '${_prefix}inventory';

  /// Get data from localStorage
  List<Map<String, dynamic>> getData(String key) {
    try {
      print('WebStorageImplementation.getData() called with key: $key');
      final data = html.window.localStorage[key];
      print('Raw localStorage data for key $key: $data');
      if (data == null) {
        print('No data found for key: $key');
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(data);
      final result = jsonList.cast<Map<String, dynamic>>();
      print('Parsed ${result.length} items for key: $key');
      return result;
    } catch (e) {
      print('Error reading from web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Save data to localStorage
  void saveData(String key, List<Map<String, dynamic>> data) {
    try {
      print('WebStorageImplementation.saveData() called with key: $key, data count: ${data.length}');
      final jsonString = jsonEncode(data);
      print('JSON string to save: $jsonString');
      html.window.localStorage[key] = jsonString;
      print('Data saved successfully for key: $key');
    } catch (e) {
      print('Error saving to web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  }

  /// Clear all data
  void clearAll() {
    try {
      print('WebStorageImplementation.clearAll() called');
      html.window.localStorage.remove(_usersKey);
      html.window.localStorage.remove(_customersKey);
      html.window.localStorage.remove(_petsKey);
      html.window.localStorage.remove(_roomsKey);
      html.window.localStorage.remove(_bookingsKey);
      html.window.localStorage.remove(_auditLogsKey);
      html.window.localStorage.remove(_posCartsKey);
      html.window.localStorage.remove(_posTransactionsKey);
      html.window.localStorage.remove(_inventoryKey);
      print('Web storage cleared');
    } catch (e) {
      print('Error clearing web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  }
}
