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
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const NumberPickerPage(),
    );
  }
}

class NumberPickerPage extends StatefulWidget {
  const NumberPickerPage({super.key});

  @override
  State<NumberPickerPage> createState() => _NumberPickerPageState();
}

class _NumberPickerPageState extends State<NumberPickerPage> {
  int _selectedIndex = 14; // For 15 to be selected (0-indexed)
  late FixedExtentScrollController _controller;
  final int _totalItems = 60;
  
  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _scrollToNext() {
    final nextIndex = (_selectedIndex + 1) % _totalItems;
    _controller.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }
  
  void _scrollToPrevious() {
    final prevIndex = (_selectedIndex - 1 + _totalItems) % _totalItems;
    _controller.animateToItem(
      prevIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
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
              childCount: _totalItems,
              builder: (context, index) {
                final number = index + 1;
                final isSelected = index == _selectedIndex;
                
                return NumberItem(
                  number: number,
                  isSelected: isSelected,
                  onCheckPressed: _scrollToNext,
                  onCrossPressed: _scrollToPrevious,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NumberItem extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onCheckPressed;
  final VoidCallback onCrossPressed;
  
  const NumberItem({
    required this.number,
    required this.isSelected,
    required this.onCheckPressed,
    required this.onCrossPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
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
              width: 50,
              height: 50,
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
              width: 50,
              height: 50,
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