import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transcribe_mate/utils/json_helper.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    // _loadImages();
  }

  Future<void> _loadImages() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    Directory imagesDirectory = Directory("${appDirectory.path}/images");
    if (!await imagesDirectory.exists()) {
      imagesDirectory.create();
    }
    setState(() {
      _imageFiles = imagesDirectory
          .listSync()
          .where((file) => file.path.endsWith(".jpg"))
          .map((file) => File(file.path))
          .toList();
    });
  }

  Future<void> _addImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Directory appDirectory = await getApplicationDocumentsDirectory();
      Directory imagesDirectory = Directory("${appDirectory.path}/images");
      await imageFile
          .copy("${imagesDirectory.path}/${DateTime.now().toString()}.jpg");
      await _loadImages();
    }
  }

  Future<void> _transcribeText() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Directory appDirectory = await getApplicationDocumentsDirectory();
      Directory imagesDirectory = Directory("${appDirectory.path}/images");
      await imageFile
          .copy("${imagesDirectory.path}/${DateTime.now().toString()}.jpg");

      final InputImage inputImage = InputImage.fromFile(imageFile);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String text = recognizedText.text;
      String finalText;
      StringBuffer stringBuffer = StringBuffer();

      for (TextBlock block in recognizedText.blocks) {
        final Rect rect = block.boundingBox;
        final List<Point<int>> cornerPoints = block.cornerPoints;
        final String text = block.text;
        final List<String> languages = block.recognizedLanguages;

        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            stringBuffer.write(element.text);
          }
          stringBuffer.write("\n");
        }
      }
      finalText = stringBuffer.toString();

      final notes = await JsonHelper.instance.getNotes();
      // final note = widget.note.copyWith(title: title, content: content, id: widget.note.id);
      final note = Note(
          title: DateTime.now().toString(),
          id: (notes.length + 1).toString(),
          content: finalText);
      await JsonHelper.instance.update(note);
      // _loadImages();
    }
  }

  void _deleteImage(File imageFile, int index) async {
    await imageFile.delete();
    setState(() {
      _imageFiles.removeAt(index);
      // only to update UI
    });
  }

  Future<void> _showImage(File imageFile, int index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(imageFile),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  _deleteImage(imageFile, index);
                  Navigator.of(context).pop();
                },
                child: const Text('DELETE'),
              ),
            ],
          );
        });
  }

  Future<void> _addImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Directory appDirectory = await getApplicationDocumentsDirectory();
      Directory imagesDirectory = Directory("${appDirectory.path}/images");
      await imageFile
          .copy("${imagesDirectory.path}/${DateTime.now().toString()}.jpg");
      await _loadImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
      ),
      body: Container(
          margin: const EdgeInsets.all(15.0),
          child: FutureBuilder(
              future: _loadImages(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading data'),
                  );
                }
                if (_imageFiles.isNotEmpty) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 10),
                    itemCount: _imageFiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          _showImage(_imageFiles[index], index);
                        },
                        child: Image.file(
                          _imageFiles[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }
                return const Center(
                    child: Text(
                  "Add images using the camera/gallery!",
                  style: TextStyle(fontSize: 18.0),
                ));
              })),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: _addImageFromGallery,
            tooltip: 'Add from gallery',
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: _addImageFromCamera,
            tooltip: 'Add from camera',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            label: const Text(
              "Text Recognition",
              style: TextStyle(fontFamily: 'Product Sans'),
            ),
            heroTag: "btn3",
            onPressed: _transcribeText,
            tooltip: 'Text Recognition',
            splashColor: Colors.orange,
            icon: const Icon(Icons.text_fields),
          ),
        ],
      ),
    );
  }
}
