import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final String supabaseKey = dotenv.env['SUPABASE_KEY']!;

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception("Missing Supabase environment variables");
    }
  }
}
