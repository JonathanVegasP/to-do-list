import 'package:flutter/material.dart';
import 'package:to_do_list/scenes/Home/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ToDoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To Do List",
      color: Colors.blueGrey,
      home: Home(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (l, s) => l,
    );
  }
}

void main() => runApp(ToDoList());
