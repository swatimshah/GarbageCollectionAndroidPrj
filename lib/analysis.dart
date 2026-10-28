import 'package:flutter/material.dart';
import 'package:hello_flutter/DatabaseHelper.dart';
import 'Summary.dart';

List<String> myList = [];
List<String> myActualLabelsList = [];

class analysis extends StatefulWidget {
  @override
  _analysisState createState() => _analysisState();
}

class _analysisState extends State<analysis> {
  List<String> _items = [];
  List<String> _actualItems = [];

  @override
  void initState() {
    super.initState();
    // 2. Call the async function from initState
    _loadDatabaseData();
  }

  // 3. Keep the asynchronous operation in a separate function
  Future<void> _loadDatabaseData() async {
    // Replace with your actual database helper or setup
    final db = await DatabaseHelper.instance;

    await DatabaseHelper.instance.getTotalPredictedLabels().then((
      List<String> labels,
    ) {
      myList = labels;
    });

    await DatabaseHelper.instance.getTotalActualLabels().then((
      List<String> actualLabels,
    ) {
      myActualLabelsList = actualLabels;
    });

    setState(() {
      _items = myList;
      _actualItems = myActualLabelsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actuals and Predictions')),
      // Assign the Column directly to the body property
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50.0, // Your exact explicit height constraint
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Sr.No')),
                DataColumn(label: Text('ActualLabels')),
                DataColumn(label: Text('PredictedLabels')),
              ],
              rows: List.generate(0, (index) => DataRow(cells: [])),
            ),
          ),

          //Expanded(
          SizedBox(
            height: 600.0, // Your exact explicit height constraint
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowHeight: 0.0, // Height of the header row
                columns: const [
                  DataColumn(label: Text('Sr.No')),
                  DataColumn(label: Text('ActualLabels')),
                  DataColumn(label: Text('PredictedLabels')),
                ],
                rows: List.generate(
                  _actualItems.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(_actualItems[index])),
                      DataCell(Text(_items[index])),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30.0),
          ElevatedButton(
            child: Text('Summary'),
            // Use the context provided by MaterialApp's descendant
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new summary()),
              );
            },
          ),
        ],
      ),
    );
  }
}
