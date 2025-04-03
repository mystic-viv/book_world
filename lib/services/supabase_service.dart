import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  // Use a cached client to avoid repeated access attempts
  static SupabaseClient? _cachedClient;

  static SupabaseClient? get client {
    if (_cachedClient != null) return _cachedClient;

    try {
      _cachedClient = Supabase.instance.client;
      return _cachedClient;
    } catch (e) {
      debugPrint("Error accessing Supabase client: $e");
      return null;
    }
  }

  // Reset the cached client on hot reload
  static void resetClient() {
    _cachedClient = null;
  }

  @override
  void onInit() {
    super.onInit();

    // Reset cached client on initialization
    resetClient();
  }
}
