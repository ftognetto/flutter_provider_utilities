import 'package:flutter/foundation.dart';

/// mixin to be user on a [ChangeNotifier] class
/// it provides a method [notifySafe] the can be called to [notifyListeners] in a safe manner
/// Useful when using [ChangeNotifier] in pages that can be dismisses or popped
mixin SafeNotifierMixin on ChangeNotifier {

  bool _mounted = true;

  notifySafe(){
    if(_mounted) { Future.delayed(Duration(seconds: 0), () => notifyListeners()); }
  }

  @override
  void dispose(){
    _mounted = false;
    super.dispose();
  }
}