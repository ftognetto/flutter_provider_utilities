

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider_utilities/src/listeners/message_listener.dart';
import 'package:provider/provider.dart';
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
class MessageSnackbarListener<T extends MessageNotifierMixin> extends StatelessWidget {


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
  
  const MessageSnackbarListener({
    Key key, 
    @required this.child, 
    this.onError, this.onErrorTap, this.errorActionLabel = 'Segnala', this.errorActionLabelColor = Colors.white, this.errorBackgroundColor = Colors.red, this.errorLeading = const Icon(Icons.error), 
    this.onInfo, this.onInfoTap, this.infoActionLabel = 'Info', this.infoActionLabelColor = Colors.white, this.infoBackgroundColor = Colors.lightBlue, this.infoLeading = const Icon(Icons.info), this.snackBarDisplayTime = const Duration(milliseconds: 4000)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MessageListener<T>(
      child: child, 
      showError: (error) => _handleError(context, error), 
      showInfo: (info) => _handleInfo(context, info)
    );
  }

  void _handleError(BuildContext context, String error) {
      Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: errorBackgroundColor,
          duration: snackBarDisplayTime,
          action: onErrorTap != null ? SnackBarAction(
            label: errorActionLabel,
            onPressed: onErrorTap,
            textColor: errorActionLabelColor
          ) : null,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              errorLeading,
              Expanded(child: Padding( padding:EdgeInsets.only(left:16), child:Text(error) ))
            ],
          ),
        ),
      );
      if (onError != null) { onError(error); }
  }

  void _handleInfo(BuildContext context, String info) {
      Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: infoBackgroundColor,
          duration: snackBarDisplayTime,
          action: onInfoTap != null ? SnackBarAction(
            label: infoActionLabel,
            onPressed: onInfoTap,
            textColor: infoActionLabelColor
          ) : null,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              infoLeading,
              Expanded(child: Padding( padding:EdgeInsets.only(left:16), child:Text(info) ))
            ],
          ),
        ),
      );
      if (onInfo != null) { onInfo(info); }
  }

}
