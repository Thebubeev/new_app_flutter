
import 'package:flutter/material.dart';
import 'package:new_app/services/auth_service.dart';

class Provider extends InheritedWidget {
  final AuthService auth;
  Provider({Key key, Widget child, this.auth}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) =>
      // ignore: deprecated_member_use
      (context.inheritFromWidgetOfExactType(Provider)
          as Provider);
}
