

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_utilities/src/mixin/message_notifier_mixin.dart';
import 'package:tuple/tuple.dart';

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
class MessageOverlayListener<T extends MessageNotifierMixin> extends StatefulWidget {


  final Widget child;

  /// Additional function that can be called when an error message occur
  final void Function(String error) onError;

  /// if [onErrorTap] is not null an action will be added to the [SnackBar] when an error message occur
  final void Function() onErrorTap;

  /// Customize error [SnackBar] action label
  final String errorActionLabel;

  /// Customize error [SnackBar] action color
  final Color errorActionLabelColor;

  /// Customize error [SnackBar] background color
  /// default to Colors.red[600]
  final Color errorBackgroundColor;

  /// Customize error [SnackBar] leading icon
  /// default to Icons.error
  final Widget errorLeading;

  /// Additional function that can be called when an info message occur
  final void Function(String info) onInfo;

  /// if [onInfoTap] is not null an action will be added to the [SnackBar] when an info message occur
  final void Function() onInfoTap;
  
  /// Customize info [SnackBar] action label
  final String infoActionLabel;

  /// Customize info [SnackBar] action color
  final Color infoActionLabelColor;

  /// Customize info [SnackBar] background color
  /// default to Colors.lightBlue
  final Color infoBackgroundColor;

  /// Customize info [SnackBar] leading
  /// default to Icons.info
  final Widget infoLeading;

  /// [SnackBar] duration
  /// default is Duration(milliseconds: 4000)
  final Duration snackBarDisplayTime;
  
  const MessageOverlayListener({
    Key key, 
    @required this.child, 
    this.onError, this.onErrorTap, this.errorActionLabel = 'Segnala', this.errorActionLabelColor = Colors.white, this.errorBackgroundColor = Colors.red, this.errorLeading = const Icon(Icons.error), 
    this.onInfo, this.onInfoTap, this.infoActionLabel = 'Info', this.infoActionLabelColor = Colors.white, this.infoBackgroundColor = Colors.lightBlue, this.infoLeading = const Icon(Icons.info), this.snackBarDisplayTime = const Duration(milliseconds: 4000)
  }) : super(key: key);

  @override
  _MessageOverlayListenerState<T> createState() => _MessageOverlayListenerState();
}

class _MessageOverlayListenerState<T extends MessageNotifierMixin> extends State<MessageOverlayListener<T>> with SingleTickerProviderStateMixin<MessageOverlayListener<T>> {

  OverlayEntry _notificationPopup;
  AnimationController controller;
  final animationDuration = Duration(milliseconds: 400);

  @override
  void initState() { 
    super.initState();
    controller = AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<T, Tuple2<String, String>>(
        selector: (ctx, model) => Tuple2(model.error, model.info),
        shouldRebuild: (before, after) {
          return before.item1 != after.item1 || before.item2 != after.item2;
        },
        builder: (context, tuple, child){
        if (tuple.item1 != null) { 
          WidgetsBinding.instance.addPostFrameCallback((_){
            _handleError(context, tuple.item1); });
        }
        if (tuple.item2 != null) {
          WidgetsBinding.instance.addPostFrameCallback((_){
            _handleInfo(context, tuple.item2); });
        }
        return child;
      },
      child: widget.child
    );
  }

  void _handleError(BuildContext context, String error) {
    if (ModalRoute.of(context).isCurrent){
      _showError(error);
      Provider.of<T>(context, listen: false).clearError();
    }
  }

  void _handleInfo(BuildContext context, String info) {
    if (ModalRoute.of(context).isCurrent){
      _showInfo(info);
      Provider.of<T>(context, listen: false).clearInfo();
    }
  }

  Future<void> _showError(String error) async {

    await _close();
    _notificationPopup = OverlayEntry(
      builder: (context2) => _OverlayBody(
        controller: controller, 
        body: error,
        leading: widget.errorLeading,
        color: widget.errorBackgroundColor ?? Theme.of(context).accentColor,
        onClosed: (){
          _close();
        },
      )
      
    );
    Overlay.of(context).insert(_notificationPopup);

  }

  Future<void> _showInfo(String info) async {

    await _close();
    _notificationPopup = OverlayEntry(
      builder: (context2) => _OverlayBody(
        controller: controller, 
        body: info,
        leading: widget.infoLeading,
        color: widget.infoBackgroundColor ?? Theme.of(context).primaryColor,
        onClosed: (){
          _close();
        },
      )
    );
    Overlay.of(context).insert(_notificationPopup);

  }

  Future<void> _close() async {
      if (_notificationPopup != null) {
        _notificationPopup.remove();
        _notificationPopup = null;
      }
  }
}

class _OverlayBody extends StatefulWidget {

  final AnimationController controller;
  final String body;
  final Widget leading;
  final Widget trailing;
  final Color color;
  final void Function(String body) onTap;
  final void Function() onClosed;

  _OverlayBody({@required this.controller, @required this.body, this.leading, this.trailing, this.color, this.onClosed, this.onTap, Key key}) : super(key: key);

  @override
  _OverlayBodyState createState() => _OverlayBodyState();
}

class _OverlayBodyState extends State<_OverlayBody> {

  Animation<double> positionAnimation;

   @override
  void initState() {
    super.initState();
    positionAnimation = Tween<double>(begin: -48.0, end: 24.0).animate(CurvedAnimation(parent: widget.controller, curve: Curves.linear));
    widget.controller.forward();
    widget.controller.addListener(_refresh);
    Future.delayed(Duration(seconds: 5),() {
      _close();
    });
  }

  void _refresh()  => setState(() {});

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
            onTap: (){ 
              if (widget.onTap != null) { widget.onTap(widget.body); }
              _close(); 
            },
            child: Dismissible(
            key: Key('in_app_notification_dismissible_${Random().nextDouble()}'),
              direction: DismissDirection.up,
              onDismissed: (direction){
                widget.onClosed();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(16)
                  ),
                  
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.leading != null) widget.leading,
                      if (widget.leading != null) SizedBox(width: 16),
                      Expanded(
                        child: Text(widget.body)
                      ),
                      if (widget.trailing != null) widget.trailing
                    ],
                  ),
                )
              )
              
            )
          )
        )
      );
  }

  void _close() {
    widget.controller.reverse().then((value) {
       widget.onClosed();
    });
  }

  @override
  void dispose() { 
    widget.controller.removeListener(_refresh);
    super.dispose();
  }
}