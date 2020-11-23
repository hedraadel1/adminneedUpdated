import 'package:adminneed/src/pages/map_screen.dart';

import 'src/pages/login.dart';
import 'src/pages/signup.dart';
import 'src/pages/usersList.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/SignIn':
        return MaterialPageRoute(builder: (_) => Login());
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/UserList':
        return MaterialPageRoute(builder: (_) => usersList());
      case '/MapScreen':
        return MaterialPageRoute(builder: (_) => MapScreen());
    }
  }
}
