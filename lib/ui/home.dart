import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note/db/db_helper.dart';
import 'package:note/model/note_.dart';
import 'package:note/ui/manage_task.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() async {
     setState(() {});
    super.initState();
    await _initializeDatabase(); // تهيئة قاعدة البيانات
  }

  Future<void> _initializeDatabase() async {
    await DbHelper.initDB(); // استدعاء دالة initDB
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.teal[50],
          appBar: AppBar(
            backgroundColor: Colors.teal[900],
            title: const Text(
              "ملاحظاتي",
              style: TextStyle(color: Colors.white),
            ),
            elevation: 5.0,
          ),
          floatingActionButton: Builder(builder: (ctx) {
            return FloatingActionButton(
              backgroundColor: Colors.teal[900],
              onPressed: () {
                showModalBottomSheet(
                  context: ctx,
                  isScrollControlled: true,
                  backgroundColor: Colors.teal[50],
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (context) => const AddNotePage(),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            );
          }),
          body: FutureBuilder<List<Map<String, Object?>>>(
            initialData: const [],
            future: DbHelper.getAllTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return Center(child: Text("خطأ: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("لا توجد بيانات"));
              } else {
                List<Note> notes = snapshot.data!.map((data) {
                  return Note(
                    data['id'] as int?,
                    data['title'] as String,
                    data['description'] as String,
                    data['date'] as String,
                  );
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailPage(
                                note: note,
                                onDelete: () {
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal[100]!, Colors.teal[300]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  note.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[900],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  note.description,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: Colors.teal[800],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    note.date,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.teal[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}


class NoteDetailPage extends StatefulWidget {
  final Note note;
  final Function() onDelete;

  const NoteDetailPage({required this.note, required this.onDelete, Key? key})
      : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController =
        TextEditingController(text: widget.note.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (widget.note.id != null) {
      // إنشاء كائن Note جديد مع البيانات المحدثة
      final updatedNote = Note(
        widget.note.id, // استخدام المعرف الحالي
        _titleController.text,
        _descriptionController.text,
        widget.note.date, // يمكنك تحديث التاريخ إذا لزم الأمر
      );

      // استدعاء دالة updateTask
      await DbHelper.updateTask(updatedNote, widget.note.id!);

      // تحديث البيانات في الواجهة
      setState(() {
        widget.note.title = _titleController.text;
        widget.note.description = _descriptionController.text;
      });

      // عرض SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حفظ الملاحظة بنجاح"),
        ),
      );

      // الانتقال إلى الصفحة الرئيسية بعد فترة قصيرة
      await Future.delayed(const Duration(seconds: 1)); // تأخير لعرض SnackBar
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return Home();
        },
      ));
    }
  }

  void _shareNote() {
    final String content =
        "${_titleController.text}\n\n${_descriptionController.text}";
    Share.share(content, subject: 'ملاحظة جديدة');
  }

  Future<void> _deleteNote() async {
    if (widget.note.id != null) {
      await DbHelper.deleteTask(widget.note.id!);
      widget.onDelete(); // تحديث الصفحة الرئيسية

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حذف الملاحظة بنجاح"),
        ),
      );

      Navigator.pop(context); // العودة إلى الصفحة السابقة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("خطأ: لا يمكن حذف ملاحظة بدون ID"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الملاحظة"),
        backgroundColor: Colors.teal[400],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveNote();
            }, // استدعاء دالة الحفظ
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("تأكيد الحذف"),
                    content: const Text("هل تريد بالتأكيد حذف هذه الملاحظة؟"),
                    actions: [
                      TextButton(
                        child: const Text("إلغاء"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("حذف"),
                        onPressed: () {
                          _deleteNote();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'عنوان الملاحظة',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _descriptionController,
                textAlign: TextAlign.right,
                maxLines: null,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'محتوى الملاحظة',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[400],
        onPressed: _shareNote,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }
}
