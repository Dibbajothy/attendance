// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'package:attendance/classroom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  final List<String> courses_list = [];
  bool isLoading = true;
  bool _mounted = true;
  
  @override
  void initState() {
    super.initState();
    fetchCourses();
  }
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchCourses() async {
    if (!_mounted) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse('https://attendance-backend-production-76c8.up.railway.app/courses'));
      
      if (!_mounted) return;
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> courses = List<String>.from(data['courses']);
        
        if (!_mounted) return;
        
        setState(() {
          courses_list.clear();
          courses_list.addAll(courses);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      if (!_mounted) return;
      
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading courses: $e',
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
          'My Courses',
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
              onPressed: fetchCourses,
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
          : courses_list.isEmpty
            ? _buildEmptyState()
            : _buildCoursesList(),
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
            "Loading courses...",
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
              Icons.school_outlined,
              size: 80,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Courses Available",
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
            "Check back later or contact your administrator",
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: fetchCourses,
              icon: const Icon(Icons.refresh),
              label: Text(
                "Refresh",
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: const BorderSide(color: Colors.pinkAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: courses_list.length,
        itemBuilder: (context, index) {
          return NeonCourseCard(
            courseName: courses_list[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Classroom(course: courses_list[index]),
                ),
              );
            },
            index: index,
          );
        },
      ),
    );
  }
}

class NeonCourseCard extends StatelessWidget {
  final String courseName;
  final VoidCallback onTap;
  final int index;
  
  const NeonCourseCard({
    required this.courseName,
    required this.onTap,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Neon color palette
    final List<List<Color>> neonColors = [
      [Colors.cyan, Colors.cyanAccent],
    ];
    
    final List<Color> neonPair = neonColors[index % neonColors.length];
    final Color primaryColor = neonPair[0];
    final Color glowColor = neonPair[1];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        splashColor: glowColor.withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.5),
                blurRadius: 12.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      courseName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: glowColor.withOpacity(0.9),
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.5),
                            blurRadius: 8.0,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.school_rounded,
                        color: glowColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}