import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hello_flutter/DatabaseHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'SecondScreen.dart';

List<CameraDescription> cameras = [];
late CameraController _controller;
bool _isPaused = false;
bool isNoChecked = false;
bool isLeavesChecked = false;
bool isPaperChecked = false;
bool isPlasticChecked = false;
bool isPredictionCorrect = true;
bool isFirstImageOfTheCycle = true;
bool _getAccuracy = false;

void main() async {
  // Fetch the available device cameras
  cameras = await availableCameras();

  // Choose the first available camera (usually the rear camera)
  _controller = CameraController(
    cameras.first,
    ResolutionPreset.low, // Choose quality: low, medium, high, max
  );

  late Future<void> _initializeControllerFuture = _controller.initialize();

  // Ensure the camera is fully initialized
  await _initializeControllerFuture;

  runApp(LeafPaperPlasticClassifier());
}

class LeafPaperPlasticClassifier extends StatefulWidget {
  @override
  _LeafPaperPlasticClassifierState createState() =>
      _LeafPaperPlasticClassifierState();
}

class _LeafPaperPlasticClassifierState
    extends State<LeafPaperPlasticClassifier> {
  File? _image;
  String _outputLabel = "No image selected";
  double accuracy = 0.0;
  Interpreter? _interpreter;
  List<String>? _labels;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TF-Lite model and labels
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _labels = await _loadLabels('assets/labels.txt');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Helper to load labels from text asset
  Future<List<String>> _loadLabels(String path) async {
    final labelData = await DefaultAssetBundle.of(context).loadString(path);
    return labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
  }

  // Pick image and process it
  Future<void> _pickAndClassifyImage() async {
    //async
    debugPrint("Inside Pick and Classify Image ... ");

    try {
      // Pause the preview so the screen freezes on the current frame
      await _controller.pausePreview();

      // Capture the picture and retrieve the file object
      final XFile image = await _controller.takePicture();

      await Gal.putImage(image.path);

      debugPrint("Picked the image ... ");

      setState(() {
        _image = File(image.path);
        _outputLabel = "Processing...";
        _isPaused = true;
      });

      _processAndRunModel(_image!);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // Resize and Run Inference
  Future<void> _processAndRunModel(File imageFile) async {
    debugPrint("This is debug statement 0");
    if (_interpreter == null || _labels == null) return;

    debugPrint("This is debug statement 1");
    // 1. Decode the image
    final bytes = await imageFile.readAsBytes();
    debugPrint("This is debug statement 2");
    img.Image? originalImage = img.decodeImage(bytes);
    debugPrint("This is debug statement 3");
    if (originalImage == null) return;

    debugPrint(originalImage.width.toString());
    debugPrint(originalImage.height.toString());

    // 2. Resize to 180x240 (Width x Height)
    img.Image resizedImage = img.copyResize(
      originalImage,
      width: 240,
      height: 180,
    );

    // 3. Convert image to a flat 3D list (Height, Width, Channels)
    // Assuming your model expects a 180x240 RGB Float32 input
    var imageBytes = _imageToByteListFloat32(resizedImage);

    // 4. Prepare output buffer
    // Example: If you have 3 classes (leaves, paper, plastic)
    var output = List.filled(3, 0.0).reshape([1, 3]);

    // 5. Run Inference
    _interpreter!.run(imageBytes, output);

    // 6. Find highest probability index and display label
    int maxIndex = _argmax(output[0]);
    setState(() {
      _outputLabel = _labels![maxIndex];
    });
  }

  // Helper function to convert Image to Float32 list
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    var convertedBytes = List.generate(
      1,
      (b) => List.generate(
        180, // Height
        (y) => List.generate(
          240, // Width
          (x) => List.generate(3, (c) => 0.0), // Channels: R, G, B
        ),
      ),
    );

    for (int y = 0; y < 180; y++) {
      for (int x = 0; x < 240; x++) {
        var pixel = image.getPixel(x, y);
        // Normalize values to [0, 1] or [-1, 1] depending on your model
        convertedBytes[0][y][x][0] = pixel.r.toDouble();

        /// 255.0;
        convertedBytes[0][y][x][1] = pixel.g.toDouble();

        /// 255.0;
        convertedBytes[0][y][x][2] = pixel.b.toDouble();

        /// 255.0;
      }
    }
    return convertedBytes;
  }

  // Helper function to find index of highest probability
  int _argmax(List<dynamic> probabilities) {
    int maxIndex = 0;
    double maxProb = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Leaf, Paper, Plastic Classifier')),
        body: Align(
          alignment: Alignment.topCenter,
          // Aligns child to the top middle
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnElevatedButton(),
                  if (isFirstImageOfTheCycle) ...[
                    Checkbox(
                      value: !isFirstImageOfTheCycle,
                      onChanged: (bool? value) {
                        setState(() {
                          DatabaseHelper.instance.clearTable();
                          isFirstImageOfTheCycle = false;
                        });
                      },
                    ),
                    Text('Clear The DataBase'),
                  ],
                ],
              ),
              CameraPreview(_controller),

              //SizedBox(height: 20),
              if (_isPaused) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Label: $_outputLabel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPredictionCorrect) ...[
                      Checkbox(value: !_isPaused, onChanged: onCheckBoxChanged),
                      Text('Yes'),

                      Checkbox(
                        value: isNoChecked, //!_isPaused,
                        onChanged: (newValue) {
                          setState(() {
                            isNoChecked = newValue ?? false;
                            // Uncheck the sub-boxes if "No" gets unchecked
                            if (isNoChecked) {
                              isLeavesChecked = false;
                              isPaperChecked = false;
                              isPlasticChecked = false;
                            }
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Conditional rendering
                    if (isNoChecked) ...[
                      Checkbox(
                        value: isLeavesChecked,
                        onChanged: (val) {
                          onLeavesCheckBoxChanged(val);
                        },
                      ),
                      Text('Leaves'),
                      Checkbox(
                        value: isPaperChecked,
                        onChanged: (val) {
                          onPaperCheckboxChanged(val);
                        },
                      ),
                      Text('Paper'),
                      Checkbox(
                        value: isPlasticChecked,
                        onChanged: (val) {
                          onPlasticCheckboxChanged(val);
                        },
                      ),
                      Text('Plastic'),
                    ],
                  ],
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isFirstImageOfTheCycle && _getAccuracy) ...[
                    Text('Accuracy: $accuracy'),
                  ],
                ],
              ),
            ],
          ),
        ),

        floatingActionButton: IconButton(
          onPressed: _pickAndClassifyImage,
          tooltip: 'Capture Photo',
          color: !_isPaused ? Colors.blue : Colors.grey,
          icon: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  void onPlasticCheckboxChanged(bool? val) async {
    await DatabaseHelper.instance.insertRecord(_outputLabel, 'plastic', 1);
    await DatabaseHelper.instance.getAccuracy().then((double predAccuracy) {
      accuracy = predAccuracy;
    });
    setState(() {
      isPlasticChecked = val ?? false;
      _controller.resumePreview();
      isNoChecked = false;
      isPredictionCorrect = true;
      _isPaused = false;
      _getAccuracy = true;
    });
  }

  void onPaperCheckboxChanged(bool? val) async {
    await DatabaseHelper.instance.insertRecord(_outputLabel, 'paper', 1);
    await DatabaseHelper.instance.getAccuracy().then((double predAccuracy) {
      accuracy = predAccuracy;
    });

    setState(() {
      isPaperChecked = val ?? false;
      _controller.resumePreview();
      isNoChecked = false;
      isPredictionCorrect = true;
      _isPaused = false;
      _getAccuracy = true;
    });
  }

  void onLeavesCheckBoxChanged(bool? val) async {
    await DatabaseHelper.instance.insertRecord(_outputLabel, 'leaves', 1);
    await DatabaseHelper.instance.getAccuracy().then((double predAccuracy) {
      accuracy = predAccuracy;
    });
    setState(() {
      isLeavesChecked = val ?? false;
      _controller.resumePreview();
      isNoChecked = false;
      isPredictionCorrect = true;
      _isPaused = false;
      _getAccuracy = true;
    });
  }

  Future<void> onCheckBoxChanged(bool? value) async {
    await DatabaseHelper.instance.insertRecord(_outputLabel, _outputLabel, 0);
    await DatabaseHelper.instance.getAccuracy().then((double predAccuracy) {
      accuracy = predAccuracy;
    });
    setState(() {
      _isPaused = false;
      _getAccuracy = true;
    });
    _controller.resumePreview();
  }
}
