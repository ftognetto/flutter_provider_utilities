

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
class MessageListener<T extends MessageNotifierMixin> extends StatelessWidget {

  final Widget child;

  /// Additional function that can be called when an error message occur
  final void Function(String error) showError;

  /// Additional function that can be called when an info message occur
  final void Function(String info) showInfo;
  
  const MessageListener({
    Key? key, 
    required this.child, 
    required this.showError, 
    required this.showInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<T, Tuple2<String?, String?>>(
        selector: (ctx, model) => Tuple2(model.error, model.info),
        shouldRebuild: (before, after) {
          return before.item1 != after.item1 || before.item2 != after.item2;
        },
        builder: (context, tuple, child){
        if (tuple.item1 != null) { 
          WidgetsBinding.instance!.addPostFrameCallback((_){
            _handleError(context, tuple.item1!); });
        }
        if (tuple.item2 != null) {
          WidgetsBinding.instance!.addPostFrameCallback((_){
            _handleInfo(context, tuple.item2!); });
        }
        return child!;
      },
      child: child
    );
  }

  void _handleError(BuildContext context, String error) {
    if (ModalRoute.of(context)!.isCurrent){
      showError(error);
      Provider.of<T>(context, listen: false).clearError();
    }
  }

  void _handleInfo(BuildContext context, String info) {
    if (ModalRoute.of(context)!.isCurrent){
      showInfo(info);
      Provider.of<T>(context, listen: false).clearInfo();
    }
    
  }

}
