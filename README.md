# provider_utilities

A set of utilities for provider package.

## Mixins

# MessageNotifierMixin
mixin to be user on a [ChangeNotifier] class
It provides two fields [error] and [info] and two methods [notifyError] and [notifyInfo]
Useful used in combination with [MessageListener] to display error or information messages to users

# NotificationNotifierMixin
mixin to be user on a [ChangeNotifier] class
It provides a method [notifyNotification] 
Useful used in combination with [NotificationListener] to display in-app notifications

# SafeNotifierMixin
mixin to be user on a [ChangeNotifier] class
it provides a method [notifySafe] the can be called to [notifyListeners] in a safe manner
Useful when using [ChangeNotifier] in pages that can be dismisses or popped


## Listeners

# MessageListener
A listener for [ChangeNotifier] that extends [MessageNotifierMixin] mixin
Wrapping a widget with [MessageListener] will use [Scaffold.context] to show Snackbars called from the ChangeNotifier class with [notifyError] or [notifyInfo] methods
Useful to display error or information messages

As an example:
```dart
ChangeNotifierProvider.value(
  value: _model,
  child: Scaffold(
   appBar: AppBar(),
   body: MessageListener<Model>(
      child: ListView()
   )
  )
);
```

# NotificationListener
A listener for [ChangeNotifier] that extends [NotificationNotifierMixin] mixin
Wrapping a widget with [NotificationListener] will display an [Overlay] called from the ChangeNotifier class with [notifyNotification]
Useful to display in-app notifications

As an example:
```dart
ChangeNotifierProvider.value(
  value: _model,
  child: Scaffold(
   appBar: AppBar(),
   body: NotificationListener<Model>(
      child: ListView()
   )
  )
);
```
