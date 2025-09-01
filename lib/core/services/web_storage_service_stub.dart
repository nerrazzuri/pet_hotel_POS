/// Stub implementation for non-web platforms
class WebStorageImplementation {
  static final Map<String, List<Map<String, dynamic>>> _storage = {};

  /// Get data from localStorage (in-memory storage for non-web platforms)
  List<Map<String, dynamic>> getData(String key) {
    return _storage[key] ?? [];
  }

  /// Save data to localStorage (in-memory storage for non-web platforms)
  void saveData(String key, List<Map<String, dynamic>> data) {
    _storage[key] = List.from(data);
  }

  /// Remove data for a specific key (in-memory storage for non-web platforms)
  void removeData(String key) {
    _storage.remove(key);
  }

  /// Clear all data (in-memory storage for non-web platforms)
  void clearAll() {
    _storage.clear();
  }
}
