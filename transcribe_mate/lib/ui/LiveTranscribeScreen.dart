// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

//
// late List<CameraDescription> _cameras;
//
// class LiveTranscribeScreen extends StatefulWidget {
//   const LiveTranscribeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LiveTranscribeScreen> createState() => _LiveTranscribeScreenState();
// }
//
// class _LiveTranscribeScreenState extends State<LiveTranscribeScreen> {
//
//   late CameraController camera;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _cameras = await availableCameras();
//     });
//     camera = CameraController(_cameras[0], ResolutionPreset.max);
//     camera.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//           // Handle access errors here.
//             break;
//           default:
//           // Handle other errors here.
//             break;
//         }
//       }
//     });
//
//     // CONTINUE FROM HERE : ADD FUNCTIONALITY TO TAKE IMAGE AND TRANSCRIBE FROM IT DIRECTLY. SHOW DIALOG WITH DATA, AND IF CONFIRM, SAVE NOTE.
//
//     // final CameraController camera; // your camera instance
//     final CameraImage cameraImage;
//
//     final WriteBuffer allBytes = WriteBuffer();
//     for (final Plane plane in cameraImage.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//
//     final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
//
//     final InputImageRotation? imageRotation =
//     InputImageRotationValue.fromRawValue(camera.sensorOrientation);
//
//     final InputImageFormat? inputImageFormat =
//     InputImageFormatValue.fromRawValue(cameraImage.format.raw);
//
//     final planeData = cameraImage.planes.map(
//           (Plane plane) {
//         return InputImagePlaneMetadata(
//           bytesPerRow: plane.bytesPerRow,
//           height: plane.height,
//           width: plane.width,
//         );
//       },
//     ).toList();
//
//     final inputImageData = InputImageData(
//       size: imageSize,
//       imageRotation: imageRotation,
//       inputImageFormat: inputImageFormat,
//       planeData: planeData,
//     );
//
//     final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
//
//   }
//
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
//
// }
//
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/json_helper.dart';

class LiveTranscribeScreen extends StatefulWidget {
  const LiveTranscribeScreen({Key? key}) : super(key: key);

  @override
  _LiveTranscribeScreenState createState() => _LiveTranscribeScreenState();
}

class _LiveTranscribeScreenState extends State<LiveTranscribeScreen> {
  File? _imageFile;

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      Directory appDirectory = await getApplicationDocumentsDirectory();
      Directory imagesDirectory = Directory("${appDirectory.path}/images");
      await _imageFile
          ?.copy("${imagesDirectory.path}/${DateTime.now().toString()}.jpg");

      final InputImage inputImage = InputImage.fromFile(_imageFile!);
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
      if (_imageFile != null) {
        final confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Save this image note?'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(_imageFile!),
                  Text(
                    finalText,
                    style: const TextStyle(fontFamily: "ProductSans"),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          // Save the image here.
          final notes = await JsonHelper.instance.getNotes();
          // final note = widget.note.copyWith(title: title, content: content, id: widget.note.id);
          final note = Note(
              title: DateTime.now().toString(),
              id: (notes.length + 1).toString(),
              content: finalText);
          await JsonHelper.instance.update(note);
        } else {
          setState(() {
            _imageFile = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Center(
        child: _imageFile == null
            ? const Text(
                'Click on the shutter below to begin',
                style: TextStyle(fontSize: 16),
              )
            : Image.file(_imageFile!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        tooltip: 'Take Picture',
        child: const Icon(Icons.camera),
      ),
    );
    throw UnimplementedError();
  }

  // if (_imageFile != null) {
  //   final confirmed = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Save this image?'),
  //         content: Image.file(_imageFile!),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () => Navigator.of(context).pop(false),
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () => Navigator.of(context).pop(true),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (confirmed == true) {
  //     // Save the image here.
  //   } else {
  //     setState(() {
  //       _imageFile = null;
  //     });
  //   }
}
