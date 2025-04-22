import 'package:flutter/material.dart';
import 'dart:ui' show SemanticsFlag;

import 'package:flutter/semantics.dart'; // Required for SemanticsFlag

void main() {
  runApp(const MyApp());
  SemanticsBinding.instance.ensureSemantics();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aria-Selected Test (Scenario A)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ScenarioAPage(),
    );
  }
}

class ScenarioAPage extends StatefulWidget {
  const ScenarioAPage({super.key});

  @override
  State<ScenarioAPage> createState() => _ScenarioAPageState();
}

// Use TickerProviderStateMixin for TabController
class _ScenarioAPageState extends State<ScenarioAPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedRowIndex = -1; // -1 means no row selected

  final List<String> _tableData = ['Apple', 'Banana', 'Cherry'];

  @override
  void initState() {
    super.initState();
    // Controller for 2 tabs
    _tabController = TabController(length: 2, vsync: this);
     // Add listener to update UI if needed when tab changes programmatically
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
         // Optional: force rebuild if state depends on tab index,
         // though TabBar handles its own selection state visually.
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build 0421');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenario A: Roles supporting aria-selected'),
        bottom: TabBar(
          controller: _tabController,
          // The Tab widgets themselves implicitly get the 'tab' role
          // and Flutter framework handles setting isSelected for them
          // based on the TabController's index.
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.tab),
              text: 'Selectable Tabs',
            ),
            Tab(
              icon: Icon(Icons.table_rows),
              text: 'Selectable Rows',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // Content for "Selectable Tabs" tab
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // Displaying the selected tab index just for confirmation
              child: Text(
                'Tab Index ${_tabController.index} is selected.\n\nInspect the Tab elements above in DevTools.\nThe selected tab should have aria-selected="true".\nThe unselected tab should have aria-selected="false".',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Content for "Selectable Rows" tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(), // Width based on content
                1: FlexColumnWidth(),      // Takes remaining space
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              // TableRows implicitly get the 'row' role.
              children: List<TableRow>.generate(_tableData.length, (index) {
                final bool isSelected = _selectedRowIndex == index;
                return TableRow(
                  // Use Semantics to explicitly mark the row as selected/not selected.
                  // The Semantics node will merge with the TableRow's node.
                  children: <Widget>[
                     Semantics(
                       // Key properties for verification:
                       selected: isSelected, // This sets SemanticsFlag.isSelected
                       // enabled: true, // Default is true
                       // button: false, // Default is false
                       // Tappable requires onTap usually, but InkWell provides it
                       child: InkWell(
                         onTap: () {
                           setState(() {
                             _selectedRowIndex = isSelected ? -1 : index; // Toggle selection
                           });
                         },
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Text('Row ${index + 1}'),
                         ),
                       ),
                     ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_tableData[index]),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter/semantics.dart'; // Required for SemanticsFlag

// void main() {
//   runApp(const MyApp());
//   SemanticsBinding.instance.ensureSemantics();
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Aria-Current Fallback Test (Scenario B)',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const ScenarioBPage(),
//     );
//   }
// }

// class ScenarioBPage extends StatefulWidget {
//   const ScenarioBPage({super.key});

//   @override
//   State<ScenarioBPage> createState() => _ScenarioBPageState();
// }

// class _ScenarioBPageState extends State<ScenarioBPage> {
//   bool _isChipSelected = false;
//   bool _isContainerSelected = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scenario B: Roles NOT supporting aria-selected'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             const Text(
//               'Example 1: Selectable RawChip',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             // RawChip is a good example as its default role often doesn't support aria-selected.
//             // The `selected` property maps to SemanticsFlag.isSelected.
//             RawChip(
//               label: const Text('Selectable Chip'),
//               selected: _isChipSelected,
//               onSelected: (bool selected) {
//                 setState(() {
//                   _isChipSelected = selected;
//                 });
//               },
//               showCheckmark: true,
//               selectedColor: Colors.lightGreenAccent,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Expected: When selected, inspect the chip element. It should NOT have aria-selected, but SHOULD have aria-current="true". When not selected, both attributes should be absent.',
//               style: TextStyle(fontStyle: FontStyle.italic),
//             ),
//             const Divider(height: 40),

//             const Text(
//               'Example 2: Custom Selectable Container',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             // Using a Container with Semantics. By default, it won't have a role
//             // supporting aria-selected. We explicitly set the isSelected flag.
//             Semantics(
//               // Key properties for verification:
//               selected: _isContainerSelected, // This sets SemanticsFlag.isSelected
//               button: true, // Give it a role like button (doesn't support aria-selected)
//                            // or omit role entirely. Avoid roles like 'row' or 'tab'.
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     _isContainerSelected = !_isContainerSelected; // Toggle
//                   });
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _isContainerSelected ? Colors.lightGreen[100] : Colors.grey[200],
//                     border: Border.all(color: Colors.black54),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     'Custom Selectable Area (${_isContainerSelected ? "Selected" : "Not Selected"})',
//                   ),
//                 ),
//               ),
//             ),
//              const SizedBox(height: 8),
//             const Text(
//               'Expected: When selected, inspect this container/semantics element. It should NOT have aria-selected, but SHOULD have aria-current="true". When not selected, both attributes should be absent.',
//               style: TextStyle(fontStyle: FontStyle.italic),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }