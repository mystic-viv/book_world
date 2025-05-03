import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:book_world/screens/auth/reset_password_confirm.dart'; // Change path as per your project

final AppLinks appLinks = AppLinks();

void initDeepLinkHandler() {
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      print('Received deep link: $uri');

      if (uri.path == '/reset_password-callback') {
        final accessToken = uri.queryParameters['access_token'];

        if (accessToken != null) {
          print('Access token from link: $accessToken');

          // Navigate to ResetPasswordConfirm screen, passing access token
          Get.to(() => ResetPasswordConfirm(accessToken: accessToken));
        }
      }
    }
  });
}
