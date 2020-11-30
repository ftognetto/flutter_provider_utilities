import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin MessageNotifierMixin<T> on ChangeNotifier {

  String _error;
  String get error => _error;

  String _info;
  String get info => _info;

  T _message;
  T get message => _message;

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

  void notifyMessage(T message) {
    _message = message;
    notifyListeners();
  }

  void clearMessage() {
    _message = null;
  }
}