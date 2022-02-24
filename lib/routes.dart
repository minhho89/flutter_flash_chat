import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_chat/screens/chat_screen.dart';
import 'package:flutter_flash_chat/screens/login_screen.dart';
import 'package:flutter_flash_chat/screens/registration_screen.dart';
import 'package:flutter_flash_chat/screens/welcome_screen.dart';

Map<String, WidgetBuilder> routes = {
  ChatScreen.routeName: (context) => ChatScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegistrationScreen.routeName: (context) => RegistrationScreen(),
  WelcomeScreen.routeName: (context) => WelcomeScreen(),
};
