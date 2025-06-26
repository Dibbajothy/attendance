import 'dart:async';
import 'dart:convert';
import 'package:attendance/classroom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Courses extends StatefulWidget{

  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {

  final List<String> courses_list = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    fetchCourses();
  }
  
  Future<void> fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // final response = await http.get(Uri.parse('http://192.168.0.197:8000/courses'));
      final response = await http.get(Uri.parse('https://attendance-backend-production-76c8.up.railway.app/courses'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> courses = List<String>.from(data['courses']);
        
        setState(() {
          courses_list.clear();
          courses_list.addAll(courses);
          isLoading = false;
          print(courses_list);

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
        SnackBar(content: Text('Error loading Courses: $e'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: Center( 
        child: isLoading
          ? const CircularProgressIndicator()
          : courses_list.isEmpty
            ? const Text('No courses available')
            : ListView.builder(

                physics: const BouncingScrollPhysics(),

                itemCount: courses_list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(courses_list[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Classroom(course: courses_list[index],),
                        ),
                      );
                    },
                  );
                },
              ),

      )
    );
  }
}


