import 'package:flutter/material.dart';
import 'package:flutter_provider_utilities/src/mixin/mixin.dart';
import 'package:flutter_provider_utilities/src/mixin/notification_notifier_mixin.dart';
import 'package:provider/provider.dart';

/// A listener for [ChangeNotifier] that extends [NotificationNotifierMixin] mixin
/// Wrapping a widget with [NotificationListener] will display an [Overlay] called from the ChangeNotifier class with [notifyNotification]
/// Useful to display in-app notifications
///
/// As an example:
/// ```dart
/// ChangeNotifierProvider.value(
///   value: _model,
///   child: Scaffold(
///    appBar: AppBar(),
///    body: NotificationListener<Model>(
///       child: ListView()
///    )
///   )
/// );
/// ```
class NotificationListener<T extends NotificationNotifierMixin<Y>, Y>
    extends StatefulWidget {
  final Widget child;
  final Widget Function(Y message)? leadingBuilder;
  final Widget Function(Y message) titleBuilder;
  final Widget Function(Y message)? bodyBuilder;
  final Widget Function(Y message)? trailingBuilder;
  final void Function(Y message)? onTap;

  const NotificationListener(
      {Key? key,
      required this.child,
      this.leadingBuilder,
      required this.titleBuilder,
      this.bodyBuilder,
      this.trailingBuilder,
      this.onTap})
      : super(key: key);

  @override
  _NotificationListenerState createState() => _NotificationListenerState();
}

class _NotificationListenerState<T extends NotificationNotifierMixin<Y>, Y>
    extends State<NotificationListener>
    with SingleTickerProviderStateMixin<NotificationListener> {
  OverlayEntry? _notificationPopup;
  AnimationController? controller;
  final animationDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<T, Y?>(
        selector: (ctx, model) => model.notification,
        shouldRebuild: (before, after) {
          return before != after;
        },
        builder: (context, notification, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotification(context, notification);
          });
          return child!;
        },
        child: widget.child);
  }

  void _handleNotification(BuildContext context, Y? notification) {
    if (notification != null) {
      if (ModalRoute.of(context)!.isCurrent) {
        _show(notification);
        Provider.of<T>(context, listen: false).clearNotification();
      }
    }
  }

  Future<void> _show(Y message) async {
    await _close();
    _notificationPopup = OverlayEntry(
        builder: (context2) => _NotificationBody(
              controller: controller,
              notification: message,
              leadingBuilder: widget.leadingBuilder,
              titleBuilder: widget.titleBuilder,
              bodyBuilder: widget.bodyBuilder,
              trailingBuilder: widget.trailingBuilder,
              onTap: (dynamic message) => widget.onTap!(message),
              onClosed: () {
                _close();
              },
            ));
    Overlay.of(context)!.insert(_notificationPopup!);
  }

  Future<void> _close() async {
    if (_notificationPopup != null) {
      _notificationPopup!.remove();
      _notificationPopup = null;
    }
  }
}

class _NotificationBody<Y> extends StatefulWidget {
  final AnimationController? controller;
  final Y notification;
  final Widget Function(Y notification)? leadingBuilder;
  final Widget Function(Y notification) titleBuilder;
  final Widget Function(Y notification)? bodyBuilder;
  final Widget Function(Y notification)? trailingBuilder;
  final void Function(Y message)? onTap;
  final void Function()? onClosed;

  _NotificationBody(
      {required this.controller,
      required this.notification,
      this.leadingBuilder,
      required this.titleBuilder,
      this.bodyBuilder,
      this.trailingBuilder,
      this.onClosed,
      this.onTap,
      Key? key})
      : super(key: key);

  @override
  _NotificationBodyState createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<_NotificationBody> {
  late Animation<double> positionAnimation;

  @override
  void initState() {
    super.initState();
    positionAnimation = Tween<double>(begin: -48.0, end: 24.0).animate(
        CurvedAnimation(parent: widget.controller!, curve: Curves.linear));
    widget.controller!.forward();
    widget.controller!.addListener(_refresh);
    Future.delayed(Duration(seconds: 5), () {
      _close();
    });
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        top: positionAnimation.value,
        width: MediaQuery.of(context).size.width,
        child: Material(
            type: MaterialType.transparency,
            elevation: 10,
            child: InkWell(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!(widget.notification);
                  }
                  _close();
                },
                child: Dismissible(
                  key: Key(
                      'in_app_notification_dismissible_${widget.notification.id}'),
                  direction: DismissDirection.up,
                  onDismissed: (direction) {
                    widget.onClosed!();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.leadingBuilder != null)
                        widget.leadingBuilder!(widget.notification),
                      if (widget.leadingBuilder != null) SizedBox(width: 16),
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          widget.titleBuilder(widget.notification),
                          if (widget.bodyBuilder != null)
                            widget.bodyBuilder!(widget.notification)
                        ],
                      )),
                      if (widget.trailingBuilder != null)
                        widget.trailingBuilder!(widget.notification)
                    ],
                  ),
                ))));
  }

  void _close() {
    widget.controller!.reverse().then((value) {
      widget.onClosed!();
    });
  }

  @override
  void dispose() {
    widget.controller!.removeListener(_refresh);
    super.dispose();
  }
}
