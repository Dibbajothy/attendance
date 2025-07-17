// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'package:attendance/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberPickerPage extends StatefulWidget {
  final List<String> studentsRoll;
  final List<String> studentsName;
  final String course;

  const NumberPickerPage({
    super.key, 
    required this.studentsRoll, 
    required this.studentsName, 
    required this.course
  });

  @override
  State<NumberPickerPage> createState() => _NumberPickerPageState();
}

class _NumberPickerPageState extends State<NumberPickerPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late FixedExtentScrollController _controller;
  late final int _totalItems;
  bool _groupMode = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final Map<int, int> _groupedNumbers = {};
  final List<int> _customNumbers = [];
  
  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
    _totalItems = widget.studentsRoll.length;
    
    // Set up animation for pulsing effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    for (int i = 0; i < widget.studentsRoll.length; i++) {
      _groupedNumbers[int.parse(widget.studentsRoll[i])] = -1;
      _customNumbers.add(int.parse(widget.studentsRoll[i]));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _present() {
    _groupedNumbers[_customNumbers[_selectedIndex]] = 1;

    final steps = _groupMode ? 2 : 1;
    final nextIndex = (_selectedIndex + steps) % _totalItems;

    _controller.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _absent() {
    _groupedNumbers[_customNumbers[_selectedIndex]] = 0;

    final steps = _groupMode ? 2 : 1;
    final nextIndex = (_selectedIndex + steps) % _totalItems;

    _controller.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }
  
  void _toggleGroupMode() {
    setState(() {
      _groupMode = !_groupMode;
    });
  }

  void _saveAttendance() {
    final apiService = ApiService(
      baseUrl: 'https://attendance-backend-production-76c8.up.railway.app', 
      course: widget.course
    );

    apiService.sendGroupedNumbers(_groupedNumbers).then((success) {
      if (success) {
        print('Data sent successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance saved successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color.fromARGB(255, 123, 213, 128),
            behavior: SnackBarBehavior.floating,
          )
        );
        Navigator.pop(context);
      } else {
        print('Failed to send data');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save attendance. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    });
  }

  int get presentCount => _groupedNumbers.values.where((status) => status == 1).length;
  int get absentCount => _groupedNumbers.values.where((status) => status == 0).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        child: SafeArea(
          child: Column(
            children: [
              // Header with Group and Save buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Group button with neon effect
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _groupMode 
                              ? Colors.cyanAccent.withOpacity(0.6) 
                              : Colors.transparent,
                            blurRadius: 12.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _toggleGroupMode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _groupMode 
                            ? Colors.black
                            : Colors.grey.shade900,
                          foregroundColor: _groupMode 
                            ? Colors.cyanAccent
                            : Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          side: BorderSide(
                            color: _groupMode 
                              ? Colors.cyanAccent 
                              : Colors.grey.shade800,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Group Mode',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            shadows: _groupMode ? [
                              Shadow(
                                color: Colors.cyanAccent.withOpacity(0.7),
                                blurRadius: 8.0,
                              ),
                            ] : [],
                          ),
                        ),
                      ),
                    ),
                    
                    // Save button with neon effect
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.4 * _pulseAnimation.value),
                                blurRadius: 12.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _saveAttendance,
                            icon: Icon(Icons.save),
                            label: Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.greenAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              side: BorderSide(
                                color: Colors.greenAccent,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Number Picker
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 400,
                    width: 350,
                    child: ListWheelScrollView.useDelegate(
                      controller: _controller,
                      itemExtent: 90,
                      perspective: 0.008,
                      diameterRatio: 2.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _customNumbers.length,
                        builder: (context, index) {
                          final number = _customNumbers[index];
                          final studentName = widget.studentsName[index];
                          final isSelected = index == _selectedIndex;
                          
                          return NeonNumberItem(
                            groupedNumbers: _groupedNumbers,
                            number: number,
                            studentName: studentName,
                            isSelected: isSelected,
                            onCheckPressed: _present,
                            onCrossPressed: _absent,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Attendance counters
              Container(
                margin: const EdgeInsets.only(bottom: 30.0, top: 20.0),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 8.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Present counter
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.3),
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Present: $presentCount',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.greenAccent.withOpacity(0.7),
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 30),
                    
                    // Absent counter
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.3),
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.cancel,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Absent: $absentCount',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.redAccent.withOpacity(0.7),
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeonNumberItem extends StatelessWidget {
  final Map<int, int> groupedNumbers;
  final int number;
  final String studentName;
  final bool isSelected;
  final VoidCallback onCheckPressed;
  final VoidCallback onCrossPressed;
  
  const NeonNumberItem({
    required this.groupedNumbers,
    required this.number,
    required this.studentName,
    required this.isSelected,
    required this.onCheckPressed,
    required this.onCrossPressed,
    super.key,
  });

  // Get the main colors based on attendance status
  Color getBackgroundColor() {
    if (!isSelected) return Colors.black;
    
    switch(groupedNumbers[number]) {
      case 1: return Colors.green.shade900;  // Present
      case 0: return Colors.red.shade900;    // Absent
      case -1: return Colors.grey.shade900;  // Not marked
      default: return Colors.black;
    }
  }

  // Get border color based on attendance status
  Color getBorderColor() {
    switch(groupedNumbers[number]) {
      case 1: return Colors.greenAccent;  // Present
      case 0: return Colors.redAccent;    // Absent
      case -1: return isSelected ? Colors.cyanAccent : Colors.grey.shade700;  // Not marked
      default: return Colors.yellow;
    }
  }

  // Get glow color based on status
  Color getGlowColor() {
    switch(groupedNumbers[number]) {
      case 1: return Colors.greenAccent;  // Present
      case 0: return Colors.redAccent;    // Absent
      case -1: return isSelected ? Colors.cyanAccent : Colors.transparent;  // Not marked
      default: return Colors.yellow;
    }
  }

  // Get text color
  Color getTextColor() {
    if (!isSelected) return Colors.grey.shade500;
    
    switch(groupedNumbers[number]) {
      case 1: return Colors.greenAccent;  // Present
      case 0: return Colors.redAccent;    // Absent
      case -1: return Colors.white;       // Not marked
      default: return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: getBorderColor(),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: getGlowColor().withOpacity(isSelected ? 0.5 : 0),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Roll Number & Name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: getBorderColor().withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$number',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: getTextColor(),
                        shadows: isSelected ? [
                          Shadow(
                            color: getGlowColor().withOpacity(0.7),
                            blurRadius: 5.0,
                          ),
                        ] : [],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  
                  Flexible(
                    child: Text(
                      studentName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: getTextColor(),
                        shadows: isSelected ? [
                          Shadow(
                            color: getGlowColor().withOpacity(0.7),
                            blurRadius: 5.0,
                          ),
                        ] : [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Present button
          GestureDetector(
            onTap: onCheckPressed,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: isSelected ? Colors.greenAccent : Colors.grey.shade800,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? Colors.greenAccent.withOpacity(0.5)
                        : Colors.transparent,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: isSelected ? Colors.greenAccent : Colors.grey.shade600,
                size: 24,
              ),
            ),
          ),
          
          // Absent button
          GestureDetector(
            onTap: onCrossPressed,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: isSelected ? Colors.redAccent : Colors.grey.shade800,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? Colors.redAccent.withOpacity(0.5)
                        : Colors.transparent,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                color: isSelected ? Colors.redAccent : Colors.grey.shade600,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}