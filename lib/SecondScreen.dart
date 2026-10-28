import 'package:flutter/material.dart';
import 'analysis.dart';

class AnElevatedButton extends StatelessWidget {
  AnElevatedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Analyse the Data'),
      // Use the context provided by MaterialApp's descendant
      onPressed: () {
        Navigator.push(context,
            new MaterialPageRoute(
                builder: (context) => new analysis()));
      },
    );
  }
}