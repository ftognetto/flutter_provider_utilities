import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_provider_utilities/src/listeners/message_listener.dart';
import 'package:flutter_provider_utilities/src/mixin/message_notifier_mixin.dart';

/// A listener for [ChangeNotifier] that extends [MessageNotifierMixin] mixin
/// Wrapping a widget with [MessageListener] will use [Scaffold.context] to show Snackbars called from the ChangeNotifier class with [notifyError] or [notifyInfo] methods
/// Useful to display error or information messages
///
/// As an example:
/// ```dart
/// ChangeNotifierProvider.value(
///   value: _model,
///   child: Scaffold(
///    appBar: AppBar(),
///    body: MessageListener<Model>(
///       child: ListView()
///    )
///   )
/// );
/// ```
class MessageOverlayListener<T extends MessageNotifierMixin>
    extends StatefulWidget {
  final Widget child;

  /// Additional function that can be called when an error message occur
  final void Function(String error)? onError;

  /// if [onErrorTap] is not null an action will be added to the [Overlay] when an error message occur
  final void Function(String error)? onErrorTap;

  /// Customize error [Overlay] leading icon
  /// default to Icons.error
  final Widget errorLeading;

  /// Customize error [Overlay] trailing widget
  /// Default is empty
  final Widget? errorTrailing;

  /// Customize error [Overlay] background color
  /// default to Colors.red[600]
  final Color errorBackgroundColor;

  /// Customize error [Overlay] text color
  /// default to Colors.white
  final Color errorColor;

  /// Additional function that can be called when an info message occur
  final void Function(String info)? onInfo;

  /// if [onInfoTap] is not null an action will be added to the [Overlay] when an info message occur
  final void Function(String info)? onInfoTap;

  /// Customize info [Overlay] leading
  /// default to Icons.info
  final Widget infoLeading;

  /// Customize info [Overlay] trailing widget
  /// Default is empty
  final Widget? infoTrailing;

  /// Customize info [Overlay] background color
  /// default to Colors.red[600]
  final Color infoBackgroundColor;

  /// Customize info [Overlay] text color
  /// default to Colors.white
  final Color infoColor;

  const MessageOverlayListener(
      {Key? key,
      required this.child,
      this.onError,
      this.onErrorTap,
      this.errorBackgroundColor = Colors.red,
      this.errorColor = Colors.white,
      this.errorLeading = const Icon(Icons.error, color: Colors.white),
      this.errorTrailing,
      this.onInfo,
      this.onInfoTap,
      this.infoBackgroundColor = Colors.lightBlue,
      this.infoColor = Colors.white,
      this.infoLeading = const Icon(Icons.info, color: Colors.white),
      this.infoTrailing})
      : super(key: key);

  @override
  _MessageOverlayListenerState<T> createState() =>
      _MessageOverlayListenerState();
}

class _MessageOverlayListenerState<T extends MessageNotifierMixin>
    extends State<MessageOverlayListener<T>>
    with SingleTickerProviderStateMixin<MessageOverlayListener<T>> {
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
    return MessageListener<T>(
        child: widget.child,
        showError: (error) => _handleError(context, error),
        showInfo: (info) => _handleInfo(context, info));
  }

  void _handleError(BuildContext context, String error) {
    _close().then((_) {
      _notificationPopup = OverlayEntry(
          builder: (context2) => _OverlayBody(
                controller: controller,
                body: error,
                leading: widget.errorLeading,
                trailing: widget.errorTrailing,
                backgroundColor: widget.errorBackgroundColor,
                textColor: widget.errorColor,
                onTap: widget.onErrorTap,
                onClosed: () {
                  _close();
                },
              ));
      Overlay.of(context)!.insert(_notificationPopup!);
      if (widget.onError != null) {
        widget.onError!(error);
      }
    });
  }

  void _handleInfo(BuildContext context, String info) {
    if (ModalRoute.of(context)!.isCurrent) {
      _close().then((_) {
        _notificationPopup = OverlayEntry(
            builder: (context2) => _OverlayBody(
                  controller: controller,
                  body: info,
                  leading: widget.infoLeading,
                  trailing: widget.infoTrailing,
                  backgroundColor: widget.infoBackgroundColor,
                  textColor: widget.infoColor,
                  onTap: widget.onInfoTap,
                  onClosed: () {
                    _close();
                  },
                ));
        Overlay.of(context)!.insert(_notificationPopup!);
        if (widget.onInfo != null) {
          widget.onInfo!(info);
        }
      });
    }
  }

  Future<void> _close() async {
    if (_notificationPopup != null) {
      _notificationPopup!.remove();
      _notificationPopup = null;
    }
  }
}

class _OverlayBody extends StatefulWidget {
  final AnimationController? controller;
  final String body;
  final Widget? leading;
  final Widget? trailing;
  final Color backgroundColor;
  final Color textColor;
  final void Function(String body)? onTap;
  final void Function()? onClosed;

  _OverlayBody(
      {required this.controller,
      required this.body,
      this.leading,
      this.trailing,
      required this.backgroundColor,
      required this.textColor,
      this.onClosed,
      this.onTap,
      Key? key})
      : super(key: key);

  @override
  _OverlayBodyState createState() => _OverlayBodyState();
}

class _OverlayBodyState extends State<_OverlayBody> {
  late Animation<double> positionAnimation;

  @override
  void initState() {
    super.initState();
    positionAnimation = Tween<double>(begin: -60.0, end: 24.0).animate(
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
                    widget.onTap!(widget.body);
                  }
                  _close();
                },
                child: Dismissible(
                    key: Key(
                        'in_app_notification_dismissible_${Random().nextDouble()}'),
                    direction: DismissDirection.up,
                    onDismissed: (direction) {
                      widget.onClosed!();
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                              color: widget.backgroundColor,
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (widget.leading != null) widget.leading!,
                              if (widget.leading != null) SizedBox(width: 16),
                              Expanded(
                                  child: Text(widget.body,
                                      style:
                                          TextStyle(color: widget.textColor))),
                              if (widget.trailing != null) SizedBox(width: 16),
                              if (widget.trailing != null) widget.trailing!
                            ],
                          ),
                        ))))));
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
