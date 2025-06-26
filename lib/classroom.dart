import 'dart:async';
import 'dart:convert';
import 'package:attendance/number_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Classroom extends StatefulWidget{

  final String course;

  const Classroom({super.key, required this.course});

  @override
  State<Classroom> createState() => _ClassroomState();
}

class _ClassroomState extends State<Classroom> {

  final List<Map<String, dynamic>> students = [];
  List<String> studentsRoll = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    fetchStudents();
  }
  
  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse('https://attendance-backend-production-76c8.up.railway.app/classroom/${widget.course}'));
      // print('http://192.168.0.197:8000/classroom/${widget.course}');
      // print(widget.course);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> rolls = List<String>.from(data['Students Roll']);
        List<String> names = List<String>.from(data['Students Name']);

        studentsRoll = rolls;
        
        setState(() {
          students.clear();
          for (int i = 0; i < rolls.length && i < names.length; i++) {
            students.add({
              'roll': rolls[i],
              'name': names[i],
            });
          }
          isLoading = false;
          print(students);

        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom'),
      ),
      body: Center(
        child: Column(
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NumberPickerPage(studentsRoll: studentsRoll, course: widget.course),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 45, 45, 45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Process Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      title: Text(
                        student['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student['roll'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: const Color.fromARGB(255, 71, 157, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      )
    );
  }
}


