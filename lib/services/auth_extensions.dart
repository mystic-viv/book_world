import 'package:supabase_flutter/supabase_flutter.dart';

extension SupabaseAuthExtensions on GoTrueClient {
  /// Signs in user via magic link.
  ///
  /// This is a custom extension method that provides compatibility
  /// for versions of the Supabase SDK that don't have signInWithLink directly.

  Future<void> signInWithLink({
    required String email,
    String? redirectTo,
    Map<String, dynamic>? data,
  }) async {
    // Use the available signInWithOtp method with email option

    return signInWithOtp(email: email, emailRedirectTo: redirectTo, data: data);
  }
}
