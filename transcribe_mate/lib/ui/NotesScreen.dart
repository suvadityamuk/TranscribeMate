// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
//
// class Note {
//   final String title;
//   final String body;
//   final DateTime createdTime;
//
//   Note({
//     required this.title,
//     required this.body,
//     required this.createdTime,
//   });
// }
//
// class NotesScreen extends StatefulWidget {
//   const NotesScreen({Key? key}) : super(key: key);
//
//   @override
//   _NotesScreenState createState() => _NotesScreenState();
// }
//
// class _NotesScreenState extends State<NotesScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _bodyController = TextEditingController();
//   final List<Note> _notes = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     Directory appDirectory = await getApplicationDocumentsDirectory();
//     File notesFile = File("${appDirectory.path}/notes.json");
//     if (await notesFile.exists()) {
//       String notesJson = await notesFile.readAsString();
//       List<dynamic> notesList = jsonDecode(notesJson);
//       setState(() {
//         _notes.clear();
//         for (dynamic noteJson in notesList) {
//           _notes.add(Note(
//             title: noteJson['title'],
//             body: noteJson['body'],
//             createdTime: DateTime.parse(noteJson['createdTime']),
//           ));
//         }
//       });
//     }
//   }
//
//   Future<void> _saveNotes() async {
//     Directory appDirectory = await getApplicationDocumentsDirectory();
//     File notesFile = File("${appDirectory.path}/notes.json");
//     List<Map<String, dynamic>> notesList = _notes.map((note) {
//       return {
//         'title': note.title,
//         'body': note.body,
//         'createdTime': note.createdTime.toIso8601String(),
//       };
//     }).toList();
//     String notesJson = jsonEncode(notesList);
//     await notesFile.writeAsString(notesJson);
//   }
//
//   void _addNote() {
//     setState(() {
//       _notes.add(Note(
//         title: _titleController.text,
//         body: _bodyController.text,
//         createdTime: DateTime.now(),
//       ));
//       _titleController.clear();
//       _bodyController.clear();
//       _saveNotes();
//     });
//   }
//
//   void _deleteNoteAtIndex(int index) {
//     setState(() {
//       _notes.removeAt(index);
//       _saveNotes();
//     });
//   }
//
//   void _editNoteAtIndex(int index) async {
//     final Note note = _notes[index];
//     final TextEditingController titleController =
//     TextEditingController(text: note.title);
//     final TextEditingController bodyController =
//     TextEditingController(text: note.body);
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Edit Note"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: const InputDecoration(hintText: "Title"),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: bodyController,
//               decoration: const InputDecoration(hintText: "Body"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _notes[index] = Note(
//                   title: titleController.text,
//                   body: bodyController.text,
//                   createdTime: note.createdTime,
//                 );
//                 _saveNotes();
//               });
//               Navigator.pop(context);
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Notes"),
//         ),
//       body: ListView.builder(
//         itemCount: _notes.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(_notes[index].title),
//             subtitle: Text(
//               _notes[index].body.length > 50
//                   ? "${_notes[index].body.substring(0, 50)}..."
//                   : _notes[index].body,
//             ),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () => _deleteNoteAtIndex(index),
//             ),
//             onTap: () => _editNoteAtIndex(index),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: const Text("New Note"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _titleController,
//                     decoration: const InputDecoration(hintText: "Title"),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _bodyController,
//                     decoration: const InputDecoration(hintText: "Body"),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     _addNote();
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Save"),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../utils/json_helper.dart';
import 'NoteEditorScreen.dart';
import '../utils/json_helper.dart';
import 'NoteEditorScreen.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      JsonHelper.instance.init();
      _loadNotes();
    });
    super.initState();
  }

  Future<void> _loadNotes() async {
    final notes = await JsonHelper.instance.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
              'No notes found. Click on the + below to begin',
              style: TextStyle(fontSize: 18.0),
            ))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Dismissible(
                  key: Key(note.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  onDismissed: (direction) async {
                    await JsonHelper.instance.delete(index);
                    setState(() {
                      _notes.remove(note);
                    });
                  },
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(note: note),
                        ),
                      ).then((context) => _loadNotes());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NoteEditorScreen(
                      note: Note(
                        id: (_notes.length + 1).toString(),
                        title: '',
                        content: '',
                      ),
                    )),
          ).then((context) => _loadNotes());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
