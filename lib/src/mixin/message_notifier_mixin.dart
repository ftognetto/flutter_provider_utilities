import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// mixin to be user on a [ChangeNotifier] class
/// It provides two fields [error] and [info] and two methods [notifyError] and [notifyInfo]
/// Useful used in combination with [MessageListener] to display error or information messages to users
mixin MessageNotifierMixin on ChangeNotifier {

  String? _error;
  String? get error => _error;

  String? _info;
  String? get info => _info;

  void notifyError(dynamic error) {
    _error = error.toString();
    notifyListeners();
  }

  void clearError() {
    _error = null;
  }

  void notifyInfo(String info) {
    _info = info;
    notifyListeners();
  }

  void clearInfo() {
    _info = null;
  }

}