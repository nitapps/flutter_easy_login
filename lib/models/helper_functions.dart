import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// prints a single [message] to console only in debug mode
void printToConsole(Object? message){
  if(kDebugMode){
    print(message);
  }
}

/// helper function to display snack bar message
void showSnackBar(BuildContext context, String text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

/// execute the [function] based on [mounted]
/// call setState if [mounted] otherwise execute the [function] normally
void setVariables(bool mounted, StateSetter setState, VoidCallback function){
  if(mounted){
    setState(function);
  }else{
    function();
  }
}