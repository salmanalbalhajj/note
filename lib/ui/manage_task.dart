import 'package:flutter/material.dart';
import 'package:note/db/db_helper.dart';
import 'package:note/model/note_.dart';
import 'package:note/ui/home.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({Key? key}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final newNote = Note(
        null,
        _titleController.text,
        _descriptionController.text,
        DateTime.now().toIso8601String().substring(0, 16).replaceAll('T', ' '));

    await DbHelper.addTask(newNote);

    // Navigate to the detail page of the new note
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0), // ارتفاع شريط التطبيق
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Container(
            padding: const EdgeInsets.only(bottom: 2.0), // Padding من الأسفل
            alignment: Alignment.bottomLeft,
            child: AppBar(
              backgroundColor: Colors.teal[400],
              elevation: 0, // إزالة الظل
              title: const Text(
                "إضافة ملاحظة",
                style: TextStyle(
                  fontSize: 20, // حجم النص
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    _saveNote();
                    setState(() {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return Home();
                        },
                      ));
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // حقل تحرير عنوان الملاحظة
              TextField(
                controller: _titleController,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'عنوان الملاحظة',
                ),
              ),
              const SizedBox(height: 16),
              // حقل تحرير محتوى الملاحظة
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  textAlign: TextAlign.right,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'محتوى الملاحظة',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
