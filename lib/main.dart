import 'package:attendance/classroom.dart';
import 'package:attendance/number_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Number Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),


      initialRoute: '/',
      routes: {
        '/': (context) => Classroom(),
        '/attendance': (context) => NumberPickerPage(studentsRoll: []),
      },

    );
  }
}

