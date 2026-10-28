import 'package:flutter/material.dart';
import 'package:hello_flutter/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

int myLeaves = 0;
int myPaper = 0;
int myPlastic = 0;
int myPaperAsLeaves = 0;
int myPlasticAsLeaves = 0;
int myPlasticAsPaper = 0;
int myLeavesAsPaper = 0;
int myLeavesAsPlastic = 0;
int myPaperAsPlastic = 0;
double myAccuracy = 0.0;

class summary extends StatefulWidget {
  @override
  _summaryState createState() => _summaryState();
}

class _summaryState extends State<summary> {
  int _correctLeaves = 0;
  int _correctPapers = 0;
  int _correctPlastic = 0;
  int _paperAsLeaves = 0;
  int _plasticAsLeaves = 0;
  int _plasticAsPaper = 0;
  int _leavesAsPaper = 0;
  int _leavesAsPlastic = 0;
  int _paperAsPlastic = 0;
  double _accuracy = 0.0;

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

    _correctLeaves = await DatabaseHelper.instance.getTotalCorrectLeaves();
    _correctPapers = await DatabaseHelper.instance.getTotalCorrectPaper();
    _correctPlastic = await DatabaseHelper.instance.getTotalCorrectPlastic();
    _paperAsLeaves = await DatabaseHelper.instance.getPaperAsLeaves();
    _plasticAsLeaves = await DatabaseHelper.instance.getPlasticAsLeaves();
    _plasticAsPaper = await DatabaseHelper.instance.getPlasticAsPaper();
    _leavesAsPaper = await DatabaseHelper.instance.getLeavesAsPaper();
    _leavesAsPlastic = await DatabaseHelper.instance.getLeavesAsPlastic();
    _paperAsPlastic = await DatabaseHelper.instance.getPaperAsPlastic();
    _accuracy = await DatabaseHelper.instance.getAccuracy();

    print(_correctLeaves);
    print(_correctPapers);
    print(_correctPlastic);
    print(_paperAsLeaves);
    print(_plasticAsLeaves);
    print(_plasticAsPaper);
    print(_leavesAsPaper);
    print(_leavesAsPlastic);
    print(_paperAsPlastic);
    print(_accuracy);

    setState(() {
      myLeaves = _correctLeaves;
      myPaper = _correctPapers;
      myPlastic = _correctPlastic;
      myPaperAsLeaves = _paperAsLeaves;
      myPlasticAsLeaves = _plasticAsLeaves;
      myPlasticAsPaper = _plasticAsPaper;
      myLeavesAsPaper = _leavesAsPaper;
      myLeavesAsPlastic = _leavesAsPlastic;
      myPaperAsPlastic = _paperAsPlastic;
      myAccuracy = _accuracy;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Table(
            border: TableBorder.all(), // Optional: adds borders to cells
            children: [
              TableRow(
                children: [
                  // TableCell(child: Text('Item 1')), // TableCell controls inner layout
                  // TableCell(child: Text('Item 2')),
                  // TableCell(child: Text('Item 3')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Correctly Predicted Leaves:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myLeaves',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Correctly Predicted Paper:  ",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myPaper',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Correctly Predicted Plastic:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myPlastic',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Paper Predicted As Leaves:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myPaperAsLeaves',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Plastic Predicted As Leaves:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myPlasticAsLeaves',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Plastic Predicted As Paper:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myPlasticAsPaper',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Leaves Predicted As Paper:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myLeavesAsPaper',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Leaves Predicted As Plastic:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myLeavesAsPlastic',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              TableRow(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Paper Predicted As Plastic:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myPaperAsPlastic',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              //Positioned(
              // right: 0,
              TableRow(
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Accuracy:", style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            //color: Colors.blue,
                            child: Text(
                              '$myAccuracy',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      //),
                      //),                      //),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
