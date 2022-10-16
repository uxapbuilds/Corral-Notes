import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({this.hasError = false, this.errorText = '', Key? key})
      : super(key: key);
  final bool hasError;
  final String errorText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child:
              hasError ? Text(errorText) : const CircularProgressIndicator()),
    );
  }
}
