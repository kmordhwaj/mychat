import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserData extends ChangeNotifier {
  String? currentUserId;
  User? currentUser;
  bool cameFromRegisterScreen = false;
}
