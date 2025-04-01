import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SignupController extends GetxController {
  final storage = GetStorage();

  var fullName = ''.obs;
  var username = ''.obs;
  var mobileNumber = ''.obs;
  DateTime dateOfBirth = DateTime.parse("").obs as DateTime;
  var localAdress = ''.obs;
  var localPincode = ''.obs;
  var permanentAddress = ''.obs;
  var permanentPincode = ''.obs;
  var email = ''.obs;
  var password = ''.obs;

  //Save user data to local storage
  void saveUserData() {
    storage.write('fullName', fullName.value);
    storage.write('username', username.value);
    storage.write('mobileNumber', mobileNumber.value);
    storage.write('dateOfBirth', dateOfBirth.toString());
    storage.write('localAdress', localAdress.value);
    storage.write('localPincode', localPincode.value);
    storage.write('permanentAddress', permanentAddress.value);
    storage.write('permanentPincode', permanentPincode.value);
    storage.write('email', email.value);
    storage.write('password', password.value);
  }
}
