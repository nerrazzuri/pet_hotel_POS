/// Stub implementation for non-web platforms
class WebStorageImplementation {
  /// Get data from localStorage (stub - returns empty list)
  List<Map<String, dynamic>> getData(String key) {
    return [];
  }

  /// Save data to localStorage (stub - no-op)
  void saveData(String key, List<Map<String, dynamic>> data) {
    // No-op on non-web platforms
  }

  /// Clear all data (stub - no-op)
  void clearAll() {
    // No-op on non-web platforms
  }
}
