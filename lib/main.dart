import 'package:abb/abbStatefulWidget.dart';
import 'package:flutter/material.dart';

void main() => runApp(AbbApp());

class AbbApp extends StatelessWidget {
  static const String _title = 'ABB';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: AbbStatefulWidget(),
    );
  }
}
