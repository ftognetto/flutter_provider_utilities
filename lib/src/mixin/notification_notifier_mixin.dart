import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// mixin to be user on a [ChangeNotifier] class
/// It provides a method [notifyNotification] 
/// Useful used in combination with [NotificationListener] to display in-app notifications
mixin NotificationNotifierMixin<T> on ChangeNotifier {

  T? _notification;
  T? get notification => _notification;

  void notifyNotification(T notification) {
    _notification = notification;
    notifyListeners();
  }

  void clearNotification() {
    _notification = null;
  }
}