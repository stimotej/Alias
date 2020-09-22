import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'alias_home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alias',
      theme: ThemeData(
        accentColor: Colors.blueAccent[700],
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          color: Colors.grey[200],
          iconTheme: IconThemeData(color: Colors.grey[800]),
        ),
        primaryTextTheme: TextTheme(
            headline6: TextStyle(
                color: Colors.black
            )
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          elevation: 12,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.black),
        accentColor: Colors.blueAccent[700],
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          elevation: 12,
        ),
        cursorColor: Colors.white,
        textSelectionHandleColor: Colors.white,
        textSelectionColor: Colors.white24,
      ),
      home: AliasHomePage(title: 'Alias'),
    );
  }
}


