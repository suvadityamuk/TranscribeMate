import 'package:flutter/material.dart';

import '../utils/json_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note note;

  const NoteEditorScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    JsonHelper.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Title"),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 5, //<-- SEE HERE
                        color: Colors.orange,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text("Content"),
              TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 5, //<-- SEE HERE
                        color: Colors.orange,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          heroTag: 'btn1',
          onPressed: () async {
            final title = _titleController.text;
            final content = _contentController.text;
            final note = widget.note
                .copyWith(title: title, content: content, id: widget.note.id);
            await JsonHelper.instance.delete(int.parse(widget.note.id));
            Navigator.of(context).pop(note);
          },
          child: const Icon(Icons.delete_forever),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'btn2',
          onPressed: () async {
            final title = _titleController.text;
            final content = _contentController.text;
            if (title.isNotEmpty && content.isNotEmpty == true) {
              final note = widget.note
                  .copyWith(title: title, content: content, id: widget.note.id);
              await JsonHelper.instance.update(note);
              Navigator.of(context).pop(note);
            }
          },
          child: const Icon(Icons.check),
        ),
      ]),
    );
  }
}
