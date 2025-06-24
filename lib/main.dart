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
  int _selectedIndex = 0; // For 15 to be selected (0-indexed)
  late FixedExtentScrollController _controller;
  final int _totalItems = 60;
  bool _groupMode = false;
  
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
    // If group mode is on, scroll by 2, otherwise by 1
    final steps = _groupMode ? 2 : 1;
    final nextIndex = (_selectedIndex + steps) % _totalItems;
    _controller.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }
  
  void _scrollToPrevious() {
    // If group mode is on, scroll by 2, otherwise by 1
    final steps = _groupMode ? 2 : 1;
    final prevIndex = (_selectedIndex - steps + _totalItems) % _totalItems;
    _controller.animateToItem(
      prevIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
    );
  }
  
  void _toggleGroupMode() {
    setState(() {
      _groupMode = !_groupMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Column(
        children: [
          // Group Button at the top
          Padding(
            padding: const EdgeInsets.only(top: 50.0, right: 20.0),
            child: Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: _toggleGroupMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _groupMode 
                      ? Colors.green 
                      : const Color.fromARGB(255, 45, 45, 45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
          ),
        ],
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
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),

      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,

      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.black : const Color.fromARGB(255, 224, 224, 224),
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
