import 'package:flutter/foundation.dart';

mixin SafeNotifierMixin on ChangeNotifier {

  bool _mounted = true;

  notifySafe(){
    if(_mounted) notifyListeners();
  }

  @override
  void dispose(){
    _mounted = false;
    super.dispose();
  }
}