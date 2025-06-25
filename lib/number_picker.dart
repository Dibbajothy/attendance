// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'package:attendance/api_service.dart';
import 'package:flutter/material.dart';


class NumberPickerPage extends StatefulWidget {

  final List<String> studentsRoll;
  const NumberPickerPage({super.key, required this.studentsRoll});

  @override
  State<NumberPickerPage> createState() => _NumberPickerPageState();
}

class _NumberPickerPageState extends State<NumberPickerPage> {
  int _selectedIndex = 0;
  late FixedExtentScrollController _controller;
  final int _totalItems = 60;
  bool _groupMode = false;


  final Map<int, int> _groupedNumbers = {};
  final List<int> _customNumbers = [];
  
  
  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);

    for (int i = 0; i < widget.studentsRoll.length; i++) {
      _groupedNumbers[int.parse(widget.studentsRoll[i])] = -1;
      _customNumbers.add(int.parse(widget.studentsRoll[i]));
    }

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _present() {

    _groupedNumbers[_customNumbers[_selectedIndex]] =  1;



    final steps = _groupMode ? 2 : 1;
    final nextIndex = (_selectedIndex + steps) % _totalItems;

    _controller.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }

  
  void _absent() {

    _groupedNumbers[_customNumbers[_selectedIndex]] = 0;

    final steps = _groupMode ? 2 : 1;
    final nextIndex = (_selectedIndex + steps) % _totalItems;

    _controller.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }
  
  void _toggleGroupMode() {
    setState(() {
      _groupMode = !_groupMode;
    });
  }


  void _saveAttendance() {

    final apiService = ApiService(baseUrl: 'https://attendance-backend-production-76c8.up.railway.app');
    // final apiService = ApiService(baseUrl: 'http://192.168.0.197:8000');

    apiService.sendGroupedNumbers(_groupedNumbers).then((success) {
      if (success) {
        print('Data sent successfully');
      } else {
        print('Failed to send data');
      }
    });
    
  }


  int get presentCount => _groupedNumbers.values.where((status) => status == 1).length;
  int get absentCount => _groupedNumbers.values.where((status) => status == 0).length;


  @override
  Widget build(BuildContext context) {

    // final List<int> _customNumbers = [1, 5, 50, 80, 82];
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Column(
        children: [
          // Group Button at the top
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _toggleGroupMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _groupMode 
                        ? const Color.fromARGB(255, 76, 158, 175) 
                        : const Color.fromARGB(255, 45, 45, 45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Group',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _groupMode ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),

                  const SizedBox(width: 180),

                  ElevatedButton(
                    onPressed: _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 45, 45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          


          // Number Picker
          Expanded(
            child: Center(
              child: SizedBox(
                height: 400,
                width: 330,

                child: ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 80, // Height of each container
                  perspective: 0.006,
                  diameterRatio: 2.0,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    // childCount: _totalItems,
                    childCount: _customNumbers.length,
                    builder: (context, index) {
                      // final number = index + 1;
                      final number = _customNumbers[index];
                      final isSelected = index == _selectedIndex;
                      
                      return NumberItem(
                        groupedNumbers: _groupedNumbers,
                        number: number,
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

          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Present: $presentCount',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  'Absent: $absentCount',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NumberItem extends StatelessWidget {
  final Map<int, int> groupedNumbers;
  final int number;
  final bool isSelected;
  final VoidCallback onCheckPressed;
  final VoidCallback onCrossPressed;
  
  const NumberItem({
    required this.groupedNumbers,
    required this.number,
    required this.isSelected,
    required this.onCheckPressed,
    required this.onCrossPressed,
    super.key,
  });


  Color getBackgroundColor() {

    if (isSelected && (groupedNumbers[number] == 1)) {
      return const Color.fromARGB(255, 0, 231, 200);
    } else if (isSelected && (groupedNumbers[number] == 0)) {
      return const Color.fromARGB(255, 255, 115, 115);
    }
    else if (isSelected && (groupedNumbers[number] == -1)) {
      return const Color.fromARGB(255, 255, 255, 255);
    }
    else if (isSelected && (groupedNumbers[number] == null)) {
      return const Color.fromARGB(255, 229, 255, 0);
    }
    else {
      return const Color.fromARGB(255, 0, 0, 0);
    }
  }

  Color getBorder() {

    if (groupedNumbers[number] == 1) {
      return const Color.fromARGB(255, 0, 231, 200);
    } else if (groupedNumbers[number] == 0) {
      return const Color.fromARGB(255, 255, 115, 115);
    }
    else if (groupedNumbers[number] == -1) {
      return const Color.fromARGB(255, 224, 224, 224);
    }
    else {
      return const Color.fromARGB(255, 229, 255, 0);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),

      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,

      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.black : getBorder(),
          width: 1,
        ),
      ),

      child: Row(
        children: [
          // Number
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          
          // Check button
          GestureDetector(
            onTap: onCheckPressed,
            child: Container(
              width: 55,
              height: 55,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.black : const Color.fromARGB(255, 45, 45, 45),
              ),
              child: Icon(
                Icons.check,
                color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.white,
                size: 24,
              ),
            ),
          ),
          
          // Cross button
          GestureDetector(
            onTap: onCrossPressed,
            child: Container(
              width: 55,
              height: 55,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color.fromARGB(255, 255, 0, 0) : const Color.fromARGB(255, 68, 0, 0),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
