import 'package:yunusco_accessories/models/user_model.dart';

class UserData{
  static UserModel _user=UserModel();

  static UserModel get user => _user;

  static set user(UserModel value) {
    _user = value;
  }
}