import 'dart:async';
import 'dart:convert';
import 'package:attendance/number_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Classroom extends StatefulWidget {
  final String course;

  const Classroom({super.key, required this.course});

  @override
  State<Classroom> createState() => _ClassroomState();
}

class _ClassroomState extends State<Classroom> {
  final List<Map<String, dynamic>> students = [];
  List<String> studentsRoll = [];
  List<String> studentsName = [];
  bool isLoading = true;
  bool _mounted = true;
  
  @override
  void initState() {
    super.initState();
    fetchStudents();
  }
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  Future<void> fetchStudents() async {
    if (!_mounted) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse('https://attendance-backend-production-76c8.up.railway.app/classroom/${widget.course}'));
      
      if (!_mounted) return;
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> rolls = List<String>.from(data['Students Roll']);
        List<String> names = List<String>.from(data['Students Name']);

        if (!_mounted) return;
        
        studentsRoll = rolls;
        studentsName = names;
        
        setState(() {
          students.clear();
          for (int i = 0; i < rolls.length && i < names.length; i++) {
            students.add({
              'roll': rolls[i],
              'name': names[i],
            });
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      if (!_mounted) return;
      
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading students: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.course,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.cyanAccent.withOpacity(0.7),
                blurRadius: 12.0,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.cyanAccent,
              ),
              onPressed: fetchStudents,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF0A0A1F),
            ],
          ),
        ),
        child: isLoading
            ? _buildLoader()
            : _buildClassroomContent(),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading students...",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  color: Colors.cyanAccent,
                  blurRadius: 8.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.6),
                blurRadius: 15.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NumberPickerPage(
                    studentsRoll: studentsRoll,
                    studentsName: studentsName,
                    course: widget.course,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              side: BorderSide(
                color: Colors.greenAccent,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              'Process Attendance',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.greenAccent.withOpacity(0.9),
                    blurRadius: 8.0,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Student List",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.cyanAccent.withOpacity(0.7),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Text(
                  "${students.length} Students",
                  style: GoogleFonts.poppins(
                    color: Colors.cyanAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: students.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    
                    // Use different colors for variety
                    final List<Color> neonColors = [
                      Colors.cyanAccent,
                    ];
                    final Color neonColor = neonColors[index % neonColors.length];
                    
                    return _buildStudentCard(student, neonColor, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, Color neonColor, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: neonColor.withOpacity(0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: neonColor.withOpacity(0.3),
              blurRadius: 8.0,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          title: Text(
            student['name'] ?? 'Unknown',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: neonColor.withOpacity(0.7),
                  blurRadius: 5.0,
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: neonColor,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: neonColor.withOpacity(0.3),
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Text(
              student['roll'] ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: neonColor,
                shadows: [
                  Shadow(
                    color: neonColor.withOpacity(0.7),
                    blurRadius: 5.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.5),
                  blurRadius: 20.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Students Available",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.pinkAccent.withOpacity(0.7),
                  blurRadius: 10.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "There are no students in this course",
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
