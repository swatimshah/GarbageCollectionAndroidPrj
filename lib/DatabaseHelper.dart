import 'package:hello_flutter/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    print("Initializing database ... ");
    if (_database != null) return _database!;
    _database = await _initDB('image_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    print("Opening database ...");
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    print("Creating database ...");
    await db.execute('''
      CREATE TABLE ImageData (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        PredictedLabel TEXT NOT NULL,
        ActualLabel TEXT NOT NULL,
        DiscrepancyFlag INTEGER NOT NULL
      )
    ''');
  }

  // Insert the label and gallery image path
  Future<int> insertRecord(
    String PredictedLabel,
    String ActualLabel,
    DiscrepancyFlag,
  ) async {
    print("Inserting the record ... ");
    final db = await instance.database;
    return await db.insert('ImageData', {
      'PredictedLabel': PredictedLabel,
      'ActualLabel': ActualLabel,
      'DiscrepancyFlag': DiscrepancyFlag,
    });
  }

  Future<int> getColumnSum() async {
    print("Getting discrepancies ...");
    // Get a reference to your initialized database
    final db = await instance.database;

    // Run the raw query with an alias
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(DiscrepancyFlag) AS total FROM ImageData',
    );

    print(result.elementAt(0)['total']);

    // Extract the value from the first row and column
    // It returns 0 if the table is empty or values are null
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getTotalEntries() async {
    print("Getting total entries ...");
    final db = await instance.database;
    // Execute the count query
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) FROM ImageData',
    );

    print(Sqflite.firstIntValue(result));

    // Parse and return the integer value safely (returns 0 if null)
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getAccuracy() async {
    print("Getting Accuracy ...");
    int totalEntries = await getTotalEntries();
    print(totalEntries);
    int discrepancies = await getColumnSum();
    print(discrepancies);
    double accuracy = (totalEntries - discrepancies) / totalEntries;
    print(accuracy);

    return accuracy;
  }

  Future<void> clearTable() async {
    // Alternative using raw SQL:
    print("Clearing the database ... ");
    final db = await instance.database;
    await db.execute("DELETE FROM ImageData");
  }

  // Separate SQLite Query for each action
  /*  Future<String> fetchData(int id) async {
    final db = await instance.database;

    if (id == 1) {
      final List<Map<String, dynamic>> result = await db.query(
        'ImageData',
        columns: ['COUNT(*) AS total'],
        where: 'PredictedLabel = ? and ActualLabel = ?',
        whereArgs: ['0 leaves', 'leaves'],
      );

      if (result.isNotEmpty) {
        return (result.first['total'] as int).toString();
      }
      return '0';
    }

    if (id == 2) {
      final List<Map<String, dynamic>> result = await db.query(
        'ImageData',
        columns: ['COUNT(*) AS total'],
        where: 'PredictedLabel = ? and ActualLabel = ?',
        whereArgs: ['1 paper', 'paper'],
      );

      if (result.isNotEmpty) {
        return (result.first['total'] as int).toString();
      }
      return '0';
    }

    if (id == 3) {
      final List<Map<String, dynamic>> result = await db.query(
        'ImageData',
        columns: ['COUNT(*) AS total'],
        where: 'PredictedLabel = ? and ActualLabel = ?',
        whereArgs: ['2 plastic', 'plastic'],
      );

      if (result.isNotEmpty) {
        return (result.first['total'] as int).toString();
      }
      return '0';
    }

    return '0';
  } */

  Future<List<String>> getTotalPredictedLabels() async {
    print("Getting total entries ...");
    final db = await instance.database;
    // Execute the count query
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT PredictedLabel FROM ImageData',
    );

    // Convert List<Map> to a List<String>
    List<String> labels = result
        .map((row) => row['PredictedLabel'].toString())
        .toList();

    print(labels.length);
    // Converts the list to a single string, then wraps it in a completed Future
    // Future<String> futureString = Future.value(labels.join(' '));
    return labels;
  }

  Future<List<String>> getTotalActualLabels() async {
    print("Getting total entries ...");
    final db = await instance.database;
    // Execute the count query
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT ActualLabel FROM ImageData',
    );

    // Convert List<Map> to a List<String>
    List<String> labels = result
        .map((row) => row['ActualLabel'].toString())
        .toList();

    print(labels.length);
    // Converts the list to a single string, then wraps it in a completed Future
    // Future<String> futureString = Future.value(labels.join(' '));
    return labels;
  }

  Future<int> getTotalCorrectLeaves() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['0 leaves', '0 leaves'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalCorrectPaper() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['1 paper', '1 paper'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalCorrectPlastic() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['2 plastic', '2 plastic'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPaperAsLeaves() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['0 leaves', 'paper'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPlasticAsLeaves() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['0 leaves', 'plastic'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPlasticAsPaper() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['1 paper', 'plastic'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getLeavesAsPaper() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['1 paper', 'leaves'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getLeavesAsPlastic() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['2 plastic', 'leaves'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPaperAsPlastic() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT COUNT(*) FROM ImageData WHERE TRIM(PredictedLabel, ' ' || CHAR(10) || CHAR(13)) = ? AND TRIM(ActualLabel, ' ' || CHAR(10) || CHAR(13)) = ?''',
      ['2 plastic', 'paper'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }



}
