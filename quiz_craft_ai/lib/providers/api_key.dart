import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider declaration
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String?>((ref) {
  return ApiKeyNotifier();
});

// Key for SharedPreferences
const _kApiKey = 'huggingface_api_key';

// Notifier class that handles the state and persistence
class ApiKeyNotifier extends StateNotifier<String?> {
  ApiKeyNotifier() : super(null) {
    _loadApiKey();
  }

  // Load API key from SharedPreferences
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kApiKey);
  }

  // Save API key to SharedPreferences
  Future<void> setApiKey(String? newKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (newKey == null || newKey.isEmpty) {
      await prefs.remove(_kApiKey);
      state = null;
    } else {
      await prefs.setString(_kApiKey, newKey);
      state = newKey;
    }
  }

  // Clear API key
  Future<void> clearApiKey() async {
    await setApiKey(null);
  }
}
