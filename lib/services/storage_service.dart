import 'package:get_storage/get_storage.dart';

class StorageServices {
  static final session = GetStorage();

  static dynamic get userSession => session.read('userSession');

  static void setUserSession(dynamic sessionData) {
    if (sessionData == null) {
      session.erase(); // Remove session if null
    } else {
      session.write('userSession', sessionData); // Write session data
    }
  }

  // Modify this method to specifically clear user session
  static void clearUserSession() {
    session.remove('userSession'); // Remove only the userSession data
  }

  static void clearAll() {
    session.erase();
  }
}
