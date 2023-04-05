import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Note {
  String id;
  String title;
  String content;

  Note({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  Note copyWith({
    required String id,
    required String title,
    required String content,
  }) {
    return Note(
      id: id,
      title: title,
      content: content
    );
  }
}


class JsonHelper {
  static final JsonHelper instance = JsonHelper._instance();
  static const String _fileName = 'notes.json';
  late String _filePath;

  List<Note> _notes = [];

  JsonHelper._instance();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _filePath = "${dir.path}/$_fileName";
    final file = File(_filePath);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      _notes = (jsonData['notes'] as List)
          .map((note) => Note(
        id: note['id'],
        title: note['title'],
        content: note['content'],
      ))
          .toList();
    } else {
      await file.create();
    }
  }

  // Future<void> _initFilePath() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   _filePath = '${directory.path}/$_fileName';
  // }

  Future<List<Note>> getNotes() async {
    return _notes;
  }

  Future<void> add(Note note) async {
    note.id = (_notes.length + 1) as String;
    _notes.add(note);
    await _save();
  }

  Future<void> update(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _save();
    }
    else {
      _notes.add(note);
      await _save();
    }
  }

  Future<void> delete(int id) async {
    _notes.removeWhere((n) => n.id == id.toString());
    await _save();
  }

  Future<void> _save() async {
    final file = File(_filePath);
    final jsonData = {"notes": _notes.map((note) => note.toJson()).toList()};
    await file.writeAsString(json.encode(jsonData));
  }
}