import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ChoreQuestApp());
}

class ChoreQuestApp extends StatelessWidget {
  const ChoreQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chore Quest Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F101A), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF222D87),       // Deep Blue
          secondary: Color(0xFF68CAB3),     // Mint Green
          tertiary: Color(0xFF833D95),      // Purple Accent
          surface: Color(0xFF17192D),       
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  String currentUser = "You"; 

  int myScore = 145;
  int alexScore = 132;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();

  String _selectedTaskType = 'Shared'; 
  String _selectedAssignee = 'You';  

  String _rouletteResult = "Tap the button below to leave your tasks to destiny.";
  bool _isSpinning = false;

  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Pay electric bill', 'type': 'Shared', 'assignedTo': 'Shared', 'points': 20, 'isDone': false, 'dueDate': 'July 15', 'missed': false},
    {'title': 'Tidy bedroom drawers', 'type': 'Individual', 'assignedTo': 'You', 'points': 0, 'isDone': false, 'dueDate': 'July 10', 'missed': true}, 
    {'title': 'Clean car windows', 'type': 'Shared', 'assignedTo': 'Shared', 'points': 15, 'isDone': false, 'dueDate': 'July 14', 'missed': false},
  ];

  final List<Map<String, dynamic>> _chores = [
    {'title': 'Vacuum lounge', 'frequency': 'Every 3 Days', 'points': 15, 'lastDoneBy': 'Alex'},
    {'title': 'Feed cat', 'frequency': 'Daily', 'points': 5, 'lastDoneBy': 'You'},
  ];

  void _toggleTask(int index) {
    setState(() {
      var task = _tasks[index];
      task['isDone'] = !task['isDone'];
      
      if (task['type'] == 'Shared') {
        if (task['isDone']) {
          if (currentUser == 'You') myScore += (task['points'] as int);
          if (currentUser == 'Alex') alexScore += (task['points'] as int);
        } else {
          if (currentUser == 'You') myScore -= (task['points'] as int);
          if (currentUser == 'Alex') alexScore -= (task['points'] as int);
        }
      }
    });
  }

  void _completeChore(int index) {
    setState(() {
      var chore = _chores[index];
      chore['lastDoneBy'] = currentUser;
      if (currentUser == 'You') {
        myScore += (chore['points'] as int);
      } else {
        alexScore += (chore['points'] as int);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF68CAB3),
        content: Text('Chore completed! +${_chores[index]['points']} points allocated.', style: const TextStyle(color: Color(0xFF0F101A), fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Task Tracker'),
          backgroundColor: const Color(0xFF17192D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g., Pay Wi-Fi bill')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTaskType,
                  items: ['Shared', 'Individual'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setDialogState(() {
                    _selectedTaskType = val!;
                    if (_selectedTaskType == 'Individual') _selectedAssignee = 'You';
                  }),
                  decoration: const InputDecoration(labelText: 'Task Context'),
                ),
                if (_selectedTaskType == 'Individual') ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedAssignee,
                    items: ['You', 'Alex'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setDialogState(() => _selectedAssignee = val!),
                    decoration: const InputDecoration(labelText: 'Assign To'),
                  ),
                ],
                if (_selectedTaskType == 'Shared') ...[
                  const SizedBox(height: 10),
                  TextField(controller: _pointsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Points Allocated')),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222D87), foregroundColor: Colors.white),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  setState(() {
                    _tasks.add({
                      'title': _titleController.text,
                      'type': _selectedTaskType,
                      'assignedTo': _selectedTaskType == 'Shared' ? 'Shared' : _selectedAssignee,
                      'points': _selectedTaskType == 'Shared' ? (int.tryParse(_pointsController.text) ?? 10) : 0,
                      'isDone': false,
                      'dueDate': 'In 3 Days',
                      'missed': false
                    });
                  });
                  _titleController.clear();
                  _pointsController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }

  void _showAddChoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Recurring Chore'),
        backgroundColor: const Color(0xFF17192D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Chore Name', hintText: 'e.g., Clean bathroom')),
            TextField(controller: _frequencyController, decoration: const InputDecoration(labelText: 'Frequency', hintText: 'e.g., Weekly, Every 2 Days')),
            TextField(controller: _pointsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Points Value')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222D87), foregroundColor: Colors.white),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _chores.add({
                    'title': _titleController.text,
                    'frequency': _frequencyController.text.isEmpty ? 'Weekly' : _frequencyController.text,
                    'points': int.tryParse(_pointsController.text) ?? 15,
                    'lastDoneBy': 'None',
                  });
                });
                _titleController.clear();
                _frequencyController.clear();
                _pointsController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _spinRoulette() {
    var openTasks = _tasks.where((t) => !t['isDone']).toList();
    if (openTasks.isEmpty) {
      setState(() => _rouletteResult = "No open tasks remaining! 🌟");
      return;
    }
    
    setState(() {
      _isSpinning = true;
      _rouletteResult = "Spinning the engine wheels... 🔄";
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      final random = Random();
      var chosenTask = openTasks[random.nextInt(openTasks.length)];
      setState(() {
        _isSpinning = false;
        _rouletteResult = "Fate has targeted you!\n\n👉 [ ${chosenTask['title']} ]\n\nGet to work, $currentUser! 🫡";
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // TAB 0: Tasks Panel
      ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          bool isIndividual = task['type'] == 'Individual';
          return Card(
            color: task['missed'] ? const Color(0xFF3A1E24) : const Color(0xFF17192D),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: task['missed'] 
                    ? Colors.redAccent.withOpacity(0.5) 
                    : isIndividual ? const Color(0xFFBEF3F8).withOpacity(0.3) : const Color(0xFF68CAB3).withOpacity(0.3), 
                width: 1.5
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: ListTile(
                title: Text(task['title'], style: TextStyle(decoration: task['isDone'] ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isIndividual ? const Color(0xFFBEF3F8).withOpacity(0.15) : const Color(0xFF68CAB3).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isIndividual ? '👤 Individual: ${task['assignedTo']}' : '👥 Shared Task',
                          style: TextStyle(color: isIndividual ? const Color(0xFFBEF3F8) : const Color(0xFF68CAB3), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(isIndividual ? 'Due: ${task['dueDate']}' : '+${task['points']} pts', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                trailing: isIndividual && task['missed'] && !task['isDone']
                  ? const Text('⚠️ OVERDUE\n(-10 pts)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)
                  : Checkbox(
                      value: task['isDone'],
                      activeColor: const Color(0xFF68CAB3),
                      checkColor: const Color(0xFF0F101A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onChanged: (val) => _toggleTask(index),
                    ),
              ),
            ),
          );
        },
      ),

      // TAB 1: Chores Panel
      ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _chores.length,
        itemBuilder: (context, index) {
          final chore = _chores[index];
          return Card(
            color: const Color(0xFF17192D),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF222D87).withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.loop_rounded, color: Color(0xFFBEF3F8)),
              ),
              title: Text(chore['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('🔄 Frequency: ${chore['frequency']} • Value: ${chore['points']} pts\n✨ History: Last done by ${chore['lastDoneBy']}'),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF68CAB3),
                  foregroundColor: const Color(0xFF0F101A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _completeChore(index),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          );
        },
      ),

      // TAB 2: Standalone Roulette Dashboard Layout
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF17192D),
                border: Border.all(
                  color: _isSpinning ? const Color(0xFF68CAB3) : const Color(0xFF833D95), 
                  width: 4
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isSpinning ? const Color(0xFF68CAB3) : const Color(0xFF833D95)).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F101A),
                  border: Border.all(color: Colors.white10),
                ),
                child: Icon(
                  Icons.casino_outlined, 
                  size: 64, 
                  color: _isSpinning ? const Color(0xFF68CAB3) : const Color(0xFFBEF3F8)
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('🎯 Task Roulette', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF833D95).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('Session Active: $currentUser', style: const TextStyle(color: Color(0xFFBEF3F8), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFF17192D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _rouletteResult, 
                  style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500), 
                  textAlign: TextAlign.center
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSpinning ? null : _spinRoulette,
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: const Text('SPIN THE WHEEL OF FATE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF833D95),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),

      // TAB 3: Leaderboard Panel
      ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('🏆 Standings Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Top player selects this month\'s dinner takeaway rewards!', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          
          Card(
            color: myScore >= alexScore ? const Color(0xFF68CAB3).withOpacity(0.15) : const Color(0xFF17192D),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: myScore >= alexScore ? const Color(0xFF68CAB3).withOpacity(0.5) : Colors.white10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const Text('🥇', style: TextStyle(fontSize: 28)),
              title: const Text('❤️ You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: Text('$myScore pts', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF68CAB3))),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: alexScore > myScore ? const Color(0xFF68CAB3).withOpacity(0.15) : const Color(0xFF17192D),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: alexScore > myScore ? const Color(0xFF68CAB3).withOpacity(0.5) : Colors.white10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const Text('🥈', style: TextStyle(fontSize: 28)),
              title: const Text('💙 Alex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: Text('$alexScore pts', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF68CAB3))),
            ),
          ),
        ],
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? '📅 Tasks' : _currentIndex == 1 ? '🔄 Chores' : _currentIndex == 2 ? '🎲 Roulette Engine' : '🏆 Standings',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF222D87),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: const Color(0xFF17192D),
              side: const BorderSide(color: Colors.white10),
              avatar: const Icon(Icons.account_circle, color: Color(0xFFBEF3F8), size: 18),
              label: Text(currentUser, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                setState(() {
                  currentUser = currentUser == "You" ? "Alex" : "You";
                });
              },
            ),
          )
        ],
      ),
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex < 2
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF833D95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                if (_currentIndex == 0) _showAddTaskDialog();
                if (_currentIndex == 1) _showAddChoreDialog();
              },
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFF17192D),
        indicatorColor: const Color(0xFF222D87).withOpacity(0.5),
        onDestinationSelected: (int idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.cached_rounded), label: 'Chores'),
          NavigationDestination(icon: Icon(Icons.casino_rounded), label: 'Roulette'),
          NavigationDestination(icon: Icon(Icons.emoji_events_rounded), label: 'Leaderboard'),
        ],
      ),
    );
  }
}